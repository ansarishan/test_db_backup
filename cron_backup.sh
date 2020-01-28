#!/bin/sh
# Set variables
DB_NAME="api_db"
CRON_USER="cron_user"

FULLDATE=$(date +"%Y-%d-%m %H:%M")
NOW=$(date +"%Y-%m-%d-%H-%M")
MYSQL_DUMP=`which mysqldump`
GIT=`which git`
TEMP_BACKUP="latest_backup.sql"
BACKUP_DIR=$(date +"%Y/%m")

# Delete older files
find /api -type f -mtime +10 -exec rm -f {} \; 
# Check current Git status and update
${GIT} status
${GIT} pull origin HEAD

# Dump database
${MYSQL_DUMP} -u "$CRON_USER" $DB_NAME > $TEMP_BACKUP &
wait

# Make backup directory if not exists (format: {year}/{month}/)
#if [ ! -d "$BACKUP_DIR" ]; then
 # mkdir -p $BACKUP_DIR
#fi

# Compress SQL dump
tar -cvzf api_db/$DB_NAME-$NOW-sql.tar.gz $TEMP_BACKUP

# Remove original SQL dump
rm -f $TEMP_BACKUP

# Add to Git and commit
${GIT} add -A
${GIT} commit -m "Automatic backup - $FULLDATE"
${GIT} push origin HEAD
