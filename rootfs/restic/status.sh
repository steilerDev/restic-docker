#!/bin/bash

# Expecting first argument to be status value
# For valid values, see STATUS_DICT below
#
# If called without status value it will pritty print the status which is read from file
# Builds and exptects Influx Line Protocol (https://docs.influxdata.com/influxdb/latest/reference/syntax/line-protocol/)

STATUS_FILE="/restic/status.info"

MEASUREMENT_NAME="backup"
FIELD_KEY_STATUS="status"
FIELD_KEY_TIME="time"

parse_status () {
    if [ -z $STATUS ]; then
        if [ -f $STATUS_FILE ]; then
            # !!
            STATUS=$(cat $STATUS_FILE)
        else
            STATUS="NO_STATUS"
        fi
    fi

    if [ -z $DATE ]; then
        if [ -f $STATUS_FILE ]; then
            DATE=$(cat $STATUS_FILE)
        else
            DATE=0
        fi
    fi

    declare -A STATUS_DICT
    PARSED_DATE=$(date -d@"$(( $DATE / 1000000000 ))")
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

if [ -z $STATUS ] ; then
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
    if [ "$1" = "SCHEDULED"] && [ -f $STATUS_FILE ]; then
        echo "Not initializing status file, because it exists"
    else
        STATUS=$1
        DATE=$(date +%s%N)
        echo "${MEASUREMENT_NAME} ${FIELD_KEY_STATUS}=${STATUS},${FIELD_KEY_TIME}=${DATE}" > $STATUS_FILE

        echo "###############################################################################"
        parse_status
        #parse_status "$STATUS" "$DATE"
        echo "###############################################################################"
    fi
fi

