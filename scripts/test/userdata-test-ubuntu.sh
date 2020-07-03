#!/bin/bash

# cat /var/log/cloud-init-output.log
echo "#1 - Initial system setup"
export DEBIAN_FRONTEND=noninteractive
apt update && apt upgrade -yq

echo "Autoremove and Autoclean System..."
apt autoremove -yq && apt autoclean -yq

echo "Set and Add locales pt_BR, en_US, es_ES, de_DE, fr_FR, pt_PT..."
sed -i '/^#.* pt_BR.* /s/^#//' /etc/locale.gen
sed -i '/^#.* en_AU.* /s/^#//' /etc/locale.gen
sed -i '/^#.* en_US.* /s/^#//' /etc/locale.gen
sed -i '/^#.* es_ES.* /s/^#//' /etc/locale.gen
sed -i '/^#.* de_DE.* /s/^#//' /etc/locale.gen
sed -i '/^#.* fr_FR.* /s/^#//' /etc/locale.gen
sed -i '/^#.* pt_PT.* /s/^#//' /etc/locale.gen
locale-gen

# Set timezone and locale
timedatectl set-timezone America/Sao_Paulo
update-locale LANG=pt_BR.UTF-8 # Requires reboot

# Set EBS -> https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html
mkdir /mnt/mdl
mkfs -t xfs /dev/xvdb
mount -t xfs /dev/xvdb /mnt/mdl
mkdir -p /mnt/mdl/{db,data,bkp}
mkdir -p /mnt/mdl/bkp/{db,data,html,auto} # Creates backup folders

# Automatically mount an attached volume after reboot
cp /etc/fstab /etc/fstab.orig # Make backup
MNTUUID=$(lsblk -nr -o UUID,MOUNTPOINT | grep -Po '.*(?= /mnt/mdl)')
echo $'UUID='${MNTUUID}$' /mnt/mdl xfs defaults,nofail  0  2' >> /etc/fstab

# Instalar a AWS CLI versão 2 no Linux -> https://docs.aws.amazon.com/pt_br/cli/latest/userguide/install-cliv2-linux.html
cd /home/ubuntu
apt install -y unzip # p7zip-full
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
rm -rf awscliv2.zip
sudo ./aws/install
aws --version

echo "#2 - Web server and dependencies setup"

# Set web server (apache)
PUBHOST=$(ec2metadata --public-hostname | cut -d : -f 2 | tr -d " ")

# Install web server
apt install -y apache2
a2enmod ssl rewrite headers deflate socache_shmcb
systemctl restart apache2
systemctl status apache2

#Create directory structure
mkdir -p /var/www/moodle/{html,local,cache,temp,git}
chown -R www-data:www-data /var/www/moodle/{html,local,cache,temp,git}
chown -R www-data:www-data /mnt/mdl/bkp/{db,data,html,auto} # Creates backup folders

# Create new conf files
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/moodle.conf
cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/moodle-ssl.conf

# Gets public hostname
PUBHOST=$(ec2metadata --public-hostname | cut -d : -f 2 | tr -d " ")
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj $"/C=BR/ST=PR/L=CWB/O=MDLTEST/CN='${PUBHOST}$'"

# Set webmaster email
if [[ -z "${ADM_EMAIL}" ]]; then # If variable is defined
  sed -i 's/webmaster@localhost/admin@fake.mail/' /etc/apache2/sites-available/moodle-ssl.conf
  sed -i 's/webmaster@localhost/admin@fake.mail/' /etc/apache2/sites-available/moodle.conf
else
  sed -i 's/webmaster@localhost/$ADM_EMAIL/' /etc/apache2/sites-available/moodle-ssl.conf
  sed -i 's/webmaster@localhost/$ADM_EMAIL/' /etc/apache2/sites-available/moodle.conf
fi

sed -i 's/\/var\/www\/html/\/var\/www\/moodle\/html/' /etc/apache2/sites-available/moodle-ssl.conf
sed -i 's/\/var\/www\/html/\/var\/www\/moodle\/html/' /etc/apache2/sites-available/moodle.conf
sed -i 's/ssl-cert-snakeoil.pem/apache-selfsigned.crt/' /etc/apache2/sites-available/moodle-ssl.conf
sed -i 's/ssl-cert-snakeoil.key/apache-selfsigned.key/' /etc/apache2/sites-available/moodle-ssl.conf

# Redirect http to https
sed -i '/combined/a \\n\tRewriteEngine On \n\tRewriteCond %{HTTPS} off \n\tRewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}' /etc/apache2/sites-available/moodle.conf


a2ensite moodle.conf moodle-ssl.conf # Enable sites
a2dissite 000-default.conf default-ssl.conf # Disable sites
systemctl reload apache2

