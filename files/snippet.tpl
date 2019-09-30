[[snippets]]
  description = "Vault path-help"
  command = "vault path-help <path>"
  tag = ["vault", "help"]
[[snippets]]
  description = "Vault API export token to envt variable"
  command = "export TOKEN=`cat ~/.vault-token`"
  tag = ["vault", "api", "token"]
[[snippets]]
  description = "Vault API"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X <VERB> -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/<PATH> | jq"
  tag = ["vault", "api"]
[[snippets]]
  description = "Vault API with payload"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X <VERB> -H \"X-Vault-Token: $TOKEN\" -d @<PAYLOAD> ${vault_address}/v1/<PATH> | jq"
  tag = ["vault", "api"]
[[snippets]]
  description = "Vault API SECRET write"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -H \"X-Vault-Token: $TOKEN\" -X POST --data '{\"<key>\": \"<value>\"}' ${vault_address}/v1/kv/<path>"
  tag = ["vault","api","secret"]
[[snippets]]
  description = "Vault API TOKEN self renew"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/auth/token/renew-self | jq"
  tag = ["vault", "api", "token"]
[[snippets]]
  description = "Vault API DB read creds"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X GET -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/db/creds/<role> | jq ."
  tag = ["vault", "api"]
[[snippets]]
  description = "Vault API DB increment ttl"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" --data '{ \"lease_id\": \"db/creds/<role>/<lease_id>\", \"increment\": 3600}' ${vault_address}/v1/sys/leases/renew | jq ."
  tag = ["vault", "api", "db", "lease"]
[[snippets]]
  description = "Vault API Read Lease"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" --data '{ \"lease_id\": \"db/creds/<role=dev>/<lease_id>\"}' ${vault_address}/v1/sys/leases/lookup | jq ."
  tag = ["vault", "api", "lease"]
[[snippets]]
  description = "Vault API AppRole login"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST --data '{\"role_id\":\"<role_id=${role_id}>\",\"secret_id\":\"<secret_id=${secret_id}>\"}' ${vault_address}/v1/auth/approle/login | jq ."
  tag = ["vault", "api", "auth", "approle"]
[[snippets]]
  description = "Vault AUTH AppRole list roles"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X LIST -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/auth/approle/role | jq ."
  tag = ["vault", "api", "auth", "approle"]
[[snippets]]
  description = "Vault AUTH AppRole list secret_id accessors"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X LIST -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/auth/approle/role/<role=consul-template>/secret-id | jq ."
  tag = ["vault", "api", "auth", "approle"]
[[snippets]]
  description = "Vault AUTH AppRole lookup secret_id"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" --data '{ \"secret_id\": <secret_id> }' ${vault_address}/v1/auth/approle/role/<role=consul-template>/secret-id/lookup | jq ."
  tag = ["vault", "api", "auth", "approle"]
[[snippets]]
  description = "Vault AUTH Userpass login"
  command = "vault login -method=userpass username=<user> password=<password>"
  tag = ["vault", "auth", "userpass"]
[[snippets]]
  description = "Vault AUTH AppRole create role" 
  command = "vault write auth/approle/role/<role>  secret_id_ttl=120m  token_ttl=60m  token_max_tll=120m token_num_uses=10 secret_id_num_uses=40 policies=\"<policies>\""
  tag = ["vault", "auth", "approle"]
[[snippets]]
  description = "Vault AUTH AppRole get details"
  command = "vault read auth/approle/role/<role=consul-template>"
  tag = ["vault", "auth", "approle"]
[[snippets]]
  description = "Vault AUTH AppRole get role_id"
  command = "vault read auth/approle/role/<role=consul-template>/role-id"
  tag = ["vault", "auth", "approle"]
[[snippets]]
  description = "Vault AUTH AppRole get secret_id"
  command = "vault write -f auth/approle/role/<role=consul-template>/secret-id"
  tag = ["vault","auth","approle"]
