resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "consul-template" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "consul-template"
  policies  = ["default", "pki_int"]
}

resource "vault_approle_auth_backend_role_secret_id" "consul-template" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "${vault_approle_auth_backend_role.consul-template.role_name}"
}

resource "vault_approle_auth_backend_login" "login" {
  backend   = "${vault_auth_backend.approle.path}"
  role_id   = "${vault_approle_auth_backend_role.consul-template.role_id}"
  secret_id = "${vault_approle_auth_backend_role_secret_id.consul-template.secret_id}"
}