# Install php 
apt install -y php php-curl php-cli php-pgsql php-gd php-soap php-intl php-xml php-mbstring php-xmlrpc php-zip php-ldap php-redis php-memcached php-apcu php-opcache

# touch /var/www/moodle/html/index.php
# echo '<?php phpinfo(); ?>' >> /var/www/moodle/html/index.php
# Set PHP ini
sed -i 's/memory_limit =.*/memory_limit = 512M/' /etc/php/7.4/apache2/php.ini
sed -i 's/post_max_size =.*/post_max_size = 128M/' /etc/php/7.4/apache2/php.ini
sed -i 's/upload_max_filesize =.*/upload_max_filesize = 128M/' /etc/php/7.4/apache2/php.ini
systemctl reload apache2

# create hidden opcache directory locally & change owner to apache - NOT TESTED
if [ ! -d /var/www/.opcache ]; then
  mkdir -p /var/www/.opcache
fi
#Ensure opcache is enabled and add settings recomended by moodle at https://docs.moodle.org/34/en/OPcache
sed -i 's/;opcache.file_cache=.*/opcache.file_cache=\/var\/www\/.opcache/' /etc/php/7.4/apache2/conf.d/10-opcache.ini
sed -i 's/opcache.memory_consumption=.*/opcache.memory_consumption=512/' /etc/php/7.4/apache2/conf.d/10-opcache.ini
sed -i 's/opcache.max_accelerated_files=.*/opcache.max_accelerated_files=8000/' /etc/php/7.4/apache2/conf.d/10-opcache.ini
sed -i 's/;opcache.revalidate_freq=.*/opcache.revalidate_freq=300/' /etc/php/7.4/apache2/conf.d/10-opcache.ini
sed -i 's/;opcache.use_cwd=.*/opcache.use_cwd=1/' /etc/php/7.4/apache2/conf.d/10-opcache.ini
sed -i 's/;opcache.validate_timestamps=.*/opcache.validate_timestamps=1/' /etc/php/7.4/apache2/conf.d/10-opcache.ini
sed -i 's/;opcache.save_comments=.*/opcache.save_comments=1/' /etc/php/7.4/apache2/conf.d/10-opcache.ini
sed -i 's/;opcache.enable_file_override=.*/opcache.enable_file_override=60/' /etc/php/7.4/apache2/conf.d/10-opcache.ini
systemctl restart apache2

# Install cache tools
apt install -y redis memcached
systemctl enable memcached
systemctl start memcached
systemctl start redis

# Display status
systemctl status memcached
systemctl status redis

# Install db 
apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql

mkdir -p /mnt/mdl/db/data
chown -R postgres:postgres /mnt/mdl/db
sudo -i -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D /mnt/mdl/db/data initdb # Inits database
systemctl start postgresql
psql --version

echo "Install pwgen..."
# https://www.2daygeek.com/5-ways-to-generate-a-random-strong-password-in-linux-terminal/
apt install -y pwgen # Install pwgen

echo ""
echo "##---------------------- GENERATES NEW DB -------------------------##"
echo ""
PGDBNAME=$(pwgen -s 10 -1 -v -A -0) # Generates ramdon db name
PGDBUSER=$(pwgen -s 10 -1 -v -A -0) # Generates ramdon user name
PGDBPASS=$(pwgen -s 14 1) # Generates ramdon password for db user
echo "DB Name: $PGDBNAME"
echo "DB User: $PGDBUSER"
echo "DB Pass: $PGDBPASS"
echo ""

touch /tmp/createdbuser.sql
echo $'CREATE DATABASE '${PGDBNAME}$';' >> /tmp/createdbuser.sql
echo $'CREATE USER '${PGDBUSER}$' WITH PASSWORD \''${PGDBPASS}$'\';' >> /tmp/createdbuser.sql
echo $'GRANT ALL PRIVILEGES ON DATABASE '${PGDBNAME}$' TO '${PGDBUSER}$';' >> /tmp/createdbuser.sql
cat /tmp/createdbuser.sql

sudo -i -u postgres psql -f /tmp/createdbuser.sql
rm /tmp/createdbuser.sql


echo "#3 - Tools and dependencies for Moodle"

echo "Install Universal Office Converter..."
apt install -y unoconv
chown www-data /var/www

echo "To use spell-checking within the editor, you MUST have aspell 0.50 or later installed on your server..."
apt install -y aspell dictionaries-common libaspell15 aspell-de aspell-es aspell-fr aspell-en aspell-pt-br aspell-pt-pt aspell-doc spellutils

echo "To be able to generate graphics from DOT files, you must have installed the dot executable..."
apt install -y graphviz imagemagick

export DEBIAN_FRONTEND=noninteractive
apt update && apt upgrade -yq

echo "Autoremove and Autoclean System..."
apt autoremove -yq && apt autoclean -yq


echo "#4 - Install moodle"