[[snippets]]
  description = "Vault AUTH AppRole login"
  command = "vault write auth/approle/login role_id=<role_id=${role_id}> secret_id=<secret_id=${secret_id}>"
  tag = ["vault", "auth", "approle"]
[[snippets]]
  description = "Vault KV put"
  command = "vault kv put kv/<secret>"
  tag = ["vault", "kv"]
[[snippets]]
  description = "Vault KV get"
  command = "vault kv get kv/<secret>"
  tag = ["vault", "kv"]
[[snippets]]
  description = "VAULT DB configure"
  command = "vault write db/config/mysql plugin_name=mysql-database-plugin allowed_roles=ops,dev,all,db-prod verify_connection=false connection_url=\"{{username}}:{{password}}@tcp(${db_host}:3306)/\" username=\"${db_user}\" password=\"<password>\""
  tag = ["vault","db"]
[[snippets]]
  description = "Vault DB create role"
  command = "vault write db/roles/all db_name=mysql creation_statements=\"CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON *.* TO '{{name}}'@'%';\" default_ttl=\"1m\" max_ttl=\"24h\""
  tag = ["vault", "mysql", "db"]
[[snippets]]
  description = "Vault DB read creds"
  command = "vault read db/creds/<role>"
  tag = ["vault", "mysql", "db"]
[[snippets]]
  description = "Vault DB show lease list"
  command = "vault list /sys/leases/lookup/db/creds/<role>/"
  tag = ["vault", "mysql", "lease", "db"]
[[snippets]]
  description = "Vault DB revoke a specific lease from role"
  command = "vault lease revoke db/creds/<role>/<lease_id>"
  tag = ["mysql","lease", "db"]
[[snippets]]
  description = "Vault DB revoke lease from role by prefix"
  command = "vault lease revoke -prefix db/creds/<role=ops>"
  tag = ["mysql","lease", "db"]
[[snippets]]
  description = "Vault TLS create Certificate"
  command = "vault write pki_int/issue/${pki_role} common_name=<host>.${dns_domain} ttl=5m"
  tag = ["vault", "tls"]
[[snippets]]
  description = "Vault TLS watch Certificate store"
  command = "watch vault list pki_int/certs"
  tag = ["vault", "tls"]
[[snippets]]
  description = "Vault TLS revoke a Certificate by serial"
  command = "vault write pki_int/revoke serial_number=\"\""
  tag =["vault", "tls"]
[[snippets]]
  description = "Vault TLS revoke all issued Certificates"
  command = "vault lease revoke -prefix pki_int/issue/${pki_role}"
  tag = ["vault", "tls"]
[[snippets]]
  description = "Vault TLS tidy Certificate store"
  command = "vault write pki_int/tidy safety_buffer=5s tidy_cert_store=true tidy_revocation_list=true"
  tag = ["vault", "tls"]
[[snippets]]
  description = "Vault TLS Verify CA"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS ${vault_address}/v1/<pki=pki>/ca/pem | openssl x509 -text"
  tag = ["tls"]
[[snippets]]
  description = "Vault TLS Export CA"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS ${vault_address}/v1/<pki=pki>/ca/pem > <pki=pki>_ca.pem"
  tag = ["tls","export"]
[[snippets]]
  description = "Vault TOKEN create with specific policy and display name"
  command = "vault token create -policy=<policy_name> -display-name=\"<display_name>\""
  tag = ["vault", "token"]
[[snippets]]
  description = "VAULT TOKEN create batch"
  command = "vault token create -type=batch -policy=<policy=default>"
  tag = ["vault","token","batch"]
[[snippets]]
  description = "VAULT TOKEN lookup"
  command = "VAULT_TOKEN=<token> vault token lookup"
  tag = ["vault","token"]
[[snippets]]
  description = "Vault LEASE revoke prefix"
  command = "vault lease revoke -prefix <prefix>"
  tag = ["vault", "lease"]
