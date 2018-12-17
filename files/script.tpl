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

vault write -format=json pki/root/generate/internal \
 common_name="pki-ca-root" ttl=87600h | tee \
>(jq -r .data.certificate > ca.pem) \
>(jq -r .data.issuing_ca > issuing_ca.pem) \
>(jq -r .data.private_key > ca-key.pem)

rm /tmp/script.sh