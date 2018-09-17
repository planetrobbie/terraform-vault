data "vault_generic_secret" "app_secret" {
  path = "kv/app_secret"
}

data "template_file" "credentials" {
  template = "username: $${secret["username"]}}\npassword: $${{secret["password"]}}"
  vars {
    secret = "${data.vault_generic_secret.app_secret.data}"
  }
}
