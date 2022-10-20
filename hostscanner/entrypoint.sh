#!/bin/bash
echo "docker container has been started"

echo "using Influx host ${DB_HOST:-localhost:8086} and databases $DB_NAMES"

CRON=${CRON:-* * * * *}

declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /var/tmp/container.env

touch /var/tmp/cron.log

echo "setting up cron $CRON"
mkdir -p /root/crontabs
echo "${CRON} /opt/hostscanner.sh >> /var/tmp/cron.log 2>&1
# This extra line makes it a valid cron" > /var/tmp/scheduler.txt
cp /var/tmp/scheduler.txt /root/crontabs/root

echo "starting cron"
crond -c /root/crontabs -L /var/tmp/crond.log && tail -f /var/tmp/cron.log

