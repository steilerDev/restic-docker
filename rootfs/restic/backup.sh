#!/bin/sh

STATUS_FILE="/restic/status.info"

/restic/status.sh "BACKUP_STARTED"

/restic/restic backup /backup
if [ $? -eq 0 ]; then
    /restic/status.sh "BACKUP_SUCCESS"
    /restic/forget.sh
else
    /restic/status.sh "BACKUP_FAILED"
fi

