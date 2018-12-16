[[snippets]]
  description = "Vault path-help"
  command = "vault path-help <path>"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault API"
  command = "curl -sS -X <VERB> -H \"X-Vault-Token: <token>\" http://127.0.0.1:8200/v1/<PATH> | jq"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault API with payload"
  command = "curl -sS -X <VERB> -H \"X-Vault-Token: <token>\" -d @<PAYLOAD> http://127.0.0.1:8200/v1/<PATH> | jq"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault login userpass"
  command = "vault login -method=userpass username=<user> password=<password>"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault put kv"
  command = "vault kv put kv/<secret>"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault get kv"
  command = "vault kv get kv/<secret>"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault read db creds"
  command = "vault read db/creds/<role>"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault create TLS Certificate"
  command = "vault write pki_int/issue/${dns_domain} common_name=<host>.${dns_domain} ttl=5m"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault watch TLS Certificate store"
  command = "watch vault list pki_int/certs"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault revoke a TLS Certificate by serial"
  command = "vault write pki_int/revoke serial_number=\"\""
  tag =["vault"]
  output = ""
[[snippets]]
  description = "Vault revoke all issued TLS Certificates"
  command = "vault lease revoke -prefix pki_int/issue/${dns_domain}"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault tidy TLS Certificate store"
  command = "vault write pki_int/tidy safety_buffer=5s tidy_cert_store=true tidy_revocation_list=true"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault create a token with specific policy and display name"
  command = "vault token create -policy=<policy_name> -display-name=\"<display_name>\""
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault lease revoke prefix"
  command = "vault lease revoke -prefix <prefix>"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault enable audit"
  command = "vault audit enable file file_path=/home/vault/audit.log"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault disable audit"
  command = "vault audit disable"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault monitor logs"
  command = "sudo journalctl -f -u vault"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault step-down"
  command = "vault operator step-down"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "Vault restart"
  command = "sudo systemctl restart vault"
  tag = ["vault"]
  output = ""
[[snippets]]
  description = "MySQL login to Google Cloud Database as ${db_user}"
  command = "/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} 2>/dev/null"
  tag = ["mysql"]
  output = ""
[[snippets]]
  description = "MySQL login to Google Cloud Database as another user"
  command = "/usr/bin/mysql -u <user> -h db.${dns_domain} -p<password>"
  tag = ["mysql"]
  output = ""
[[snippets]]
  description = "MySQL watch users being created by Vault"
  command = "watch '/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} mysql -e \"select user from user;\" 2>/dev/null | grep --invert-match sys | grep -v ^user | grep -v vault-user'"
  tag = ["mysql"]
  output = ""
[[snippets]]
  description = "GCP create GCE auth role"
  command = "vault write auth/gcp/role/<role> type=\"gce\" project_id=\"${project_name}\"     policies=\"<policy>\" bound_zones=\"<bound_zone>\" ttl=\"30m\" max_ttl=\"24h\""
[[snippets]]
  description = "GCP get JWT token"
  command = "export TOKEN=\"$(curl -sS -H 'Metadata-Flavor: Google' --get --data-urlencode 'audience=http://vault/gce-role'  --data-urlencode 'format=full'  'http://metadata/computeMetadata/v1/instance/service-accounts/default/identity')\""
  tag = ["gcp"]
  output = ""
[[snippets]]
  description = "GCP Vault login thru GCE role"
  command = "vault write auth/gcp/login role=\"gce-role\" jwt=\"$TOKEN\""
  tag = ["gcp"]
  output = ""
[[snippets]]
  description = "GCP Vault read role"
  command = "vault read auth/gcp/role/<role>"
  tag = ["gcp"]
  output = ""
[[snippets]]
  description = "GCP Vault get key"
  command = "vault read gcp/key/<role>"
  tag = ["gcp"]
  output = ""
[[snippets]]
  description = "GCP Auth - XXX remove credentials after allowing API access from Instance"
  command = "vault login -method=gcp role=\"iam-role\" jwt_exp=\"15m\"     credentials=@/home/${ssh_user}/vault-kms.json  project=\"${project_name}\" ttl=\"30m\" max_ttl=\"24h\" service_account=\"vault-kms@${project_name}.iam.gserviceaccount.com\""
  tag = ["gcp"]
  output = ""
[[snippets]]
  description = "Get latest HashiCorp product version"
  command = "curl -s https://releases.hashicorp.com/<product>/index.json | jq -r '.versions[].version' | grep -Ev 'beta|rc' | tail -n 1"
  tag = ["hashicorp"]
  output = ""
[[snippets]]
  description = "revoke, revocation crl list"
  command = "watch \"curl -sS ${vault_address}/v1/pki_int/crl | openssl crl -inform DER -text -noout -\""
  tag = ["tls"]
  output = ""
[[snippets]]
  description = "ssl certificate status"
  command = "watch -n 5 \"curl --cacert /etc/vault/tls/ca.crt  --insecure -v https://v1.${dns_domain} 2>&1 | awk 'BEGIN { cert=0 } /^\\* SSL connection/ { cert=1 } /^\\*/ { if (cert) print }'\""
  tag = ["tls"]
  output = ""
[[snippets]]
  description = "which program listen on which port"
  command = "netstat -tlnp"
  tag = ["linux"]
  output = ""