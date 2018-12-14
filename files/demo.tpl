#!/bin/bash

while getopts 'hlw' option;
do
        case $option in
                h) echo -e "Usage:\n\n-l to login to Google Cloud MySQL Database as ${db_user}\n-w to watch MySQL users being created by Vault";;
                l) /usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password};;
                w) watch '/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} -e "select user from user;"';;
        esac
done