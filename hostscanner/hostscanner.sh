#!/bin/bash


# Set debug level
DEBUG=${DEBUG:-0}


# Set default values where necessary
DB_HOST=${DB_HOST:-localhost:8086}
DB_NAMES=${DB_NAMES:-telegraf}
DB_USER=${DB_USER:-user}                                                                        
DB_PASSWORD=${DB_PASSWORD:password}                                                             
MEASUREMENT=${MEASUREMENT:-hoststate}
STATE_FIELD=${STATE_FIELD:-state}


# Do hostscans for each of the databases listen in $DB_NAMES
for DB_NAME in $DB_NAMES; do


    # Set filenames to be used
    IP_FILE="/hostscanner/$DB_NAME.ip"
    XML_FILE="/hostscanner/$DB_NAME.xml"
    JSON_FILE="/hostscanner/$DB_NAME.json"


    # Execute nmap and convert output to JSON format (-v option necessary for offline host info)
    if [ $DEBUG -gt 2 ]; then 
        nmap -v -sn -R -oX $XML_FILE -iL $IP_FILE
        echo -e "\n"
    else
        nmap -v -sn -oX $XML_FILE -iL $IP_FILE > /dev/null
    fi
    python2 /opt/xml2json.py $XML_FILE > $JSON_FILE




    # Get statistics
    NR_HOSTS=$(jq -r '.nmaprun.runstats.hosts."@total"' $JSON_FILE)
    NR_UP=$(jq -r '.nmaprun.runstats.hosts."@up"' $JSON_FILE)
    NR_DOWN=$(jq -r '.nmaprun.runstats.hosts."@down"' $JSON_FILE)
    if [ $DEBUG -gt 0 ]; then
        echo -e "$(date -Iseconds) - $DB_NAME - $NR_HOSTS hosts; $NR_UP up, $NR_DOWN down"
    fi


    # Get status info for all hosts and send to Influx database
    MAX_HOSTS=$((NR_HOSTS-1))
    for i in $(seq 0 $MAX_HOSTS); do

        # Set params for JSON query
        if [ $NR_HOSTS = 1 ]; then
            HOSTFIELD="host"
        else
            HOSTFIELD="host[${i}]"
        fi

        TEMP=$(jq -r ".nmaprun.${HOSTFIELD}.hostnames.hostname" $JSON_FILE)
        if [ "${TEMP:0:1}" = "{" ]; then
            HOSTNAMEFIELD="hostname"
        else
            HOSTNAMEFIELD="hostname[0]"
        fi

        # Do JSON queries
        NAME=$(jq -r ".nmaprun.${HOSTFIELD}.hostnames.${HOSTNAMEFIELD}.\"@name\"" $JSON_FILE)
        ADDR=$(jq -r ".nmaprun.${HOSTFIELD}.address.\"@addr\"" $JSON_FILE)
        STATE_STR=$(jq -r ".nmaprun.${HOSTFIELD}.status.\"@state\"" $JSON_FILE)
        if [ $STATE_STR = "up" ]; then
            STATE=1
        else
            STATE=0
        fi
        if [ $DEBUG -gt 1 ]; then
            echo -e "\t$NAME\t$ADDR\t$STATE_STR"
        fi

        # Send update to Influx database
        MSG="$MEASUREMENT,host=$NAME,ip=$ADDR $STATE_FIELD=$STATE"
        if [ $DEBUG -gt 2 ]; then
            echo -e "\tmessage = $MSG"
        fi
        curl -u $DB_USER:$DB_PASSWORD -XPOST "http://$DB_HOST/write?db=$DB_NAME" --data-raw "$MSG" 2> /dev/null

    done


    if [ $DEBUG -gt 1 ]; then
        echo -e "\n"
    fi


done

