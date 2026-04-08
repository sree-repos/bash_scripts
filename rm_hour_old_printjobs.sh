#!/bin/bash

#########################################
#Script to Purge Jobs Older than an HOUR#
#########################################

JOBTMP="/tmp/lpstat_tmpjob"
JOBLOG="/var/log/print_queue_cleanup.log"
CURRENT_DATE=$(date "+%Y-%m-%d %T")
CUR_TIME=$(date +%s)
THRESHOLD_MIN=60

/usr/bin/lpstat -o >> $JOBTMP

while read -r line; do
    JOB_ID=$(echo "$line" | awk '{print $1}')
    JOB_TIME=$(echo "$line" | awk '{print $4, $5, $6, $7, $8}')

    # Convert job time to Unix time
    JOB_UNIX_TIME=$(date -d "$JOB_TIME" +%s 2>/dev/null)
    [ -z "$JOB_UNIX_TIME" ] && continue
    DIFF_SEC=$(( CUR_TIME - JOB_UNIX_TIME ))
    DIFF_MIN=$(( DIFF_SEC / 60 ))

    if [ "$DIFF_MIN" -gt "$THRESHOLD_MIN" ]; then
        cancel "$JOB_ID" && echo -e "$CURRENT_DATE [CANCELED] Job $JOB_ID canceled after $DIFF_MIN minutes in the Print Queue." >> "$JOBLOG"
#        echo -e "$CURRENT_DATE [CANCELED] Job $JOB_ID canceled after $DIFF_MIN minutes in the Print Queue." >> "$JOBLOG"
#        echo -e "$CURRENT_DATE [CANCELED] Job $JOB_ID canceled after $DIFF_MIN minutes in the Print Queue."
    fi

done < "$JOBTMP"
rm -rf $JOBTMP

<<'LOGSAMPLES'
### Log Samples : remove_1hr_old_print_jobs.sh ###
2026-01-16 15:30:08 [CANCELED] Job CEDPRT10-9092291 canceled after 3159 minutes in the Print Queue.
2026-01-16 15:30:08 [CANCELED] Job CEDPRT10-9092370 canceled after 3125 minutes in the Print Queue.
2026-01-16 15:30:08 [CANCELED] Job CEDPRT10-9092372 canceled after 3124 minutes in the Print Queue.
2026-01-16 15:30:08 [CANCELED] Job CEDPRT10-9092386 canceled after 3121 minutes in the Print Queue.
LOGSAMPLES
