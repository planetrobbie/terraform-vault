[[snippets]]
  description = "login to Google Cloud MySQL Database as ${db_user}"
  command = "/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} 2>/dev/null"
  tag = ["mysql"]
  output = ""
[[snippets]]
  description = "login to Google Cloud MySQL Database as another user"
  command = "/usr/bin/mysql -u $2 -h db.${dns_domain} -p"
  tag = ["mysql"]
  output = ""
[[snippets]]
  description = "watch MySQL users being created by Vault"
  command = "watch '/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} mysql -e \"select user from user;\" 2>/dev/null | grep --invert-match sys | grep -v ^user | grep -v vault-user'"
  tag = ["mysql"]
  output = ""
[[snippets]]
  description = "Create a token with specific policy and display name"
  command = "vault token create -policy=<policy_name> -display-name=\"<display_name>\""
  tag = ["vault"]
  output = ""