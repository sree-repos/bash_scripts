#!/bin/bash

tomcat_restart(){
   echo -e "\nOPTION [${yourchoice}] RESTART ALL TOMCAT SERVICE/INSTANCE"
   echo -e "----------------------------------------------"
   echo -e "CAUTION : This will Restart whole Tomcat service or All Tomcat Instances in a Host

Note:
  <ENTER>   Seaparate Multiple Host names with NEW LINE by 'Pressing ENTER'
<Ctrl + D>  Press 'Ctrl+D' in New Line To close the Input Entry
            at <HOSTNAME> field
<Ctrl + C>  To Quit from the script\n"

   echo -e "Enter Hostname : " ; readarray -t hosts
#   read -p "Enter Hostname: " -d ';' hosts
   if [[ -z "$hosts" ]]; then
      echo "Error: <HOST_NAME> field is empty."
      exit 1
   fi
   for host in ${hosts[@]}; do
      echo -e "\nHostname: ${host}"
      ssh -q $host "service tomcat restart"
   done
}

tomcat_instance_restart(){
   echo -e "\nOPTION [${yourchoice}] MENTIONED TOMCAT SERVICE/INSTANCE RESTART"
   echo -e "----------------------------------------------------"
   echo -e "Tis is used to Restart Tomcat Instances in Multiple [or] Single host
Things needed: Tomcat <DOMAIN_NAME> <INSTANCE_NAME> ; <HOSTNAME>
}
Note:
  <ENTER>   Seaparate Multiple INSTANCE/HOST names with NEW LINE by 'Pressing ENTER'
<Ctrl + D>  Press 'Ctrl+D' in New Line To close the Input Entry
            at <DOMAIN_NAME> <INSTANCE_NAME> / <HOSTNAME> fields
<Ctrl + C>  To Quit from the script\n"

   echo -e "Enter Tomcat <DOMAIN_NAME> <INSTANCE_NAME> : "
   readarray -t tomcat_instances

   if [[ -z "$tomcat_instances" ]]; then
       echo "Error: <TOMCAT_INSTANCES> field are empty."
       exit 1
   fi

   echo -e "\nEnter Hostname : " ; readarray -t hosts
   if [[ -z "$hosts" ]]; then
      echo "Error: <HOST_NAME> field is empty."
      exit 1
   fi

   for host in ${hosts[@]}; do
      echo -e "\nHostname : ${host}"
      for ((i=0; i<${#tomcat_instances[@]}; i++)) ; do
         # Split the line into two elements
         line=(${tomcat_instances[i]})
         domain=${line[0]}
         instance=${line[1]}
         echo -e "Tomcat Service : ${domain} ${instance}"
         ssh -q $host "service tomcat restart ${domain} ${instance}"
      done
   done
#   echo -e "\n\n Press a key. . .:"; read
}

tomcat_status(){
   echo -e "\nOPTION [${yourchoice}] TOMCAT STATUS CHECK"
   echo -e "----------------------------------"
   echo -e "This is used to check the Tomcat Status in Single [or] Multiple Host

Note:
  <ENTER>   For Multiple Host names seaperate them with NEW LINE by 'Pressing ENTER'
<Ctrl + D>  Press 'Ctrl+D' in New Line To close the Input Entry
            at <HOSTNAME> field
<Ctrl + C>  To Quit from the script\n"

   echo -e "Enter Hostname : " ; readarray -t hosts
#   read -p "Enter Hostname: " -d ';' hosts
   if [[ -z "$hosts" ]]; then
      echo "Error: <HOST_NAME> field is empty."
      exit 1
   fi
   for host in ${hosts[@]}; do
      echo -e "\nHostname: ${host}"
      ssh -q $host "service tomcat status"
   done
}

tomcat_instance_restart_v1(){
   clear
   echo -e "Restart Tomcat Instances in Multiple [or] Single host
Things needed: Tomcat <DOMAIN_NAME> <INSTANCE_NAME> ; <HOSTNAME>

Note: To enter multiple Tomcat-Instance, Hostnames in single run
<ENTER>   To Input multiple <INSTANCE_NAME> / <HOSTNAME> Seaparate them with new line
  <;>     To close the Entry of <INSTANCE_NAME> / <HOSTNAME> \n"
#   while :
#   do
      read -p "Enter Tomcat Domain_name: " domain
      read -p "Enter Tomcat Instance_name: " -d ';' instances ; echo -e "\n"

      if [[ -z "$domain" || -z "$instances" ]]; then
          echo "Error: <DOMAIN_NAME> or <INSTANCE_NAME> are empty."
          exit 1
      fi

      read -p "Enter Hostname: " -d ';' hosts ; echo -e "\n"
      if [[ -z "$hosts" ]]; then
         echo "Error: <HOST_NAME> is empty."
         exit 1
      fi

      for host in ${hosts[@]}; do
         echo -e "\nHostname: ${host}"
         for instance in ${instances[@]} ; do
            echo -e "Tomcat : ${domain} ${instance}"
#            ssh -q $host "service tomcat restart ${domain} ${instance}"
         done
      done
#      echo -e "\n Press a key. . .:"; read
#   done
}

while :
do
   clear
   echo "------------------------------------------------"
   echo "TOMCAT ACTION MAIN MENU"
   echo "------------------------------------------------"
   echo "[1] Restart All Tomcat Service/Instances in Host"
   echo "[2] Restart mentioned Tomcat Service/Instances in Host"
   echo "[3] Check the Tomcat Status in the Host"
   echo "[0] Exit"
   echo "================================================"
   echo -n "Enter your choice [0-3]: "
   read yourchoice
   case $yourchoice in
      1) tomcat_restart ; read;;
      2) tomcat_instance_restart ; read ;;
      3) tomcat_status ; read ;;
      0) exit 0 ;;
      *) echo "INVALID INPUT" ; sleep 4 ;;
    esac
done
