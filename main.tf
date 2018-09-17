data "vault_generic_secret" "app_secret" {
  path = "kv/app_secret"
}

data "template_file" "credentials" {
  template = "username: $${username}}\npassword: $${{password}}"

  vars {
    username  = "${vault_generic_secret.app_secret.data["username"]}"
    password  = "${vault_generic_secret.app_secret.data["password"]}"
  }
}
