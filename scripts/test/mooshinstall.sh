#!/bin/bash

cd /var/www/moodle/git
# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
echo "Install Composer programmatically"
EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
	exit 1
fi

php composer-setup.php --quiet
rm composer-setup.php

echo "Move conposer.phar"
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
composer --version

# https://moosh-online.com/
echo "Clone moosh"
git clone git://github.com/tmuras/moosh.git
cd moosh
echo "Composer install moosh"
composer install
ln -s $PWD/moosh.php /usr/local/bin/moosh

echo "Create moosh user and report course"
cd /var/www/moodle/html
userid=$(moosh -n user-create --password M00sh#2k20 --email moosh@fake.mail --city Curitiba --country BR --firstname Moosh --lastname User moosh)
courseid=$(moosh -n course-create --category 1 --fullname "Moosh Reports" --description "Moosh command line reports" --idnumber "mooshreports" "Moosh Reports")
moosh -n course-enrol -r teacher -i $courseid $userid

