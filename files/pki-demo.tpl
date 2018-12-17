vault {
  address = "${vault_address}:8200"
  renew_token = true

  retry {
    enabled = true
    attempts = 5
    backoff = "250ms"
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