[[snippets]]
  description = "Vault OPS  enable audit"
  command = "vault audit enable file file_path=/home/vault/audit.log"
  tag = ["vault", "ops"]
[[snippets]]
  description = "Vault OPS disable audit"
  command = "vault audit disable"
  tag = ["vault", "ops"]
[[snippets]]
  description = "Vault OPS monitor logs"
  command = "sudo journalctl -f -u vault"
  tag = ["vault", "ops"]
[[snippets]]
  description = "Vault OPS step-down"
  command = "vault operator step-down"
  tag = ["vault", "ops"]
  output = ""
[[snippets]]
  description = "Vault OPS status"
  command = "vault status"
  tag = ["vault", "ops"]
[[snippets]]
  description = "Vault OPS systemd restart"
  command = "sudo systemctl restart vault"
  tag = ["vault", "ops"]
[[snippets]]
  description = "Vault OPS systemd status"
  command = "sudo systemctl status vault"
  tag = ["vault", "ops"]
[[snippets]]
  description = "MySQL LOGIN as ${db_user}"
  command = "/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} 2>/dev/null"
  tag = ["mysql"]
[[snippets]]
  description = "MySQL LOGIN as another user"
  command = "/usr/bin/mysql -u <user> -h db.${dns_domain} -p<password>"
  tag = ["mysql"]
[[snippets]]
  description = "MySQL WATCH users being created by Vault"
  command = "watch '/usr/bin/mysql -u ${db_user} -h db.${dns_domain} -p${db_password} mysql -e \"select user from user;\" 2>/dev/null | grep --invert-match sys | grep -v ^user | grep -v vault-user'"
  tag = ["mysql"]
[[snippets]]
  description = "GCP get JWT token"
  command = "export JWT_TOKEN=\"$(curl -sS -H 'Metadata-Flavor: Google' --get --data-urlencode 'audience=http://vault/gce' --data-urlencode 'format=full' 'http://metadata/computeMetadata/v1/instance/service-accounts/default/identity')\""
  tag = ["gcp", "token"]
[[snippets]]
  description = "GCP demo token usage"
  command = ""
  tag = ["gcp","API"]
[[snippets]]
  description = "Vault GCP AUTH create role type gce"
  command = "vault write auth/gcp/role/<role> type=\"gce\" project_id=\"${project_name}\" policies=\"<policy>\" bound_zones=\"<bound_zone>\" ttl=\"30m\" max_ttl=\"24h\""
  tag = ["vault", "gcp", "auth"]
[[snippets]]
  description = "Vault GCP AUTH login thru iam role"
  command = "vault login -method=gcp role=\"iam\" jwt_exp=\"15m\" credentials=@/home/${ssh_user}/gcp/creds.json"
  tag = ["vault","gcp","auth", "login"]
[[snippets]]
  description = "Vault GCP AUTH login thru gce role"
  command = "vault write auth/gcp/login role=\"gce\" jwt=\"$JWT_TOKEN\""
  tag = ["vault", "gcp"]
[[snippets]]
  description = "Vault GCP AUTH read role"
  command = "vault read auth/gcp/role/<role>"
  tag = ["vault", "gcp"]
[[snippets]]
  description = "VAULT K8S AUTH login"
  command = "vault write -tls-skip-verify auth/kubernetes/login role=k8s-role jwt=$JWT"
  tag = ["vault", "auth", "k8s"]
[[snippets]]
  description = "VAULT GCP SECRETS roleset create service_account_key type"
  command = "vault write gcp/roleset/sak-<roleset> project=\"${project_name}\" secret_type=\"service_account_key\" bindings='resource \"//cloudresourcemanager.googleapis.com/projects/${project_name}\" {roles = [\"roles/viewer\"]}'"
  tag = ["vault","gcp","secrets"]
