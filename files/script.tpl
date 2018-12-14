#!/bin/bash

export VAULT_ADDR='${vault_address}'
export VAULT_CACERT=/etc/vault/tls/ca.crt

/usr/local/bin/vault status