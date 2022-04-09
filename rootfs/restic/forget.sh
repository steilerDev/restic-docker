#!/bin/sh
/restic/status.sh "CLEANING_STARTED"
echo "Policy: "
POLICY=""
if [ ! -z "$KEEP_LAST" ]; then 
    echo "    Keep the most recent ${KEEP_LAST} snapshots"
    POLICY="${POLICY} --keep-last ${KEEP_LAST}"
fi

if [ ! -z "$KEEP_HOURLY" ]; then 
    echo "    For the last ${KEEP_HOURLY} hours in which a snapshot was made, keep only the last snapshot for each hour"
    POLICY="${POLICY} --keep-hourly ${KEEP_HOURLY}"
fi

if [ ! -z "$KEEP_DAILY" ]; then 
    echo "    For the last ${KEEP_DAILY} days which have one or more snapshots, only keep the last one for that day"
    POLICY="${POLICY} --keep-daily ${KEEP_DAILY}"
fi

if [ ! -z "$KEEP_WEEKLY" ]; then 
    echo "    For the last ${KEEP_WEEKLY} weeks which have one or more snapshots, only keep the last one for that week"
    POLICY="${POLICY} --keep-weekly ${KEEP_WEEKLY}"
fi

if [ ! -z "$KEEP_MONTHLY" ]; then 
    echo "    For the last ${KEEP_MONTHLY} months which have one or more snapshots, only keep the last one for that month"
    POLICY="${POLICY} --keep-monthly ${KEEP_MONTHLY}"
fi

if [ ! -z "$KEEP_YEARLY" ]; then 
    echo "    For the last ${KEEP_YEARLY} years which have one or more snapshots, only keep the last one for that year"
    POLICY="${POLICY} --keep-yearly ${KEEP_YEARLY}"
fi

if [ ! -z "$KEEP_TAG" ]; then 
    echo "    Keep all snapshots which have all of the following tags ${KEEP_TAG}"
    POLICY="${POLICY} --keep-tag ${KEEP_TAG}"
fi

if [ ! -z "$KEEP_WITHIN" ]; then 
    echo "    Keep all snapshots that have been made ${KEEP_WITHIN} before the last snapshot"
    POLICY="${POLICY} --keep-within ${KEEP_WITHIN}"
fi
echo "###############################################################################"

/restic/restic forget ${POLICY} --prune -g paths
if [ $? -eq 0 ]; then
    /restic/status.sh "SUCCESS"
else
    /restic/status.sh "CLEANING_FAILED"
fi
