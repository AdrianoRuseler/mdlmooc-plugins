#!/bin/bash

courseid=2
userid=3
sectionid=1 
 
MOODLE_HOME="/var/www/moodle/html" # moodle core folder
MOODLE_DATA="/mnt/mdl/data" # moodle data folder
BKP_DIR="/mnt/mdl/mdlbkp" # moodle backup folder

cd $MOODLE_HOME
 
mdlrelease=$(moosh -n config-get core release)
moosh -n course-config-set course 1 shortname "$mdlrelease"

forumid=$(moosh -n activity-add --name "Moodle $mdlrelease - Report at $(date)" -o="--intro=Moodle version $mdlrelease - $(date)." --section $sectionid forum $courseid)

# courseusers=$(moosh -n user-list --course $courseid)
# moosh -n forum-newdiscussion --subject "Users in this Course" --message "<pre>$courseusers</pre>" $courseid $forumid $userid

mdlpluginsusage=$(moosh -n plugins-usage)
moosh -n forum-newdiscussion --subject "Plugins Usage - Shows the usage of the subset of the plugins used in Moodle installation." --message "<pre>$mdlpluginsusage</pre>" $courseid $forumid $userid

datastats=$(moosh -n data-stats)
moosh -n forum-newdiscussion --subject "Data Stats - Provides information on size of dataroot directory, dataroot/filedir subdirectory and total size of non-external files in moodle." --message "<pre>$datastats</pre>" $courseid $forumid $userid

mdldatastats=$(moosh -n data-stats)
moosh -n forum-newdiscussion --subject "Plugins Usage - Shows the usage of the subset of the plugins used in Moodle installation." --message "<pre>$mdldatastats</pre>" $courseid $forumid $userid

coreconfig=$(moosh -n config-get)
coreconfig=$(echo $coreconfig | sed -e "s/\[dbpass\] => [^[:space:]]*/\[dbpass\] => mysecretpass/g") # Hides db password
coreconfig=$(echo $coreconfig | sed -e "s/\[smtppass\] => [^[:space:]]*/\[smtppass\] => mysecretpass/g") # Hides smtp password

moosh -n forum-newdiscussion --subject "Config - Get config variable from config or config_plugins table." --message "<pre>$coreconfig</pre>" $courseid $forumid $userid

pluginsconfig=$(moosh -n config-plugins)
moosh -n forum-newdiscussion --subject "Config - Get config variable from config_plugins table." --message "<pre>$pluginsconfig</pre>" $courseid $forumid $userid

courselist=$(moosh -n course-list)
moosh -n forum-newdiscussion --subject "Course List - Lists courses that match your search criteria." --message "<pre>$courselist</pre>" $courseid $forumid $userid

eventlist=$(moosh -n event-list)
moosh -n forum-newdiscussion --subject "Event List - List all events available in current Moodle installation." --message "<pre>$eventlist</pre>" $courseid $forumid $userid

datacheck=$(moosh -n file-datacheck)
moosh -n forum-newdiscussion --subject "File Datacheck - Go through all files in Moodle data and check them for corruption." --message "<pre>$datacheck</pre>" $courseid $forumid $userid

dbcheck=$(moosh -n file-dbcheck)
moosh -n forum-newdiscussion --subject "File dbcheck - Check that all files recorder in the DB do exist in Moodle data directory." --message "<pre>$dbcheck</pre>" $courseid $forumid $userid

infoplugins=$(moosh -n info-plugins)
moosh -n forum-newdiscussion --subject "Info Plugins - List all possible plugins in this version of Moodle and directory for each." --message "<pre>$infoplugins</pre>" $courseid $forumid $userid

# nowdate=$(date '+%Y%m%d')
# lastweek=$(date +%Y%m%d -d "7 day ago")
# concurrency=$(moosh -n report-concurrency -f $lastweek -t $nowdate -p 30)
# moosh -n forum-newdiscussion --subject "Report Concurrency (last Week)- Get information about concurrent users online." --message "<pre>$concurrency</pre>" $courseid $forumid $userid

themeinfo=$(moosh -n theme-info)
moosh -n forum-newdiscussion --subject "Theme Info - Show what themes are really used on Moodle site." --message "<pre>$themeinfo</pre>" $courseid $forumid $userid

authlist=$(moosh -n auth-list)
moosh -n forum-newdiscussion --subject "Auth List - List authentication plugins." --message "<pre>$authlist</pre>" $courseid $forumid $userid

categorylist=$(moosh -n category-list)
moosh -n forum-newdiscussion --subject "Category List - List all categories or those that match search string(s)." --message "<pre>$categorylist</pre>" $courseid $forumid $userid
 
phpinfo=$(php -i)
moosh -n forum-newdiscussion --subject "PHP Info" --message "<pre>$phpinfo</pre>" $courseid $forumid $userid
 
moodlerootinfo1=$(ls -lh)
moodlerootinfo2=$(du -h --max-depth=1)
 
moosh -n forum-newdiscussion --subject "Moodle root info" --message "<pre>$moodlerootinfo1</pre><hr><pre>$moodlerootinfo2</pre>" $courseid $forumid $userid 

moodledatainfo1=$(ls -lh $BKP_DIR)
moodledatainfo2=$(du -h --max-depth=1 $BKP_DIR)

moosh -n forum-newdiscussion --subject "Moodle Backup info" --message "<pre>$moodledatainfo1</pre><hr><pre>$moodledatainfo2</pre>" $courseid $forumid $userid 

moodledatainfo1=$(ls -lh $MOODLE_DATA)
moodledatainfo2=$(du -h --max-depth=1 $MOODLE_DATA)

moosh -n forum-newdiscussion --subject "Moodle data info" --message "<pre>$moodledatainfo1</pre><hr><pre>$moodledatainfo2</pre>" $courseid $forumid $userid 
 
sysinfo=$(uname -a) # Gets system info
diskinfo=$(df -H) # Gets disk usage info 
httpdver=$(apachectl -V)
mysqlver=$(psql -V)
phpversion=$(php -v)

moosh -n forum-newdiscussion --subject "System info" --message "<pre>$sysinfo</pre><hr><br><pre>$diskinfo</pre><hr><br><pre>$httpdver</pre><hr><br><pre>$mysqlver</pre><hr><br><pre>$phpversion</pre>" $courseid $forumid $userid
