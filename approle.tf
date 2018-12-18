resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "consul-template" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "consul-template"
  policies  = ["default", "pki_int"]
}