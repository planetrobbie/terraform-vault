resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_secret" "ops-user" {
  path = "auth/userpass/users/ops"

  data_json = <<EOT
{
  "password": "${var.userpass_password}",
  "policies": "ops"
}
EOT
depends_on = ["vault_auth_backend.userpass"]
}

resource "vault_generic_secret" "dev-user" {
  path = "auth/userpass/users/dev"

  data_json = <<EOT
{
  "password": "${var.userpass_password}",
  "policies": "dev"
}
EOT
depends_on = ["vault_auth_backend.userpass"]
}

resource "vault_generic_secret" "admin-user" {
  path = "auth/userpass/users/admin"

  data_json = <<EOT
{
  "password": "${var.userpass_password}",
  "policies": "admin"
}
EOT
depends_on = ["vault_auth_backend.userpass"]
}