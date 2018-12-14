#!/bin/bash

export VAULT_ADDR='${vault_address}'
export VAULT_TOKEN='${vault_token}'
export VAULT_CACERT=/etc/vault/tls/ca.crt


rm /tmp/script.sh