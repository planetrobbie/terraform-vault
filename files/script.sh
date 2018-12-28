#!/bin/bash

# Latest Ansible install
sudo apt-get update
sudo apt-get install software-properties-common --yes
sudo apt-add-repository --update ppa:ansible/ansible --yes
sudo apt-get install ansible --yes

# Ansible Playbook
/usr/bin/ansible-playbook playbook.yml

# Vault environment variables
export VAULT_ADDR='${vault_address}'
export VAULT_TOKEN='${vault_token}'
export VAULT_CACERT=/etc/vault/tls/ca.crt

# Authenticate Vault using AppRole.
if [ ! -d ~/approle ]; then
	echo "Authenticating thru AppRole"

    mkdir ~/approle
	sudo vault write auth/approle/login role_id=${role_id} secret_id=${secret_id}
	echo role_id > ~/approle/${role_id}
	echo secret_id > ~/approle/${secret_id}

	vault agent -config=/tmp/vault-agent.hcl

	# Position the Vault token for Consul-template process which runs as root
	sudo mv /tmp/consul-template-token /root/.vault-token
fi

# Provision Root and Intermediate Certificate Authority
if [ ! -d ~/pki ]; then
    echo "Provisioning PKI"

    # Gather everything in ~/pki
    mkdir ~/pki; cd ~/pki

    # Root CA
    vault write -format=json pki/root/generate/internal \
		 common_name="pki-ca-root" ttl=87600h | tee \
		>(jq -r .data.certificate > ca.pem) \
		>(jq -r .data.issuing_ca > issuing_ca.pem) \
		>(jq -r .data.private_key > ca-key.pem)

	# Intermediate CA
	vault write -format=json pki_int/intermediate/generate/internal \
		common_name="pki-ca-int" ttl=43800h | tee \
		>(jq -r .data.csr > pki_int.csr) \
		>(jq -r .data.private_key > pki_int.pem)

	# signing CSR using root CA
	vault write -format=json pki/root/sign-intermediate \
		csr=@pki_int.csr \
		common_name="pki-ca-int" ttl=43800h | tee \
		>(jq -r .data.certificate > pki_int.pem) \
		>(jq -r .data.issuing_ca > pki_int_issuing_ca.pem)

	# Inject it back into Intermediate CA configuration
	vault write pki_int/intermediate/set-signed certificate=@pki_int.pem

	# Create PKI Role
	vault write pki_int/roles/${pki_role} \
          allow_any_name=true \
          max_ttl="20m" \
          generate_lease=true

    # PKI Revocation list configuration [require GSLB]
    vault write pki_int/config/urls \
      issuing_certificates="https://vault.${dns_domain}/v1/pki_int/ca" \
      crl_distribution_points="https://vault.${dns_domain}/v1/pki_int/crl"

    # Lower the expiration delay of your Certificate Revocation List
    curl \
        -sS \
        --cacert /etc/vault/tls/ca.crt \
        --header "X-Vault-Token: ${vault_token}" \
        --request POST \
        --data '{"expiry": "2m"}' \
        ${vault_address}/v1/pki_int/config/crl

fi

# Configure GCP AUTH and Secret Engine
if [ ! -d ~/gcp ]; then

	echo "Provisioning GCP related stuff"

    # ~/gcp contains required bits
    mkdir ~/gcp; cd ~/gcp

    # Grab GCP JSON credentials
    echo '${gcp_json_key}' | base64 --decode > ./creds.json

    # Configure gcloud SDK
    gcloud auth activate-service-account --key-file ./creds.json
    gcloud config set core/project ${project_name}

	# Inject Service Account Key to GCP Auth backend
	vault write auth/gcp/config credentials=@./creds.json

	# Inject Service Account Key to GCP Secret Engine
	vault write gcp/config credentials=@./creds.json

	# Configure GCP SECRET Key Generation - roles/viewer
	vault write gcp/roleset/key project="${project_name}" secret_type="service_account_key" bindings='resource "//cloudresourcemanager.googleapis.com/projects/${project_name}" {roles = ["roles/viewer"]}'

	# Configure GCP SECRET OAuth Token Generation - StorageAdmin
	vault write gcp/roleset/token project="${project_name}" secret_type="access_token" token_scopes="https://www.googleapis.com/auth/cloud-platform" bindings='resource "buckets/${project_name}" { roles = ["roles/storage.objectAdmin", "roles/storage.legacyBucketReader"] }'

fi

# Configure k8s Use Case
if [ ! -d ~/k8s ] && [ ${enable_auth_k8s} ]; then
	
	echo "Provisioning K8S"

    # ~/k8s contains required bits
    mkdir ~/k8s; cd ~/k8s

    # Grab Client Certificate
	echo '${k8s_client_crt}' | base64 --decode > ./k8s_client.crt

	# Grab Client Key
	echo '${k8s_client_key}' | base64 --decode > ./k8s_client.key

	# Grab Cluster CA Certificate
	echo '${k8s_cluster_crt}' | base64 --decode > ./k8s_cluster_ca.crt

	# Configure Cluster
	kubectl config set-cluster demo-k8s-cluster --server=https://${k8s_host} --certificate-authority=./k8s_cluster_ca.crt --client-certificate=./k8s_client.crt

    # Configure Context
	kubectl config set-context demo-k8s --cluster=demo-k8s-cluster --namespace=default --user=admin

	# Set current Context
	kubectl config use-context demo-k8s

	# Configure Credentials
	kubectl config set-credentials admin --client-certificate=./k8s_client.crt --client-key=./k8s_client.key

	# Protect sensitive information
	chmod 600 *

	# Configure ClusterRoleBinding
	kubectl apply -f - <<EOH
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: default
EOH
	
	# Get the name of the secret corresponding to the service account
	SECRET_NAME="$(kubectl get serviceaccount vault-auth -o go-template='{{ (index .secrets 0).name }}')"

  	# Get the actual token reviewer account
	TR_ACCOUNT_TOKEN="$(kubectl get secret $SECRET_NAME -o go-template='{{ .data.token }}' | base64 --decode)"

	# Configure Vault to talk to our Kubernetes host with the cluster's CA and the token reviewer JWT token
	vault write auth/kubernetes/config kubernetes_host="https://${k8s_host}" kubernetes_ca_cert=@./k8s_cluster_ca.crt token_reviewer_jwt="$TR_ACCOUNT_TOKEN"

	# Push upstream Official Vault Docker image
	cd ~/code/vault/
	git config --global credential.'https://source.developers.google.com'.helper gcloud.sh
	git remote add google https://source.developers.google.com/p/${project_name}/r/docker-vault
	git push google master

	# Install Vault Deployment YAML file
	mv /tmp/dep-vault.yaml ~/k8s/

	# Push upstream Official Vault Docker image
	cd ~/code/bookshelf/
	git config --global credential.'https://source.developers.google.com'.helper gcloud.sh
	git remote add google https://source.developers.google.com/p/${project_name}/r/bookshelf
	git push google master

fi

#rm /tmp/script.sh