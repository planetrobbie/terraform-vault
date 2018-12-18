resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "pki" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "pki"
  policies  = ["default", "pki_int"]
}