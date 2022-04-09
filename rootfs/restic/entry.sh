#!/bin/sh
echo "Welcome to steilerDev-Restic Docker!"

STATUS_FILE="/restic/status.info"
if [ ! -f $STATUS_FILE ]; then
    /restic/status.sh "SCHEDULED"
fi

echo "Checking your remote repository..."
/restic/restic snapshots > /dev/null
if [ $? -ne 0 ] ; then
    echo "Restic repository does not exists at the defined location"
    echo "Starting init process..."
    /restic/restic init
fi
echo "...done"

echo "Setting up cron-job..."
> /etc/crontabs/root
echo "# min   hour    day     month   weekday command" >> /etc/crontabs/root
echo "$CRON_SCHEDULE /restic/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2" >> /etc/crontabs/root
echo "...done"

echo "Starting scheduled backup process with cron schedule:"
cat /etc/crontabs/root 
crond -fS
