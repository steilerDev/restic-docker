# DEPRECATED

This repository has been deprecated in favor of [mazzolino/restic](https://github.com/djmaze/resticker). The following configuration is able to enable equal functionality with this project:

```
services:
  backup:
    image: mazzolino/restic:1.7.2
    container_name: backup
    restart: unless-stopped
    hostname: "***"
    volumes:
      - type: bind
        source: /home
        target: /backup/home
        read_only: true
      - type: bind
        source: /opt/steilerGroup-Docker/volumes/backup/pre-run.d
        target: /pre-run.d
      - type: bind
        source: /opt/steilerGroup-Docker/volumes/backup/status.info
        target: /status.info
    environment:
      BACKUP_CRON: "0 20 3 * * 1,4"
      RESTIC_REPOSITORY: b2:***
      RESTIC_PASSWORD: ***
      RESTIC_BACKUP_SOURCES: /backup
      RESTIC_BACKUP_ARGS: >-
        --compression max
      RESTIC_FORGET_ARGS: >-
        --keep-weekly 5
        --keep-monthly 12
        --keep-yearly 5
      SUCCESS_ON_INCOMPLETE_BACKUP: true
      PRE_COMMANDS: |-
        run-parts --exit-on-error /pre-run.d
      POST_COMMANDS_SUCCESS: >
        echo "backup status=\"BACKUP_SUCCESS\",date=$(( $(date +%s%N) * 1000 ))" > /status.info
      POST_COMMANDS_FAILURE: >
        echo "backup status=\"BACKUP_FAILED\",date=$(( $(date +%s%N) * 1000 ))" > /status.info
      POST_COMMANDS_INCOMPLETE: >
        echo "backup status=\"BACKUP_INCOMPLETE\",date=$(( $(date +%s%N) * 1000 ))" > /status.info
      B2_ACCOUNT_ID: ***
      B2_ACCOUNT_KEY: ***
      TZ: Europe/Berlin
    labels:
      - wud.link.template=https://github.com/djmaze/resticker/releases/tag/$${raw}
      - wud.tag.include=^\d+\.\d+\.\d+$$
      - wud.display.icon=si:backblaze
      - wud.display.name=backup-ns1
  prune:
    image: mazzolino/restic:1.7.2
    container_name: backup_prune
    restart: unless-stopped
    hostname: "***"
    volumes:
      - type: bind
        source: /opt/steilerGroup-Docker/volumes/backup/status.info
        target: /status.info
    environment:
      SKIP_INIT: "true"
      PRUNE_CRON: "0 20 3 * * 2,5"
      RESTIC_REPOSITORY: b2:***
      RESTIC_PASSWORD: ***
      POST_COMMANDS_SUCCESS: >
        echo "backup status=\"PRUNE_SUCCESS\",date=$(( $(date +%s%N) * 1000 ))" > /status.info
      POST_COMMANDS_FAILURE: >
        echo "backup status=\"PRUNE_FAILED\",date=$(( $(date +%s%N) * 1000 ))" > /status.info
      B2_ACCOUNT_ID: ***
      B2_ACCOUNT_KEY: ***
      TZ: Europe/Berlin
    labels:
      - wud.link.template=https://github.com/djmaze/resticker/releases/tag/$${raw}
      - wud.tag.include=^\d+\.\d+\.\d+$$
      - wud.display.icon=si:backblaze
      - wud.display.name=backup_prune-ns1
  check:
    image: mazzolino/restic:1.7.2
    container_name: backup_check
    restart: unless-stopped
    hostname: "***"
    volumes:
      - type: bind
        source: /opt/steilerGroup-Docker/volumes/backup/status.info
        target: /status.info
    environment:
      SKIP_INIT: "true"
      CHECK_CRON: "0 20 3 * * 3"
      RESTIC_CHECK_ARGS: >
        --read-data-subset=10%
      RESTIC_REPOSITORY: b2:***
      RESTIC_PASSWORD: ***
      POST_COMMANDS_SUCCESS: >
        echo "backup status=\"CHECK_SUCCESS\",date=$(( $(date +%s%N) * 1000 ))" > /status.info
      POST_COMMANDS_FAILURE: >
        echo "backup status=\"CHECK_FAILED\",date=$(( $(date +%s%N) * 1000 ))" > /status.info
      B2_ACCOUNT_ID: ***
      B2_ACCOUNT_KEY: ***
      TZ: Europe/Berlin
    labels:
      - wud.link.template=https://github.com/djmaze/resticker/releases/tag/$${raw}
      - wud.tag.include=^\d+\.\d+\.\d+$$
      - wud.display.icon=si:backblaze
      - wud.display.name=backup_check-ns1
```

# Docker Container for Restic
This docker container allows you to define a cron schedule to backup your files using [restic](https://github.com/restic/restic).

The current status of backup (date of last run) is (pretty) printed when executing `docker exec <container-name> status` (e.g. as part of the `.bashrc` script).

The backup status is stored as [Influx Line Protocol](https://docs.influxdata.com/influxdb/latest/reference/syntax/line-protocol/) in `/restic/status.info` and can be used to monitor the backup status. Find possible values in the (`status.sh`)[https://github.com/steilerDev/restic-docker/blob/main/rootfs/restic/status.sh] script.

# Configuration options
When running the docker, setting the hostname is recommended (see example below).

## Environment Variables
This only lists the most important and docker specific environmental variables. Restic specific variables can be found in the [restic documentation](https://restic.readthedocs.io/en/stable/manual_rest.html).

  - `CRON_SCHEDULE`  
    The [cron schedule](https://crontab.guru) for performing the backup
  - `RESTIC_REPOSITORY`  
    The location of the repository
  - `RESTIC_PASSWORD`  
    The password for the restic repository
  - `KEEP_LAST`  
    Never delete the n last (most recent) snapshots
  - `KEEP_HOURLY`  
    For the last n hours in which a snapshot was made, keep only the last snapshot for each hour
  - `KEEP_DAILY`  
    For the last n days which have one or more snapshots, only keep the last one for that day
  - `KEEP_WEEKLY`  
    For the last n weeks which have one or more snapshots, only keep the last one for that week
  - `KEEP_MONTHLY`  
    For the last n months which have one or more snapshots, only keep the last one for that month
  - `KEEP_YEARLY` . 
    For the last n years which have one or more snapshots, only keep the last one for that year
  - `KEEP_TAG`  
    Keep all snapshots which have all tags specified by this option (can be specified multiple times)
  - `KEEP_WITHIN`  
    Keep all snapshots which have been made within the `duration` of the latest snapshot. `duration` needs to be a number of years, months, days, and hours, e.g. `2y5m7d3h` will keep all snapshots made in the two years, five months, seven days, and three hours before the latest snapshot
  - `TZ`  
    Timezone of installation for precise backup execution (Defaults to `Europe/Berlin`)


## Volume Mounts
The following paths are recommended for persisting state and/or accessing configurations

 - `/backup/`  
    The source of the backup
 - `/restored/` (*recommended*)  
    The destination for restoring files
 - `/restic/status.info` (*optional*)  
    Read the current backup status from this file
 - `/pre-run.d` (*optional*)
    This tool will use `run-parts` to execute the content of this dir before a backup (if it exists)

# docker-compose example
Usage with `nginx-proxy` inside of predefined `steilerGroup` network.

```
version: '2'
services:
  <service-name>:
    image: steilerdev/restic:latest
    container_name: backup
    restart: unless-stopped
    hostname: "<hostname>"
    environment:
      CRON_SCHEDULE: "0 4 * * 0,3"
      RESTIC_REPOSITORY: "b2:<bucket-name>:<folder-name>/"
      RESTIC_PASSWORD: "<pwd>"
      RESTIC_COMPRESSION: "max"
      B2_ACCOUNT_ID: "<account-id>"
      B2_ACCOUNT_KEY: "<account-key"
      KEEP_DAILY: "7"
      KEEP_WEEKLY: "5"
      KEEP_MONTHLY: "12"
      KEEP_YEARLY: "5"
    volumes:
      - /opt:/backup/opt:ro
      - /root:/backup/root:ro
      - /home:/backup/home:ro
      - /media/files/_restored:/restored
      - /opt/docker/backup/volumes/status.info:/restic/status.info
networks:
  default:
    name: steilerGroup
    external: true
```