[[snippets]]
  description = "VAULT GCP SECRETS roleset create token type"
  command = "vault write gcp/roleset/token-<roleset> project=\"${project_name}\" secret_type=\"access_token\" token_scopes=\"https://www.googleapis.com/auth/cloud-platform\" bindings='resource \"buckets/${project_name}\" { roles = [\"roles/storage.objectAdmin\", \"roles/storage.legacyBucketReader\"] }'"
  tag = ["vault","gcp","secrets"]
[[snippets]]
  description = "VAULT GCP SECRETS roleset delete service_account_key type"
  command = "vault delete gcp/roleset/<roleset>"
  tag = ["vault","gcp","secrets"]
[[snippets]]
  description = "Vault GCP SECRETS get service account key"
  command = "vault read gcp/key/<roleset=key>"
  tag = ["vault", "gcp", "secrets"]
[[snippets]]
  description = "Vault GCP SECRETS get oauth token"
  command = "vault read gcp/token/<roleset=token>"
  tag = ["vault", "gcp", "secrets"]
[[snippets]]
  description = "GCP demo OAuth works"
  command = "curl -X POST --data-binary @<file=playbook.yml> -H \"Authorization: Bearer XXTOKENXX\" -H \"Content-Type: text/html\" \"https://www.googleapis.com/upload/storage/v1/b/${project_name}/o?uploadType=media&name=<file=playbook.yml>\""
  tag = ["oauth"]
[[snippets]]
  description = "HashiCorp GET latest product version"
  command = "curl -sS https://releases.hashicorp.com/<product>/index.json | jq -r '.versions[].version' | grep -Ev 'beta|rc' | tail -n 1"
  tag = ["hashicorp"]
[[snippets]]
  description = "TLS Consul-Template renew once"
  command = "sudo /usr/local/bin/consul-template -vault-ssl-ca-cert=/etc/vault/tls/ca.crt -config='/etc/consul-template.d/pki-demo.hcl' -once"
  tag = ["tls", "consul-template"]
[[snippets]]
  description = "TLS revoke, revocation crl list"
  command = "curl -sS --output - --cacert /etc/vault/tls/ca.crt ${vault_address}/v1/pki_int/crl | openssl crl -inform DER -text"
  tag = ["tls", "crl"]
[[snippets]]
  description = "TLS NGINX certificate status"
  command = "watch -n 5 \"curl --cacert /home/${ssh_user}/pki/ca.pem  --insecure -v https://www.${dns_domain} 2>&1 | awk 'BEGIN { cert=0 } /^\\* SSL connection/ { cert=1 } /^\\*/ { if (cert) print }'\""
  tag = ["tls", "nginx"]
[[snippets]]
  description = "Linux which program listen on which port"
  command = "netstat -tlnp"
  tag = ["linux"]
[[snippets]]
  description = "Linux base64 decode"
  command = "echo '<string>' | base64 --decode"
  tag = ["linux"]
[[snippets]]
  description = "K8S create resource"
  command = "kubectl apply -f <yaml=~/k8s/dep-vault.yaml>"
  tag = ["k8s", "kubectl"]
[[snippets]]
  description = "K8S delete resource"
  command = "kubectl delete -f <yaml=~/k8s/dep-vault.yaml>"
  tag = ["k8s", "kubectl"]
[[snippets]]
  description = "K8S get service"
  command = "kubectl get svc <service=bookshelf-frontend>"
  tag = ["k8s", "kubectl"]
[[snippets]]
  description = "K8S enter pod"
  command = "kubectl exec -it <pod> -- /bin/sh"
  tag = ["k8s", "kubectl"]
[[snippets]]
  description = "K8S enter vault pod"
  command = "kubectl exec -it $(kubectl get pod -l \"app=vault\" -o jsonpath='{.items[0].metadata.name}') -- /bin/sh"
  tag = ["k8s", "kubectl"]
[[snippets]]
  description = "K8S get JWT token"
  command = "JWT=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
  tag = ["k8s","token"]
