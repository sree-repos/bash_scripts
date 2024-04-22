#!/bin/sh
echo "Script Start-Time: $(date "+%d%m%Y %H:%M:%S")"

DATE=$(date +%d%m%Y_%H%M)
SOURCE_FOLDR="/home/sree/"
BKUP_FILE="SiteName$DATE.tar.gz"
DEST_FOLDR="/root/backup_test/$BKUP_FILE"

cd $SOURCE_FOLDR
tar -cvzf $DEST_FOLDR .
