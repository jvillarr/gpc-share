#!/bin/sh
BAKDIR="/opt/tmp-dev"

echo "Cleaning up xml files"
rm -f ${BAKDIR}/automate_backups/*.xml

echo "Backing up Automate model"
cd /var/www/miq/vmdb
script/rails runner script/rake evm:automate:backup FILE=${BAKDIR}/automate_backups/automate_backup.xml
script/rails runner script/rake evm:automate:export NAMESPACE=MCICOM FILE=${BAKDIR}/automate_backups/namespace_MCICOM.xml

echo "Backing up database"

SQLFILE="/tmp/postgres.sql"

su - postgres -c "pg_dumpall > ${SQLFILE}"

if [ ! -f ${SQLFILE} ] ; then
  echo "Error, ${SQLFILE} does NOT exist"
  exit 1
else 
  cd /tmp
  tar cvzf ${BAKDIR}/database_backups/database-backup.tar.gz ${SQLFILE}
fi
 
