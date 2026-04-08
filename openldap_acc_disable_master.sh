#!/bin/bash
### Note : pwdAccountLockedTime section has been commented out because
### ldap_modify: pwdAccountLockedTime, nsAccountLock attributes are Undefined type (17)
### in the Host02 & Host03 servers.

clear
CURRENT_DATE=$(date "+%Y-%m-%d %T")
LDAP_HOST1="host01.abc.net"
LDAP_HOST2="host02.abc.net"
LDAP_HOST3="host03.abc.net"
BASE_DN="dc=abc,dc=net"
BIND_DN="cn=Manager,dc=abc,dc=net"
LOGFILE="/scripts/ldap/disable_acc/disable_acc_master.log"
PARSED_FILE1="/scripts/ldap/disable_acc/host01_ldap_parsed.txt"
PARSED_FILE2="/scripts/ldap/disable_acc/host02_ldap_parsed.txt"
PARSED_FILE3="/scripts/ldap/disable_acc/host03_ldap_parsed.txt"
USERS_FILE="/scripts/ldap/disable_acc/users.txt"

printf -- '#%.0s' {1..50};echo -e "";echo -e "       DAILY ACOOUNT REMOVAL - MASTER SCRIPT       ";printf -- '#%.0s' {1..50};echo -e ""
echo -e "\nEnter LDAP Manager Password\nUser : Manager"
read -s -p "Pass : " PASS

## Verifies LDAP Manager credential are correct
if ldapsearch -x -h host01.abc.net -p 10389 -D "cn=Manager,dc=gspt,dc=net" -w $PASS -b "dc=abc,dc=net" -s base >/dev/null 2>&1 ; then
    echo -e "\nManager LDAP authentication successful"
else
    echo -e "\nManager LDAP authentication failed"
    exit 1
fi

## Processing UIDs
echo -e "\n\nEnter all the sAMAccountName values one per line.
Press ; to close the entry    :"
read -d ';' USERS
printf "%s\n" $USERS > "$USERS_FILE"
echo -e "\n"
#printf -- '-%.0s' {1..50};echo -e "\n"

FILTER="(|"
while IFS= read -r u; do
    FILTER="${FILTER}(uid=$u)"
done < "$USERS_FILE"
FILTER="${FILTER})"

##########################################################################
printf -- '#%.0s' {1..69};
echo -e "\nChecking if the sAMAccounts have matching LDAP UIDs in HOST01..."
## Single ldapsearch to get all User info
RESULT1=$(ldapsearch -x -LLL -h "$LDAP_HOST1" -D "$BIND_DN" -w "$PASS" \
    -b "$BASE_DN" "$FILTER" dn uid pwdAccountLockedTime 2>/dev/null)

echo "$RESULT1" | awk '
BEGIN { RS=""; FS="\n" }
{
    dn=""; uid=""; lock=""
    for (i=1; i<=NF; i++) {
        if ($i ~ /^dn:/) {
            sub(/^dn: /, "", $i)
            dn=$i
        } else if ($i ~ /^uid:/) {
            sub(/^uid: /, "", $i)
            uid=$i
        } else if ($i ~ /^pwdAccountLockedTime:/) {
            sub(/^pwdAccountLockedTime: /, "", $i)
            lock=$i
        }
    }
    if (uid && dn) {
        print uid "|" dn "|" lock
    }
}' > "$PARSED_FILE1"
#cat -n "$PARSED_FILE1"

while IFS= read -r USER; do
    ENTRY=$(grep -m1 "^${USER}|" "$PARSED_FILE1")

    if [ -z "$ENTRY" ]; then
        echo "$CURRENT_DATE $LDAP_HOST1 - USER:$USER NOT_FOUND" | tee -a "$LOGFILE"
        continue
    fi

    DN=$(echo "$ENTRY" | cut -d'|' -f2)
    LOCK=$(echo "$ENTRY" | cut -d'|' -f3 | xargs)
    echo "$CURRENT_DATE $LDAP_HOST1 - USER:$USER FOUND" | tee -a "$LOGFILE"

    ## Change password
    ldapmodify -x -h "$LDAP_HOST1" -D "$BIND_DN" -w "$PASS" <<EOF
