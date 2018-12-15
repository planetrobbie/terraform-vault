#!/bin/bash

# Latest Ansible install
sudo apt-get update
sudo apt-get install software-properties-common --yes
sudo apt-add-repository --update ppa:ansible/ansible --yes
sudo apt-get install ansible --yes
sudo apt-get install mysql-client -y
/usr/bin/ansible-playbook playbook/playbook.yml

# Vault
export VAULT_ADDR='${vault_address}'
export VAULT_TOKEN='${vault_token}'
export VAULT_CACERT=/etc/vault/tls/ca.crt

rm /tmp/script.sh