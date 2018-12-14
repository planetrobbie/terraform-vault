#!/bin/bash

while getopts l:w: option
do
	case "${option}" in
		l) /usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password};;
		w) watch '/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} -e "select user from user;"';;
	esac
done