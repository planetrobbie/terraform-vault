#!/bin/bash

while getopts 'hlwu:' option;
do
        case $option in
                h) echo -e "Usage:\n\n-l to login to Google Cloud MySQL Database as ${db_user}\n-u to login to Google Cloud MySQL Database as another user\n-w to watch MySQL users being created by Vault";;
                l) /usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} 2>/dev/null;;
                u) /usr/bin/mysql -u $2 -h db.prod.yet.org. -p;;
                w) watch '/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} mysql -e "select user from user;" 2>/dev/null | grep --invert-match sys | grep -v ^user | grep -v vault-user ';;
        esac
done