dn: $DN
changetype: modify
replace: userPassword
userPassword: {SSHA}*LK*9sar1NJ4ckvbIho1cvsFx3YhLzWCioNB
EOF
    echo "$CURRENT_DATE $LDAP_HOST1 - USER:$USER PASSWORD_CHANGED" | tee -a "$LOGFILE"
    
    ## Re-check lock status AFTER password change
    LOCK=$(ldapsearch -x -LLL -h "$LDAP_HOST1" -D "$BIND_DN" -w "$PASS" \
        -b "$BASE_DN" "(uid=$USER)" pwdAccountLockedTime 2>/dev/null |
        awk '/^pwdAccountLockedTime:/ {print $2}' | xargs)
    
    #echo "DEBUG AFTER PASSWORD CHANGE: USER=[$USER] LOCK=[$LOCK]"
    
    if [[ "$LOCK" =~ [0-9] ]]; then
        #echo "$CURRENT_DATE $LDAP_HOST1 - USER:$USER ALREADY_LOCKED"
        echo "$CURRENT_DATE $LDAP_HOST1 - USER:$USER ALREADY_LOCKED" | tee -a "$LOGFILE"
    elif [[ -z "$LOCK" ]]; then
        ldapmodify -x -h "$LDAP_HOST1" -D "$BIND_DN" -w "$PASS" <<EOF
dn: $DN
changetype: modify
add: pwdAccountLockedTime
pwdAccountLockedTime: 000001010000Z
EOF

        #echo "$CURRENT_DATE $LDAP_HOST1 - USER:$USER ACCOUNT_LOCKED"
        echo "$CURRENT_DATE $LDAP_HOST1 - USER:$USER ACCOUNT_LOCKED" | tee -a "$LOGFILE"
    fi

done < "$USERS_FILE"

##############################################################################
printf -- '#%.0s' {1..75}
echo -e "\nChecking if the sAMAccounts have matching LDAP UIDs in HOST02..."
## Single ldapsearch to get all User info
RESULT2=$(ldapsearch -x -LLL -H ldap://$LDAP_HOST2:10389 -D "$BIND_DN" -w "$PASS" \
    -b "$BASE_DN" "$FILTER" dn uid pwdAccountLockedTime 2>/dev/null)

echo "$RESULT2" | awk '
BEGIN { RS=""; FS="\n" }
{
    dn=""; uid=""; lock=""
    for (i=1; i<=NF; i++) {
        if ($i ~ /^dn:/) {
            sub(/^dn: /, "", $i)
            dn=$i
        } else if ($i ~ /^uid:/) {
            sub(/^uid: /, "", $i)
            uid=$i
        } else if ($i ~ /^pwdAccountLockedTime:/) {
            sub(/^pwdAccountLockedTime: /, "", $i)
            lock=$i
        }
    }
    if (uid && dn) {
        print uid "|" dn "|" lock
    }
}' > "$PARSED_FILE2"
#cat -n "$PARSED_FILE2"

while IFS= read -r USER; do
    ENTRY=$(grep -m1 "^${USER}|" "$PARSED_FILE2")

    if [ -z "$ENTRY" ]; then
        echo "$CURRENT_DATE $LDAP_HOST2 - USER:$USER NOT_FOUND" | tee -a "$LOGFILE"
        continue
    fi

    DN=$(echo "$ENTRY" | cut -d'|' -f2)
    LOCK=$(echo "$ENTRY" | cut -d'|' -f3 | xargs)

    #echo "DEBUG: USER=[$USER] LOCK=[$LOCK]"

    #echo "$CURRENT_DATE $LDAP_HOST2 - USER:$USER FOUND"
    echo "$CURRENT_DATE $LDAP_HOST2 - USER:$USER FOUND" | tee -a "$LOGFILE"

    ## Change password
    ldapmodify -x -H ldap://$LDAP_HOST2:10389 -D "$BIND_DN" -w "$PASS" <<EOF
dn: $DN
changetype: modify
replace: userPassword
userPassword: {SSHA}*LK*9sar1NJ4ckvbIho1cvsFx3YhLzWCioNB
EOF
    #echo "$CURRENT_DATE $LDAP_HOST2 - USER:$USER PASSWORD_CHANGED
    echo "$CURRENT_DATE $LDAP_HOST2 - USER:$USER PASSWORD_CHANGED" | tee -a "$LOGFILE"

<<'COMMENT'    
    ## Re-check lock status AFTER password change
    LOCK=$(ldapsearch -x -LLL -H ldap://$LDAP_HOST2:10389 -D "$BIND_DN" -w "$PASS" \
        -b "$BASE_DN" "(uid=$USER)" pwdAccountLockedTime 2>/dev/null |
        awk '/^pwdAccountLockedTime:/ {print $2}' | xargs)
    
    #echo "DEBUG AFTER PASSWORD CHANGE: USER=[$USER] LOCK=[$LOCK]"
    
    if [[ "$LOCK" =~ [0-9] ]]; then
        #echo "$CURRENT_DATE $LDAP_HOST2 - USER:$USER ALREADY_LOCKED"
        echo "$CURRENT_DATE $LDAP_HOST2 - USER:$USER ALREADY_LOCKED" | tee -a "$LOGFILE"
    elif [[ -z "$LOCK" ]]; then
        ldapmodify -x -H ldap://$LDAP_HOST2:10389 -D "$BIND_DN" -w "$PASS" <<EOF
