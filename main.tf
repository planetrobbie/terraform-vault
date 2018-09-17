data "vault_generic_secret" "app_secret" {
  path = "kv/app_secret"
}

data "template_file" "credentials" {
  template = "username: $${creds["username"]}}\npassword: $${{creds["password"]}}"

  vars {
    creds  = ${data.vault_generic_secret.app_secret.data}
  }
}
