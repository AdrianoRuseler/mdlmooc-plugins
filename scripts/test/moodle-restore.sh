#!/bin/bash

DB_BKP="/mnt/mdl/bkp/db/" # moodle database backup folder
DATA_BKP="/mnt/mdl/bkp/data/" # moodle data backup folder
MOODLE_DATA="/mnt/mdl/data"  # moodle data folder
MOODLE_DB="/mnt/mdl/db/data"  # moodle database folder

echo "Activating Moodle Maintenance Mode in..."
sudo -u www-data /usr/bin/php $MOODLE_HOME/admin/cli/maintenance.php --enable

echo "Get latest DB backup files.."
dbmd5file=$(ls -t $DB_BKP | head -2 | grep -e '\bmd5$')
dbgzfile=$(ls -t $DB_BKP | head -2 | grep -e '\bgz$')

md5sum -c $DB_BKP$dbmd5file # Check DB file

echo "Get latest Data backup files.."
datamd5file=$(ls -t $DATA_BKP | head -2 | grep -e '\bmd5$')
datagzfile=$(ls -t $DATA_BKP | head -2 | grep -e '\bgz$')

md5sum -c $DATA_BKP$datamd5file # Check data file


filename=$(date +\%Y-\%m-\%d-\%H.\%M) # Generates filename

# make database backup
mdldbname=$(cat $MOODLE_HOME/config.php | grep '$CFG->dbname' | cut -d\' -f 2) # Gets Moodle DB Name
mdldbuser=$(cat $MOODLE_HOME/config.php | grep '$CFG->dbuser' | cut -d\' -f 2) # Gets Moodle DB User
# mdldbpass=$(cat $MOODLE_HOME/config.php | grep '$CFG->dbpass' | cut -d\' -f 2) # Gets Moodle DB Pass

echo "Make database backup..."
sudo -i -u postgres pg_dump $mdldbname | gzip > $DB_BKP$filename.psql.gz
md5sum $DB_BKP$filename.psql.gz > $DB_BKP$filename.psql.gz.md5
md5sum -c $DB_BKP$filename.psql.gz.md5
ls -lh $DB_BKP # list folder content

echo "Drop database..."
sudo -i -u postgres dropdb $mdldbname

touch /tmp/createdb$mdldbname.sql
echo $'CREATE DATABASE '${mdldbname}$';' >> /tmp/createdb$mdldbname.sql
echo $'GRANT ALL PRIVILEGES ON DATABASE '${mdldbname}$' TO '${mdldbuser}$';' >> /tmp/createdb$mdldbname.sql
cat /tmp/createdb$mdldbname.sql
echo ""

echo "Create DB and grant user acess..."
sudo -i -u postgres psql -f /tmp/createdb$mdldbname.sql
rm /tmp/createdb$mdldbname.sql

echo "Restore database..."
gunzip -c $DB_BKP$dbgzfile > /tmp/restoreme.sql
sudo -i -u postgres psql -d $mdldbname -f /tmp/restoreme.sql
rm /tmp/restoreme.sql

echo "Remove Moodle DB..."
rm -rf $MOODLE_DATA
mkdir $MOODLE_DATA
tar xvzf $DATA_BKP$datagzfile -C $MOODLE_DATA
chown www-data:www-data -R $MOODLE_DATA

echo "disable the maintenance mode..."
sudo -u www-data /usr/bin/php $MOODLE_HOME/admin/cli/maintenance.php --disable

