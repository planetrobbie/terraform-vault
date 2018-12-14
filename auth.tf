resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_secret" "ops-user" {
  path = "auth/userpass/users/ops"

  data_json = <<EOT
{
  "password": "ops"
  "policies": "ops"
}
EOT
}

resource "vault_generic_secret" "dev-user" {
  path = "auth/userpass/users/dev"

  data_json = <<EOT
{
  "password": "dev"
  "policies": "dev"
}
EOT
}

resource "vault_generic_secret" "admin-user" {
  path = "auth/userpass/users/admin"

  data_json = <<EOT
{
  "password": "admin"
  "policies": "admin"
}
EOT
}