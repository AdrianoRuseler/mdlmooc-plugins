#!/bin/bash

DB_BKP="/mnt/mdl/bkp/db/" # moodle database backup folder
DATA_BKP="/mnt/mdl/bkp/data/" # moodle data backup folder
HTML_BKP="/mnt/mdl/bkp/html/" # moodle html backup folder
MOODLE_DATA="/mnt/mdl/data"  # moodle data folder
MOODLE_DB="/mnt/mdl/db/data"  # moodle database folder
MOODLE_HOME="/var/www/moodle/html" # moodle core folder

filename=$(date +\%Y-\%m-\%d-\%H.\%M) # Generates filename

# make database backup

sudo -i -u postgres pg_dump mdldb > $DB_BKP$filename.mdldb.sql
md5sum $DB_BKP$filename.mdldb.sql > $DB_BKP$filename.mdldb.sql.md5
md5sum -c $DB_BKP$filename.mdldb.sql.md5

sudo -i -u postgres pg_dump mdldb | gzip > $DB_BKP$filename.psql.gz
md5sum $DB_BKP$filename.psql.gz > $DB_BKP$filename.psql.gz.md5
md5sum -c $DB_BKP$filename.psql.gz.md5

# Backup the files using tar.
tar -czf $DB_BKP$filename.tar.gz $MOODLE_DB
md5sum $DB_BKP$filename.tar.gz > $DB_BKP$filename.tar.gz.md5
md5sum -c $DB_BKP$filename.tar.gz.md5

# Backup the files using tar.
tar -czf $HTML_BKP$filename.tar.gz $MOODLE_HOME
md5sum $HTML_BKP$filename.tar.gz > $HTML_BKP$filename.tar.gz.md5
md5sum -c $HTML_BKP$filename.tar.gz.md5

# Backup the files using tar.
tar -czf $DATA_BKP$filename.tar.gz $MOODLE_DATA
md5sum $DATA_BKP$filename.tar.gz > $DATA_BKP$filename.tar.gz.md5
md5sum -c $DATA_BKP$filename.tar.gz.md5

ls -lh $DATA_BKP
