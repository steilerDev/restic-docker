#!/bin/bash
trap "kill 0" SIGINT

echo "Welcome to steilerDev-Restic Docker!"
echo
echo "Checking your remote repository..."
/restic/restic snapshots > /dev/null
if [ $? -ne 0 ] ; then
    echo "Restic repository does not exists at the defined location"
    echo "Starting init process..."
    /restic/restic init
fi
echo "...done"
echo

if [ -z "$CRON_SCHEDULE" ]; then
    echo "No CRON_SCHEDULE defined, aborting!"
    exit 1
else
    echo "$CRON_SCHEDULE /restic/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/crontabs/root
fi

/restic/status.sh "SCHEDULED"
echo
crond -fS