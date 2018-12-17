#!/bin/bash

# Latest Ansible install
sudo apt-get update
sudo apt-get install software-properties-common --yes
sudo apt-add-repository --update ppa:ansible/ansible --yes
sudo apt-get install ansible --yes
sudo apt-get install mysql-client -y
/usr/bin/ansible-playbook playbook.yml

# Vault
export VAULT_ADDR='${vault_address}'
export VAULT_TOKEN='${vault_token}'
export VAULT_CACERT=/etc/vault/tls/ca.crt

vault login ${vault_token}

if [ ! -d ~/pki ]; then
    echo "Provisioning PKI"

    # Gather everything in ~/pki
    mkdir ~/pki; cd pki

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
	vault write pki_int/roles/${dns_domain} \
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

#rm /tmp/script.sh