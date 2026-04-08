#!/bin/bash

NAGIOS_CMD_FILE="/usr/local/nagios/var/rw/nagios.cmd"
STATUS_FILE="/usr/local/nagios/var/status.dat"
read -p "Enter Nagios Scheduled Downtime comment: " NAGIOS_COMMENT

# Check if $NAGIOS_COMMENT is provided
if [ -z "$NAGIOS_COMMENT" ]; then
    echo -e "Usage: $0 \nEnter Nagios Scheduled Downtime comment: <Nagios Downtime comment>"
    exit 1
fi

# Get the current timestamp
CURRENT_TIME=$(date +%s)

# Find all downtime IDs and service names with the specified Nagios comment
SERVICE_DOWNTIME_ENTRIES=$(awk -v comment="$NAGIOS_COMMENT" '
  BEGIN { RS = ""; FS = "\n" }
  /servicedowntime/ {
    for (i = 1; i <= NF; i++) {
      if ($i ~ /comment=/ && $i ~ comment) {
        downtime_id=""
        service_name=""
        for (j = i; j <= NF; j++) {
          if ($j ~ /downtime_id=/) {
            split($j, a, "=")
            downtime_id=a[2]
          }
          if ($j ~ /service_description=/) {
            split($j, b, "=")
            service_name=b[2]
          }
          if (downtime_id && service_name) {
            print downtime_id ";" service_name
            break
          }
        }
      }
    }
  }
' $STATUS_FILE)

# Find all host downtime IDs for the specified host itself
HOST_DOWNTIME_IDS=$(awk -v comment="$NAGIOS_COMMENT" '
  BEGIN { RS = ""; FS = "\n" }
  /hostdowntime/ {
    for (i = 1; i <= NF; i++) {
      if ($i ~ /comment=/ && $i ~ comment) {
        for (j = i; j <= NF; j++) {
          if ($j ~ /downtime_id=/) {
            split($j, a, "=")
            print a[2]
            break
          }
        }
      }
    }
  }
' $STATUS_FILE)

# Check if any downtime entries were found
if [ -z "$SERVICE_DOWNTIME_ENTRIES" ] && [ -z "$HOST_DOWNTIME_IDS" ]; then
  echo "No downtime entries found for the Nagios comment $NAGIOS_COMMENT"
  exit 1
fi

# Loop through each service downtime entry and construct the command to delete it
echo "$SERVICE_DOWNTIME_ENTRIES" | while IFS=";" read -r DOWNTIME_ID SERVICE_NAME; do
  COMMAND="[$CURRENT_TIME] DEL_SVC_DOWNTIME;$DOWNTIME_ID"
  # Append the command to the Nagios command file
#  echo "$COMMAND" >> $NAGIOS_CMD_FILE
  # Echo the service name
  echo "Downtime cleared for service: $SERVICE_NAME"
done

# Loop through each host downtime ID and construct the command to delete it
echo "$HOST_DOWNTIME_IDS" | while read -r DOWNTIME_ID; do
  COMMAND="[$CURRENT_TIME] DEL_HOST_DOWNTIME;$DOWNTIME_ID"
  # Append the command to the Nagios command file
#  echo "$COMMAND" >> $NAGIOS_CMD_FILE
  # Echo the host downtime cleared
  echo "Downtime cleared for the Nagios comment: $NAGIOS_COMMENT"
done

echo "Downtime cleared for the specified Nagios comment"
