#!/bin/bash

###############################
# Cancel ALL CUPS print queues
###############################

JOBTMP="/tmp/lpstat_450_tmpjob"
LOGFILE="/var/log/print_queue_cleanup.log"
CURRENT_DATE=$(date "+%Y-%m-%d %T")
THRESHOLD=450

QUEUE_SIZE=$(/usr/bin/lpstat -o 2>/dev/null | wc -l)

if [ "$QUEUE_SIZE" -le "$THRESHOLD" ]; then
    echo "$CURRENT_DATE [INFO] Queue size $QUEUE_SIZE (<= $THRESHOLD) – No action required" >> $LOGFILE
    exit 0
elif [ "$QUEUE_SIZE" -gt "$THRESHOLD" ]; then	
    JOB_IDS=$(/usr/bin/lpstat -o 2>/dev/null | awk '{print $1}')	
    echo -e "$CURRENT_DATE [CRITICAL] Queue size $QUEUE_SIZE exceeded the threshold limit $THRESHOLD - Canceling print jobs" >> $LOGFILE
    /usr/bin/lpstat -o >> $JOBTMP
    cancel -a 2>/dev/null
    while read -r line; do
        JOB_ID=$(echo "$line" | awk '{print $1}')
        echo -e "$CURRENT_DATE [CANCELED] Job $JOB_ID canceled as the Queue size $QUEUE_SIZE exceeded the threshold limit $THRESHOLD " >> $LOGFILE
    done < "$JOBTMP"
    rm -rf $JOBTMP

    sendmail -t <<EOF
From: SysOps-Bot@$(hostname)
To: AppTeam@company.com, AppTeam-L2@company.com, operationssupport@company.com 
Subject: PrintQ :: $(hostname -s) : Printer Job Queue Size Alert
Hi Team,

The print queue size on $(hostname) has exceeded the configured threshold($THRESHOLD). As a result, the queued jobs were automatically canceled to prevent further impact.

Logs : $LOGFILE


Thanks,
SysOps-Bot
EOF
    QUEUE_SIZE=$(/usr/bin/lpstat -o 2>/dev/null | wc -l)
    echo "$CURRENT_DATE [INFO] Current Queue size: $QUEUE_SIZE, Cleanup completed – All print jobs are Cancelled" >> $LOGFILE  
fi

<<'LOGSAMPLES'
### Log Samples : 450_queue_cleanup.sh ###
2026-01-20 04:19:31 [CRITICAL] Queue size 73 exceeded the threshold limit 50 - Canceling print jobs
2026-01-20 04:19:31 [CANCELED] Job CEDPRT58-8821649 canceled as the Queue size 73 exceeded the threshold limit 50
2026-01-20 04:19:31 [CANCELED] Job CEDPRT58-8821651 canceled as the Queue size 73 exceeded the threshold limit 50
2026-01-20 04:19:31 [CANCELED] Job CEDPRT58-8821661 canceled as the Queue size 73 exceeded the threshold limit 50
2026-01-20 04:19:31 [CANCELED] Job CEDPRT58-8821666 canceled as the Queue size 73 exceeded the threshold limit 50
...
2026-01-20 04:19:31 [CANCELED] Job CEDPRT58-8822411 canceled as the Queue size 73 exceeded the threshold limit 50
2026-01-20 04:19:31 [INFO] Current Queue size: 0, Cleanup completed – All print jobs are Cancelled
LOGSAMPLES
