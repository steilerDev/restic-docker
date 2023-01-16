#!/bin/bash

PRE_RUN="/pre-run.d"

if [ -d ${PRE_RUN} ]; then
    echo "Executing pre-run scripts..."
    run-parts ${PRE_RUN}
fi

/restic/status.sh "BACKUP_STARTED"
/restic/restic backup /backup
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    /restic/status.sh "BACKUP_SUCCESS"
    /restic/forget.sh
elif [ $EXIT_CODE -eq 3]; then
    /restic/status.sh "BACKUP_INCOMPLETE"
else
    /restic/status.sh "BACKUP_FAILED"
fi