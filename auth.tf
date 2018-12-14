resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_secret" "admin-user" {
  path = "auth/userpass/users/admin"

  data_json = <<EOT
{
  "password": "admin"
}
EOT
}