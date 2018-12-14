#!/bin/bash

export VAULT_ADDR='${vault_address}'
export VAULT_CACERT=/etc/vault/tls/ca.crt
export VAULT_TOKEN='${env.VAULT_TOKEN}'

# Create Ops user
/usr/local/bin/vault write auth/userpass/users/ops password=ops

# Create Dev user
/usr/local/bin/vault write auth/userpass/users/dev password=dev