[[snippets]]
  description = "K8S create and enter vault pod"
  command = "kubectl run vault-shell --rm -i --tty --env=\"VAULT_ADDR=${vault_address}\" --image gcr.io/${project_name}/docker-vault:latest -- /bin/sh"
  tag = ["k8s", "vault", "kubectl"]
[[snippets]]
  description = "K8S get bookshelf lease id"
  command = "kubectl exec -it bookshelf-frontend-<id> -- cat /etc/vault-assets/lease_id"
  tag = ["kubectl","lease"]
[[snippets]]
  description = "GIT trigger"
  command = "git commit --allow-empty -am 'trigger build' && git push -f google master"
  tag = ["git"]
[[snippets]]
  description = "GCP make Container Registry images public"
  command = "gsutil iam ch allUsers:objectViewer gs://artifacts.${project_name}.appspot.com/"
  tag = ["k8s","registry"]
[[snippets]]
  description = "Vault API Lease force revoke"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/sys/leases/revoke-force/gcp | jq ."
  tag = ["vault","api","lease"]
[[snippets]]
  description = "VAULT TLS AUTH config"
  command = "vault write auth/cert/certs/test display_name=test policies=dev certificate=@ca.pem ttl=3600"
  tag = ["vault","tls","auth", "config"]
[[snippets]]
  description = "VAULT TLS AUTH get token"
  command = "vault login -method=cert -ca-cert=ca.pem -client-cert=cert.pem -client-key=key.pem name=test"
  tag = ["vault","tls","auth", "token"]
[[snippets]]
  description = "VAULT 1.1 Counter"
  command = "vault read -format=json sys/internal/counters/requests"
  tag = ["vault","licensing", "1.1"]
[[snippets]]
  description = "VAULT 1.1 curl flag"
  command = "-output-curl-string"
  tag = ["vault","flag", "1.1"]
[[snippets]]
  description = "VAULT TRANSIT enable"
  command = "vault secrets enable transit"
  tag = ["vault","transit","enable"]
[[snippets]]
  description = "VAULT TRANSIT create key"
  command = "vault write -f transit/keys/my-key"
  tag = ["vault","transit","key"]
[[snippets]]
  description = "VAULT TRANSIT encrypt"
  command = "vault write transit/encrypt/my-key plaintext=$(base64 <<< \"my secret data\")"
  tag = ["vault","transit","encrypt"]
[[snippets]]
  description = "VAULT TRANSIT decrypt"
  command = "vault write transit/decrypt/my-key ciphertext=<cipher> | jq .data.plaintext"
  tag = ["vault","transit","decrypt"]
[[snippets]]
  description = "VAULT TRANSIT rotate key - can still decrypt old stuff"
  command = "vault write -f transit/keys/my-key/rotate"
  tag = ["vault","transit","key","rotate"]
[[snippets]]
  description = "VAULT TRANSIT rewrap - unprivileged ops"
  command = "vault write transit/rewrap/my-key ciphertext=<cipher>"
  tag = ["vault","transit","rewrap"]
[[snippets]]
  description = "VAULT TRANSIT API create key"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" -d '{\"type\": \"ecdsa-p256\"}' ${vault_address}/v1/transit/keys/my-key | jq"
  tag = ["vault","api","transit","key"]
[[snippets]]
  description = "VAULT TRANSIT API update key config"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" -d '{\"deletion_allowed\": \"true\", \"allow_plaintext_backup\": \"true\", \"exportable\": \"true\"}' ${vault_address}/v1/transit/keys/my-key/config | jq"
  tag = ["vault","api","transit","key", "config"]
[[snippets]]
  description = "VAULT TRANSIT API read key"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/transit/keys/my-key | jq"
  tag = ["vault","api","transit","key"]
[[snippets]]
  description = "VAULT TRANSIT API list key"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X LIST -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/transit/keys | jq"
  tag = ["vault","api","transit","key"]
