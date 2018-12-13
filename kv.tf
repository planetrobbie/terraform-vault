resource "vault_mount" "kv" {
  path        = "kv"
  type        = "kv"
  description = "This is a key/value secret backend"
  options     = "${var.vault_kv_options}"
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
  "username": "sebbraun",
  "password": ${db_bookshelf_password}"
}
EOT
}
