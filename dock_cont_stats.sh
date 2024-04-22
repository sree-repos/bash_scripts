#!/bin/bash

read -p "Enter Container ID/Name to SEARCH : " c_input
echo -e "\nHOSTNAME             CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT   MEM %               NET I/O             BLOCK I/O           PIDS"

for host in $(host -l .com | grep usprddockapp[01-100] | awk '{print $1}' | awk -F. '{print $1}')
do
   ssh -q $host docker ps -a | grep ${c_input} > /dev/null
   if [ $? -eq 0 ] ; then
      val=$(ssh -q $host docker stats ${c_input} --no-stream | tail -1)
      echo "$host      $val"
   fi
done

for host in $(host -l .com | grep inddockdockapp[01-100] | awk '{print $1}' | awk -F. '{print $1}')
do
   ssh -q $host docker ps -a | grep ${c_input} > /dev/null
   if [ $? -eq 0 ] ; then
      val=$(ssh -q $host docker stats ${c_input} --no-stream | tail -1)
      echo "$host      $val"
   fi
done