[[snippets]]
  description = "VAULT TRANSIT API rotate key"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/transit/keys/my-key/rotate | jq"
  tag = ["vault","api","transit","key","rotate"]
[[snippets]]
  description = "VAULT TRANSIT API export key"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/transit/export/encryption-key/my-key/1 | jq"
  tag = ["vault","api","transit","key","rotate"]
[[snippets]]
  description = "VAULT TRANSIT API backup key - base64 encoded"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/transit/backup/my-key | jq '.data.backup'"
  tag = ["vault","api","transit","key","backup"]
[[snippets]]
  description = "VAULT TRANSIT API encrypt"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" -d '{\"plaintext\": \"<base64=c2ViYnJhdW4K>\"}' ${vault_address}/v1/transit/encrypt/my-key | jq"
  tag = ["vault","api","transit","encrypt"]
[[snippets]]
  description = "VAULT TRANSIT API decrypt"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" -d '{\"ciphertext\": \"PASTE\"}' ${vault_address}/v1/transit/decrypt/my-key | jq"
  tag = ["vault","api","transit","encrypt"]
[[snippets]]
  description = "VAULT TRANSIT API generate data key"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" -d '{\"context\": \"<context=c2ViYnJhdW4K>\"}' ${vault_address}/v1/transit/datakey/wrapped/my-key | jq"
  tag = ["vault","api","transit","datakey"]
[[snippets]]
  description = "VAULT TRANSIT API generate random bytes"
  command = "curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H \"X-Vault-Token: $TOKEN\" -d '{\"format\": \"<format=hex>\"}' ${vault_address}/v1/transit/random/164 | jq"
  tag = ["vault","api","transit","datakey"]
[[snippets]]
  description = "VAULT AUTH USERPASS create user"
  command = "vault write -namespace=\"<namespace>\" auth/userpass/users/<username=guest> password=<password> policies=<policies>"
  tag = ["vault","auth","userpass"]
[[snippets]]
  description = "VAULT API POLICY create"
  command = "curl --cacert /etc/vault/tls/ca.crt -d @policy.json -sS -X PUT  -H \"X-Vault-Token: $TOKEN\" ${vault_address}/v1/sys/policy/policy_api | jq"
  tag = ["vault","api","policies"]
[[snippets]]
  description = "VAULT K8S CSI Driver demo launch"
  command = "kubectl apply -f ~/k8s/pod-nginx.yaml; kubectl apply -f ~/k8s/pvc-vault-csi-static.yaml; kubectl apply -f ~/k8s/pv-vault-csi.yaml"
[[snippets]]
  description = "VAULT K8S CSI Driver demo check"
  command = "kubectl exec -it nginx -- cat /mnt/vault/apikey"
  tag = ["k8s","csi"]
[[snippets]]
  description = "VAULT K8S CSI Driver demo troubleshoot"
  command = "kubectl logs -f csi-secrets-store-<id=t576h> secrets-store"
  tag = ["k8s","csi"]
[[snippets]]
  description = "VAULT K8S CSI Driver demo cleanup"
  command = "kubectl delete -f ~/k8s/pod-nginx.yaml; kubectl delete -f ~/k8s/pvc-vault-csi-static.yaml; kubectl delete -f ~/k8s/pv-vault-csi.yaml"
  tag = ["k8s","csi"]
[[snippets]]
  description = "TLS Decode"
  command = "openssl x509 -in <cert=~/pki/pki_int.pem> -text -noout"
  tag = ["tls","openssl"]
[[snippets]]
  description = "CONSUL active vault"
  command = "dig @127.0.0.1 -p 8600 active.vault.service.consul"
  tag = ["consul","active"]
[[snippets]]
  description = "Ansible playbook"
  command = "ansible-playbook ~/ansible/read_secret.yaml"
  tag = ["ansible","playbook"]