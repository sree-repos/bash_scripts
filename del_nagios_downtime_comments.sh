#!/bin/bash

NAGIOS_CMD_FILE="/usr/local/nagios/var/rw/nagios.cmd"
STATUS_FILE="/usr/local/nagios/var/status.dat"
read -p "Enter Nagios Scheduled Downtime comment (case-sensitive): " NAGIOS_COMMENT
CURRENT_TIME=$(date +%s)

# Check if $NAGIOS_COMMENT is provided
if [ -z "$NAGIOS_COMMENT" ]; then
    echo -e "Usage: sh $0 \n" 
    printf '%*s\n' 50 '' | tr ' ' '-'
    echo -e "Enter Nagios Scheduled Downtime comment (case-sensitive): <Nagios Downtime comment> \n"
    exit 1
fi

# Finds ServiceDowntime IDs for the specified Nagios comment
SERVICE_DOWNTIME_ENTRIES=$(awk -v nag_comment="$NAGIOS_COMMENT" '
    BEGIN { RS="}"; FS="\n" }
    /servicedowntime/ {
        downtime_id= ""; service_name= ""; matched = 0;
        for (i=1; i<=NF; i++) {
            if ($i ~ "comment=" && $i ~ nag_comment) matched = 1;
            if ($i ~ "downtime_id=") { split($i, a, "="); downtime_id=a[2]; }
            if ($i ~ "host_name=") { split($i, b, "="); host_name=b[2]; }
            if ($i ~ "service_description=") { split($i, c, "="); service_name=c[2]; }
        }
        if (matched && downtime_id && service_name)
            print downtime_id ";" host_name ";" service_name;
    }' $STATUS_FILE)

# Finds HostDowntime IDs for the specified Nagios comment
HOST_DOWNTIME_IDS=$(awk -v nag_comment="$NAGIOS_COMMENT" '
    BEGIN { RS = "}"; FS="\n" }
    /hostdowntime/ {
        downtime_id= ""; matched = 0;  
        for (i = 1; i<=NF; i++) {
            if ($i ~ "comment=" && $i ~ nag_comment) matched = 1;
            if ($i ~ "downtime_id=") { split($i, a, "="); downtime_id=a[2]; }
            if ($i ~ "host_name=") { split($i, b, "="); host_name=b[2]; }
        }
        if (matched && downtime_id)
            print downtime_id ";" host_name;
    }' $STATUS_FILE)

# Check if any downtime entries were found
if [ -z "$SERVICE_DOWNTIME_ENTRIES" ] && [ -z "$HOST_DOWNTIME_IDS" ]; then
    echo -e "No downtime entries found for the Nagios comment: $NAGIOS_COMMENT \n"
    exit 1
fi

# Clears Service Downtime
if [ -n "$SERVICE_DOWNTIME_ENTRIES" ]; then
    echo -e "\nFound Service Downtime entries for comment: \"$NAGIOS_COMMENT\""
    echo "$SERVICE_DOWNTIME_ENTRIES" | while IFS=";" read -r DOWNTIME_ID HOST_NAME SERVICE_NAME; do
        COMMAND="[$CURRENT_TIME] DEL_SVC_DOWNTIME;$DOWNTIME_ID"
        echo "$COMMAND" >> "$NAGIOS_CMD_FILE"
        echo "Deleting Service Downtime ID: $DOWNTIME_ID ($HOST_NAME: $SERVICE_NAME)"
    done
    echo
fi
if [ -z "$SERVICE_DOWNTIME_ENTRIES" ] ; then
    echo -e "No Service Downtime entries found for the Nagios comment: $NAGIOS_COMMENT \n"
fi   

# Clears Host Downtime
if [ -n "$HOST_DOWNTIME_IDS" ]; then
    echo "Found Host Downtime entries for comment: \"$NAGIOS_COMMENT\""
    echo "$HOST_DOWNTIME_IDS" | while IFS=";" read -r DOWNTIME_ID HOST_NAME; do
        COMMAND="[$CURRENT_TIME] DEL_HOST_DOWNTIME;$DOWNTIME_ID"
        echo "$COMMAND" >> "$NAGIOS_CMD_FILE"
        echo -e "Deleting Host Downtime ID: $DOWNTIME_ID ($HOST_NAME)"
    done
    echo
fi
if [ -z "$HOST_DOWNTIME_IDS" ] ; then
    echo -e "No Host downtime entries found for the Nagios comment: $NAGIOS_COMMENT \n"
fi 

echo -e "Downtime cleared for the specified Nagios comment: \"$NAGIOS_COMMENT\""
echo -e "Note: Give it a few seconds for the changes to reflect in the Nagios XI dashboard.\n"
