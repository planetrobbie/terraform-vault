#!/bin/bash

export VAULT_ADDR='${vault_address}'
export VAULT_CACERT=/etc/vault/tls/ca.crt

# Create Ops user
/usr/local/bin/vault write auth/userpass/users/ops password=ops