vault {
  address = "${vault_address}"
  renew_token = false

  retry {
    enabled = true
    attempts = 5
    backoff = "250ms"
  }

  ssl {
    enabled = true
    ca_cert = "/etc/vault/tls/ca.crt"
  }
}

template {
  source      = "/etc/consul-template.d/cert.tpl"
  destination = "/etc/nginx/certs/cert.crt"
  perms       = "0600"
  command     = "systemctl reload nginx"
}

template {
  source      = "/etc/consul-template.d/key.tpl"
  destination = "/etc/nginx/certs/cert.key"
  perms       = "0600"
  command     = "systemctl reload nginx"
}