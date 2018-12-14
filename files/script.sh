#!/bin/bash

export VAULT_ADDR='https://v1.prod.yet.org:8200'
export VAULT_CACERT=/etc/vault/tls/ca.crt

/usr/local/bin/vault status
