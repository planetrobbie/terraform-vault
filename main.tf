data "vault_generic_secret" "app_secret" {
  path = "kv/app_secret"
}

data "template_file" "credentials" {
  template = "username: $${data.vault_generic_secret.app_secret.data["username"]}}\npassword: $${{data.vault_generic_secret.app_secret.data["password"]}}"
}
