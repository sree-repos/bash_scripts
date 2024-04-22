#!/bin/sh
echo "Script Start-Time: $(date "+%d%m%Y %H:%M:%S")"

DATE=$(date +%d%m%Y_%H%M)
# cPanel account Folders
FOLDRS=('Site1' 'Site2' 'Site3')
 
for ACCS in "${FOLDRS[@]}"
do
   # Path variables
   ACC_FOLDR="$ACCS"
   CPAN_FOLDR="/home/sree"
   BKUP_FILE="$ACC_FOLDR$DATE.tar.gz"
   DEST_FOLDR="/root/backup_test/$ACC_FOLDR/$BKUP_FILE"

   # Backup cmd
   cd $CPAN_FOLDR/$ACC_FOLDR/
   tar -cvzf $DEST_FOLDR .
done
