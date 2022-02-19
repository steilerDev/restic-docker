# Docker Container for Restic
This docker container allows you to define a cron schedule to backup your files using [restic](https://github.com/restic/restic).

The current status of backup (date of last run) is printed when executing `docker exec <container-name> status` (e.g. as part of the `.bashrc` script).

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
  - `KEEP_YEARLY`
    For the last n years which have one or more snapshots, only keep the last one for that year
  - `KEEP_TAG`
    Keep all snapshots which have all tags specified by this option (can be specified multiple times)
  - `KEEP_WITHIN`
    Keep all snapshots which have been made within the `duration` of the latest snapshot. `duration` needs to be a number of years, months, days, and hours, e.g. `2y5m7d3h` will keep all snapshots made in the two years, five months, seven days, and three hours before the latest snapshot


## Volume Mounts
The following paths are recommended for persisting state and/or accessing configurations

 - `/backup/`  
    The source of the backup
 - `/restored/` (*recommended*)  
    The destination for restoring files

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
networks:
  default:
    external:
      name: steilerGroup
```