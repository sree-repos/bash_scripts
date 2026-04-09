#!/bin/bash
echo -e "\nEnter Host Names              :
(Press ; to close the entry) "
read -d ';' h_name

# Simple For loop to check Tomcat status
for host in ${h_name[@]}; do
    ssh -q $host "hostname; uptime;service tomcat status"
    #ssh -q $host "ps -ef | grep cheprd01_services"
    echo -e "\n "
done
