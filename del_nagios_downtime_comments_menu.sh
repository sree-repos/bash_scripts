#!/bin/bash

clear
if [ "$(id -u)" -ne 0 ]; then
    echo -e "This script requires ROOT or SUDO permission \n"
    exit 1
fi

SCRIPT_PATH="/usr/local/nagios/var/rw/nagios_clear_downtime.sh"
while true; do
    echo "#################################################"
    echo "##### NAGIOS - BULK COMMENT DELETION SCRIPT #####"
    echo "################### Main Menu ###################"
    echo "Select a host:"
    echo "     1) HOST01"
    echo "     2) HOST02"
    echo "     3) HOST03"
    echo "     Q) Quit"
    echo -e "\nFYI: HOST04 (server04.cba.com) is in a different domain (CBA), So this script cannot reach it.
Kindly run the nagios_clear_downtime.sh script directly on the host.\n"
    read -n 1 -p "Enter your choice: " choice
    echo -e

    case "$choice" in
        1)
            echo -e "\n################ HOST01 ################"
            ssh -qt host01.abc.net "sh $SCRIPT_PATH"
            ;;
        2)
            echo -e "\n################ HOST02 ################"
            ssh -qt host02.abc.net "sh $SCRIPT_PATH"
            ;;
        3)
            echo -e "\n################ HOST03 ################"
            ssh -qt host03.abc.net "sh $SCRIPT_PATH"
            ;;
        q|Q)
            echo "Exiting."
            break
            ;;
        *)
            echo "Invalid choice. Please select 1–3 or Q."
            ;;
    esac

    echo -n
	read -p "Press Enter to return to The MAIN MENU [or] Ctrl + C to EXIT..."
    echo -e "\n"
done