# Clone git repository
cd /var/www/moodle/git
git clone --depth=1 --branch=MOODLE_39_STABLE https://github.com/moodle/moodle.git core
git clone --depth=1 --recursive https://github.com/AdrianoRuseler/mdlmooc-plugins.git plugins

# Merge and move moodle files
rsync -a /var/www/moodle/git/core/ /tmp/moodle
rsync -a /var/www/moodle/git/plugins/moodle/ /tmp/moodle
rsync -a /var/www/moodle/git/plugins/climaintenance.html /mnt/mdl/data/climaintenance.html

mv /tmp/moodle/* /var/www/moodle/html

# Copy moodle config file
cp /var/www/moodle/git/plugins/scripts/test/config-dist.php /var/www/moodle/html/config.php 
sed -i 's/mydbname/'"$PGDBNAME"'/' /var/www/moodle/html/config.php # Configure password
sed -i 's/mydbuser/'"$PGDBUSER"'/' /var/www/moodle/html/config.php # Configure password
sed -i 's/mydbpass/'"$PGDBPASS"'/' /var/www/moodle/html/config.php # Configure password
sed -i 's/mytesturl/https:\/\/'"$PUBHOST"'/' /var/www/moodle/html/config.php # Configure url

cp /var/www/moodle/git/plugins/scripts/test/defaults-dist.php /var/www/moodle/html/local/defaults.php 
sed -i 's/mytesturl/'"$PUBHOST"'/' /var/www/moodle/html/local/defaults.php 

MDLADMPASS=$(pwgen -s 14 1) # Generates ramdon password for Moodle Admin
sed -i 's/myadmpass/'"$MDLADMPASS"'/' /var/www/moodle/html/local/defaults.php # Set password in file


# Set email sender
if [[ -z "${SMTP_HOST}" ]]; then # If variable is defined
	echo "Email sender not defined!!"
else
# Email Setup
	echo '' >> /var/www/moodle/html/local/defaults.php
	echo $'$defaults[\'moodle\'][\'smtphosts\'] = \''${SMTP_HOST}$':587\';' >> /var/www/moodle/html/local/defaults.php
	echo $'$defaults[\'moodle\'][\'smtpsecure\'] = \'tls\';' >> /var/www/moodle/html/local/defaults.php
	echo $'$defaults[\'moodle\'][\'smtpauthtype\'] = \'LOGIN\';' >> /var/www/moodle/html/local/defaults.php
	echo $'$defaults[\'moodle\'][\'smtpuser\'] = \''${SMTP_USER}$'\';' >> /var/www/moodle/html/local/defaults.php
	echo $'$defaults[\'moodle\'][\'smtppass\'] = \''${SMTP_PASS}$'\';' >> /var/www/moodle/html/local/defaults.php
	echo '' >> /var/www/moodle/html/local/defaults.php
fi

# Set BigBluButton server
if [[ -z "${BBB_URL}" ]]; then # If variable is defined
	echo "BBB server not defined!!"
else
# Email Setup
	echo '' >> /var/www/moodle/html/local/defaults.php
	echo $'$defaults[\'moodle\'][\'bigbluebuttonbn_server_url\'] = \''${BBB_URL}$'\';' >> /var/www/moodle/html/local/defaults.php
	echo $'$defaults[\'moodle\'][\'bigbluebuttonbn_shared_secret\'] = \''${BBB_SECRET}$'\';' >> /var/www/moodle/html/local/defaults.php
	echo '' >> /var/www/moodle/html/local/defaults.php
fi

# Fix permissions
chmod 740 /var/www/moodle/html/admin/cli/cron.php
chown www-data:www-data -R /var/www/moodle/html
chown www-data:www-data -R /mnt/mdl/data

cd /var/www/moodle/html
mdlver=$(cat version.php | grep '$release' | cut -d\' -f 2) # Gets Moodle Version

#Install moodle database
if [[ -z "${ADM_EMAIL}" ]]; then # If variable is defined
  sudo -u www-data /usr/bin/php admin/cli/install_database.php --lang=pt_br --adminpass=$MDLADMPASS --agree-license --adminemail=admin@fake.mail --fullname="Moodle $mdlver" --shortname="Moodle $mdlver"
else
  sudo -u www-data /usr/bin/php admin/cli/install_database.php --lang=pt_br --adminpass=$MDLADMPASS --agree-license --adminemail=$ADM_EMAIL --fullname="Moodle $mdlver" --shortname="Moodle $mdlver"
fi

# Add cron for moodle - Shows: no crontab for root
(crontab -l | grep . ; echo -e "*/1 * * * * /usr/bin/php  /var/www/moodle/html/admin/cli/cron.php >/dev/null\n") | crontab -

# Install H5P content
sudo -u www-data /usr/bin/php admin/tool/task/cli/schedule_task.php --execute='\core\task\h5p_get_content_types_task'


