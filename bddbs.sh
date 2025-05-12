#!/bin/bash
#
# mysql backup script
# crontab version
# December 2019
# 


# change these variables as needed to fit your environment 
BKP_USER=""
BKP_PASS=""
BKP_DEST="/media/local/databaseBackups"
BKP_DAYS="2"
MYSQL_HOST="localhost"
IGNORE_DB="information_schema copra4server mysql performance_schema test"
BKP_DATE=$(date +"%Y%m%d")
# end of changeable variables


# get databases
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
DB_LIST="$($MYSQL -u $BKP_USER -h $MYSQL_HOST --password="$BKP_PASS" -Bse 'show databases')"


# make backup destination if it doesn't exist
[ ! -d $BKP_DEST ] && mkdir -p $BKP_DEST || :
echo -e "writing database backups to: "$BKP_DEST"  ---  date: ${BKP_DATE}"


# backup loop
for db in $DB_LIST; do
	skipdb=-1
	if [ "$IGNORE_DB" != "" ]; then
		for i in $IGNORE_DB; do
			[ "$db" == "$i" ] && skipdb=1 || :
		done
	fi
	
	if [ "$skipdb" == "-1" ]; then
		BKP_FILENAME="$BKP_DEST/"${db}"_${BKP_DATE}.sql"
		echo -e "backing up database: $(basename "$BKP_FILENAME")"
		$MYSQLDUMP -u $BKP_USER --password="$BKP_PASS" $db > "$BKP_FILENAME"
	fi
done


# error checking and cleanup... 
if [ $? = "0" ]; then
	echo "deleting old database backups"
	find $BKP_DEST -type f -mtime +$(expr ${BKP_DAYS} - 1) -delete
	echo "setting permissions on backup files to rwx for all..."
	chmod -R a+rwx "$BKP_DEST"
	echo -e "done..."
	exit
else
	tput setaf 1
	echo -e "something went wrong..."
	tput sgr 0
	exit 1
fi

