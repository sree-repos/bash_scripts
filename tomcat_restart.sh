#!/bin/bash
echo -e "\nEnter Host Names              :
(Press ; to close the entry) "
read -d ';' h_name

## Parallel control variables  
MAX_JOBS=4
count=0

for host in ${h_name[@]}; do
   ((count++))
   ## Background job execution block
   {
       if [ $? -eq 0 ] ; then          # $? refers to previous command’s exit status
          ssh -q $host "hostname; service tomcat status; service tomcat restart"
          #ssh -q $host "hostname; service tomcat restart"
          #ssh -q $host "service tomcat restart cheprd01_services avail_01"
          #ssh -q $host "hostname; service tomcat status | grep ptfrpt; ps -ef | grep ptfrpt | grep -v root ";
          echo -e "\n "
       fi
   } &

   ## Job throttling
   if (( count % MAX_JOBS == 0 )); then
      wait
   fi

done
wait
echo "All jobs completed."