dn: $DN
changetype: modify
add: pwdAccountLockedTime
pwdAccountLockedTime: 000001010000Z
EOF

        #echo "$CURRENT_DATE $LDAP_HOST2 - USER:$USER ACCOUNT_LOCKED"
        echo "$CURRENT_DATE $LDAP_HOST2 - USER:$USER ACCOUNT_LOCKED" | tee -a "$LOGFILE"
    fi
COMMENT

done < "$USERS_FILE"

##############################################################################
printf -- '#%.0s' {1..73}
echo -e "\nChecking if the sAMAccounts have matching LDAP UIDs in HOST03..."
## Single ldapsearch to get all User info
RESULT=$(ldapsearch -x -LLL -h "$LDAP_HOST3" -p 10389 -D "$BIND_DN" -w "$PASS" \
    -b "$BASE_DN" "$FILTER" dn uid pwdAccountLockedTime 2>/dev/null)

echo "$RESULT3" | awk '
BEGIN { RS=""; FS="\n" }
{
    dn=""; uid=""; lock=""
    for (i=1; i<=NF; i++) {
        if ($i ~ /^dn:/) {
            sub(/^dn: /, "", $i)
            dn=$i
        } else if ($i ~ /^uid:/) {
            sub(/^uid: /, "", $i)
            uid=$i
        } else if ($i ~ /^pwdAccountLockedTime:/) {
            sub(/^pwdAccountLockedTime: /, "", $i)
            lock=$i
        }
    }
    if (uid && dn) {
        print uid "|" dn "|" lock
    }
}' > "$PARSED_FILE3"
#cat -n "$PARSED_FILE3"

while IFS= read -r USER; do
    ENTRY=$(grep -m1 "^${USER}|" "$PARSED_FILE3")

    if [ -z "$ENTRY" ]; then
        echo "$CURRENT_DATE $LDAP_HOST3 - USER:$USER NOT_FOUND" | tee -a "$LOGFILE"
        continue
    fi

    DN=$(echo "$ENTRY" | cut -d'|' -f2)
    LOCK=$(echo "$ENTRY" | cut -d'|' -f3 | xargs)

    #echo "DEBUG: USER=[$USER] LOCK=[$LOCK]"
    #echo "$CURRENT_DATE $LDAP_HOST3 - USER:$USER FOUND"
    echo "$CURRENT_DATE $LDAP_HOST3 - USER:$USER FOUND" | tee -a "$LOGFILE"

    ## Change password
    ldapmodify -x -h "$LDAP_HOST3" -p 10389 -D "$BIND_DN" -w "$PASS" <<EOF
dn: $DN
changetype: modify
replace: userPassword
userPassword: {SSHA}*LK*9sar1NJ4ckvbIho1cvsFx3YhLzWCioNB
EOF
    
    echo "$CURRENT_DATE $LDAP_HOST3 - USER:$USER PASSWORD_CHANGED" | tee -a "$LOGFILE"

<<'COMMENT'    
    ## Re-check lock status AFTER password change
    LOCK=$(ldapsearch -x -LLL -h "$LDAP_HOST3" -p 10389 -D "$BIND_DN" -w "$PASS" \
        -b "$BASE_DN" "(uid=$USER)" pwdAccountLockedTime 2>/dev/null |
        awk '/^pwdAccountLockedTime:/ {print $2}' | xargs)
    
    #echo "DEBUG AFTER PASSWORD CHANGE: USER=[$USER] LOCK=[$LOCK]"
    
    if [[ "$LOCK" =~ [0-9] ]]; then
        echo "$CURRENT_DATE $LDAP_HOST3 - USER:$USER ALREADY_LOCKED"
        echo "$CURRENT_DATE $LDAP_HOST3 - USER:$USER ALREADY_LOCKED" >> "$LOGFILE"
    elif [[ -z "$LOCK" ]]; then
        ldapmodify -x -h "$LDAP_HOST3" -p 10389 -D "$BIND_DN" -w "$PASS" <<EOF
dn: $DN
changetype: modify
add: pwdAccountLockedTime
pwdAccountLockedTime: 000001010000Z
EOF

        echo "$CURRENT_DATE $LDAP_HOST3 - USER:$USER ACCOUNT_LOCKED"
        echo "$CURRENT_DATE $LDAP_HOST3 - USER:$USER ACCOUNT_LOCKED" >> "$LOGFILE"
    fi
COMMENT

done < "$USERS_FILE"
echo -e "\nDaily Account Removal - Master Script execution completed successfully"; printf -- '#%.0s' {1..79};echo -e ""
