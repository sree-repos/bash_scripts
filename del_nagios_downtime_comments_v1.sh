#!/bin/bash

echo -e "\n Enter Downtime/Comment ID            :\n(Press ; to close the entry)"
read -d ';' d_ids

del_func () {
    for d_id in ${d_ids[@]}; do
        echo -e "$1 OPTION has been selected Down ID : $d_id " ; exit 0
#        printf "[%lu] %s;%s\n" "$(date +%s)" "$1" "$d_id" >> /usr/local/nagios/var/rw/nagios.cmd
    done
}

show_menu() {
    echo "=============================="
    echo " Delete DOWNTIME/ACKS in BULK"
    echo "=============================="
    echo "1) Delete Host Downtime"
    echo "2) Delete Service Downtime"
    echo "3) Delete Host Comment"
    echo "4) Delete Service Comment"
    echo "q) Quit"
    echo "------------------------------"
}

while true; do
    show_menu
    read -p "Enter your choice: " choice

    case "$choice" in
        1) del_func DEL_HOST_DOWNTIME ;;
        2) del_func DEL_SVC_DOWNTIME ;;
        3) del_func DEL_HOST_COMMENT ;;
        4) del_func DEL_SVC_COMMENT ;;
        q|Q) echo "Exiting..." ; exit 0 ;;
        *) echo "Invalid choice, try again." ;;
    esac

    echo -e "\nPress Enter to continue..."
    read  # pause before showing the menu again
done

##########################################################
del_host_downtime () {
    for d_id in ${d_ids[@]}; do
        echo -e "del_host_downtime OPTION has been selected Down ID : $d_id " ; exit 0
#        printf "[%lu] DEL_HOST_DOWNTIME;%s\n" "$(date +%s)" "$d_id" >> /usr/local/nagios/var/rw/nagios.cmd
    done
}
del_svc_downtime () {
    for d_id in ${d_ids[@]}; do
        echo -e "del_svc_downtime OPTION has been selected Down ID : $d_id " ; exit 0
#        printf "[%lu] DEL_SVC_DOWNTIME;%s\n" "$(date +%s)" "$d_id" >> /usr/local/nagios/var/rw/nagios.cmd
    done
}
del_host_comment () {
    for d_id in ${d_ids[@]}; do
        echo -e "del_host_comment OPTION has been selected Down ID : $d_id " ; exit 0
#        printf "[%lu] DEL_HOST_COMMENT;%s\n" "$(date +%s)" "$d_id" >> /usr/local/nagios/var/rw/nagios.cmd
    done
}
del_svc_comment () {
    for d_id in ${d_ids[@]}; do
        echo -e "del_svc_comment OPTION has been selected Down ID : $d_id " ; exit 0
#        printf "[%lu] DEL_SVC_COMMENT;%s\n" "$(date +%s)" "$d_id" >> /usr/local/nagios/var/rw/nagios.cmd
    done
}
