[[snippets]]
  description = "Vault path-help"
  command = "vault path-help <path>"
  tag = ["vault", "help"]
  output = ""
[[snippets]]
  description = "Vault API export token to envt variable"
  command = "export TOKEN=`cat ~/.vault-token`"
  tag = ["vault", "api", "token"]
  output = ""
[[snippets]]
  description = "Vault API"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X <VERB> -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/<PATH> | jq"
  tag = ["vault", "api"]
  output = ""
[[snippets]]
  description = "Vault API with payload"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X <VERB> -H \"X-Vault-Token: $TOKEN\" -d @<PAYLOAD> ${vault_address}/v1/<PATH> | jq"
  tag = ["vault", "api"]
  output = ""
[[snippets]]
  description = "Vault API self renew token"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/auth/token/renew-self | jq"
  tag = ["vault", "api", "token"]
  output = ""
[[snippets]]
  description = "Vault API DB read creds"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X GET -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/db/creds/<role> | jq ."
  tag = ["vault", "api"]
  output = ""
[[snippets]]
  description = "Vault API DB read creds"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" --data '{ \"lease_id\": \"database/creds/<role>/<lease_id>\", \"increment\": 3600}' ${vault_address}/v1/sys/leases/renew | jq ."
  tag = ["vault", "api", "db", "lease"]
  output = ""
[[snippets]]
  description = "Vault AUTH login userpass"
  command = "vault login -method=userpass username=<user> password=<password>"
  tag = ["vault", "auth", "userpass"]
  output = ""
[[snippets]]
  description = "Vault AUTH login AppRole"
  command = "vault write auth/approle/login role_id=<role_id> secret_id=<secret_id>"
  tag = ["vault", "auth", "approle"]
[[snippets]]
  description = "Vault KV put"
  command = "vault kv put kv/<secret>"
  tag = ["vault", "kv"]
  output = ""
[[snippets]]
  description = "Vault KV get"
  command = "vault kv get kv/<secret>"
  tag = ["vault", "kv"]
  output = ""
[[snippets]]
  description = "Vault DB read creds"
  command = "vault read db/creds/<role>"
  tag = ["vault", "mysql"]
  output = ""
[[snippets]]
  description = "Vault DB show lease list"
  command = "vault list /sys/leases/lookup/db/creds/<role>/"
  tag = ["vault", "mysql", "lease"]
  output = ""
[[snippets]]
  description = "Vault DB revoke a specific lease from role"
  command = "vault lease revoke db/creds/<role>/<lease_id>"
  tag = ["mysql","lease"]
  output = ""
[[snippets]]
  description = "Vault DB revoke lease from role by prefix"
  command = "vault lease revoke -prefix db/creds/<role>"
  tag = ["mysql","lease"]
  output = ""
[[snippets]]
  description = "Vault TLS create Certificate"
  command = "vault write pki_int/issue/${pki_role} common_name=<host>.${dns_domain} ttl=5m"
  tag = ["vault", "tls"]
  output = ""
[[snippets]]
  description = "Vault TLS watch Certificate store"
  command = "watch vault list pki_int/certs"
  tag = ["vault", "tls"]
  output = ""
[[snippets]]
  description = "Vault TLS revoke a Certificate by serial"
  command = "vault write pki_int/revoke serial_number=\"\""
  tag =["vault", "tls"]
  output = ""
[[snippets]]
  description = "Vault TLS revoke all issued Certificates"
  command = "vault lease revoke -prefix pki_int/issue/${pki_role}"
  tag = ["vault", "tls"]
  output = ""
[[snippets]]
  description = "Vault TLS tidy Certificate store"
  command = "vault write pki_int/tidy safety_buffer=5s tidy_cert_store=true tidy_revocation_list=true"
  tag = ["vault", "tls"]
  output = ""
[[snippets]]
  description = "Vault TOKEN create with specific policy and display name"
  command = "vault token create -policy=<policy_name> -display-name=\"<display_name>\""
  tag = ["vault", "token"]
  output = ""
[[snippets]]
  description = "Vault lease revoke prefix"
  command = "vault lease revoke -prefix <prefix>"
  tag = ["vault", "lease"]
  output = ""
[[snippets]]
  description = "Vault OPS  enable audit"
  command = "vault audit enable file file_path=/home/vault/audit.log"
  tag = ["vault", "ops"]
  output = ""
