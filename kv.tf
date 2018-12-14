resource "vault_mount" "kv" {
  path        = "kv"
  type        = "kv"
  description = "This is a key/value secret backend"
  options     = "${var.vault_kv_options}"
}

# secret that dev or ops cannot interact with
resource "vault_generic_secret" "priv" {
  path = "kv/priv"

  data_json = <<EOT
{
  "access_key": "supersecretkey"
}
EOT
}

# secrets for bookshelf application
# https://github.com/planetrobbie/bookshelf/tree/master/container-engine
resource "vault_generic_secret" "bookshelf" {
  path = "kv/bookshelf"

  data_json = <<EOT
{
  "project_id": "${var.project_name}",
  "host": "${google_sql_database_instance.master.ip_address.0.ip_address}",
  "database":   "bookshelf",  
  "username": "${var.db_user}",
  "password": "${var.db_bookshelf_password}"
}
EOT
}
