#!/bin/bash

# Expecting first argument to be status value
# For valid values, see STATUS_DICT below
#
# If called without status value it will pritty print the status which is read from file
# Builds and exptects Influx Line Protocol (https://docs.influxdata.com/influxdb/latest/reference/syntax/line-protocol/)

#STATUS_FILE="/restic/status.info"
STATUS_FILE="./status.info"

MEASUREMENT_NAME="backup"
FIELD_KEY_STATUS="status"
FIELD_KEY_TIME="date"

# This will parse the status either based on the provided input or from the file
parse_status () {
    if [ ! -z $1 ] && [ ! -z $2 ]; then
        STATUS=$1
        DATE=$2
    else
        if [ -f $STATUS_FILE ]; then
            DATA=$(cut $STATUS_FILE -c $(( ${#MEASUREMENT_NAME}+2 ))- | tr "," "\n")
            for DATA_POINT in $DATA ; do
                if [[ $DATA_POINT == "$FIELD_KEY_STATUS="* ]]; then
                    STATUS=$(echo $DATA_POINT | cut -c $(( ${#FIELD_KEY_STATUS}+2 ))- | tr -d "\"")
                elif [[ $DATA_POINT == "$FIELD_KEY_TIME="* ]]; then
                    DATE=$(echo $DATA_POINT | cut -c $(( ${#FIELD_KEY_TIME}+2 ))-)
                fi
            done
        else
            STATUS="NO_STATUS"
            DATE=0
        fi
    fi

    declare -A STATUS_DICT
    # DATE stored as Milliseconds, but `date` can only format seconds
    PARSED_DATE=$(date -d@"$(( $DATE / 1000 ))")
    STATUS_DICT+=(
        ["NO_STATUS"]="No backup execution scheduled" 
        ["SCHEDULED"]="Backup execution scheduled, but not started" 
        ["BACKUP_STARTED"]="Backup creation started at ${PARSED_DATE}"
        ["BACKUP_SUCCESS"]="Backup creation successfully finished at ${PARSED_DATE}"
        ["BACKUP_FAILED"]="Backup creation failed at ${PARSED_DATE}"
        ["CLEANING_STARTED"]="Cleaning started at ${PARSED_DATE}"
        ["CLEANING_FAILED"]="Cleaning failed at ${PARSED_DATE}"
        ["SUCCESS"]="Backup finished at ${PARSED_DATE}"
    )
    echo ${STATUS_DICT[$STATUS]}
}

if [ -z $1 ] ; then
    BLUE='\033[0;34m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    UNDERLINE='\e[4m'
    STOP_UNDERLINE='\e[0m'
    STOP_COLOR='\033[0m'

    echo -e "${BLUE}#################${GREEN} Backup Status ${BLUE}###############################################"
    echo -e "${BLUE}###############################################################################"

    FILLER="                                                                        "
    STATUS="$(parse_status)"
    STATUS="${STATUS:0:72}${FILLER:0:$((72 - ${#STATUS}))}"

    echo -e "${BLUE}##  ${YELLOW}${STATUS}${BLUE} ##"
    echo -e "${BLUE}###############################################################################${STOP_COLOR}"
else
    #if [ "$1" = "SCHEDULED" ] && [ -f $STATUS_FILE ]; then
    #    echo "Not initializing status file, because it exists"

    STATUS=$1
    # Storing in Milliseconds (natively parsable DateTime for Grafana)
    DATE=$(( $(date +%s%N) / 1000000 ))
    echo "${MEASUREMENT_NAME} ${FIELD_KEY_STATUS}=\"${STATUS}\",${FIELD_KEY_TIME}=${DATE}" > $STATUS_FILE

    echo "###############################################################################"
    parse_status "$STATUS" "$DATE"
    echo "###############################################################################"
fi