[[snippets]]
  description = "Vault OPS disable audit"
  command = "vault audit disable"
  tag = ["vault", "ops"]
  output = ""
[[snippets]]
  description = "Vault OPS monitor logs"
  command = "sudo journalctl -f -u vault"
  tag = ["vault", "ops"]
  output = ""
[[snippets]]
  description = "Vault OPS step-down"
  command = "vault operator step-down"
  tag = ["vault", "ops"]
  output = ""
[[snippets]]
  description = "Vault OPS status"
  command = "vault status"
  tag = ["vault", "ops"]
  output = ""
[[snippets]]
  description = "Vault OPS systemd restart"
  command = "sudo systemctl restart vault"
  tag = ["vault", "ops"]
  output = ""
[[snippets]]
  description = "Vault OPS systemd status"
  command = "sudo systemctl status vault"
  tag = ["vault", "ops"]
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
  command = "watch '/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} mysql -e \"select user,password from user;\" 2>/dev/null | grep --invert-match sys | grep -v ^user | grep -v vault-user'"
  tag = ["mysql"]
  output = ""
[[snippets]]
  description = "Vault GCP create GCE auth role"
  command = "vault write auth/gcp/role/<role> type=\"gce\" project_id=\"${project_name}\"     policies=\"<policy>\" bound_zones=\"<bound_zone>\" ttl=\"30m\" max_ttl=\"24h\""
  tag = ["vault", "gcp"]
  output = ""
[[snippets]]
  description = "GCP get JWT token"
  command = "export TOKEN=\"$(curl -sS -H 'Metadata-Flavor: Google' --get --data-urlencode 'audience=http://vault/gce-role'  --data-urlencode 'format=full'  'http://metadata/computeMetadata/v1/instance/service-accounts/default/identity')\""
  tag = ["gcp", "token"]
  output = ""
[[snippets]]
  description = "Vault GCP login thru GCE role"
  command = "vault write auth/gcp/login role=\"gce-role\" jwt=\"$TOKEN\""
  tag = ["vault", "gcp"]
  output = ""
[[snippets]]
  description = "Vault GCP read role"
  command = "vault read auth/gcp/role/<role>"
  tag = ["vault", "gcp"]
  output = ""
[[snippets]]
  description = "Vault GCP get key"
  command = "vault read gcp/key/<role>"
  tag = ["vault", "gcp"]
  output = ""
[[snippets]]
  description = "Vault GCP login - XXX remove credentials after allowing API access from Instance"
  command = "vault login -method=gcp role=\"iam-role\" jwt_exp=\"15m\"     credentials=@/home/${ssh_user}/vault-kms.json  project=\"${project_name}\" ttl=\"30m\" max_ttl=\"24h\" service_account=\"vault-kms@${project_name}.iam.gserviceaccount.com\""
  tag = ["vault", "gcp"]
  output = ""
[[snippets]]
  description = "Get latest HashiCorp product version"
  command = "curl -sS https://releases.hashicorp.com/<product>/index.json | jq -r '.versions[].version' | grep -Ev 'beta|rc' | tail -n 1"
  tag = ["hashicorp"]
  output = ""
[[snippets]]
  description = "Consul-Template renew TLS once"
  command = "sudo /usr/local/bin/consul-template -vault-ssl-ca-cert=/etc/vault/tls/ca.crt -config='/etc/consul-template.d/pki-demo.hcl' -once"
  tag = ["tls", "consul-template"]
[[snippets]]
  description = "TLS revoke, revocation crl list"
  command = "watch \"curl --cacert /etc/vault/tls/ca.crt -sS ${vault_address}/v1/pki_int/crl | openssl crl -inform DER -text -noout -\""
  tag = ["tls", "crl"]
  output = ""
[[snippets]]
  description = "TLS certificate status"
  command = "watch -n 5 \"curl --cacert /home/${ssh_user}/pki/ca.pem  --insecure -v https://www.${dns_domain} 2>&1 | awk 'BEGIN { cert=0 } /^\\* SSL connection/ { cert=1 } /^\\*/ { if (cert) print }'\""
  tag = ["tls"]
  output = ""
[[snippets]]
  description = "Linux which program listen on which port"
  command = "netstat -tlnp"
  tag = ["linux"]
  output = ""