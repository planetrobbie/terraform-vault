# It's not possible to reuse an instance name for up to a week after deletion.
# so we randomize the db name to avoid conflicting names.
resource "random_id" "name" {
  count = "${var.enable_secret_engine_db}"
  byte_length = 3
}

resource "google_sql_database_instance" "master" {
  count = "${var.enable_secret_engine_db}"
  name = "${var.db_instance_name}-${random_id.name.hex}"
  database_version = "MYSQL_5_7"
  
  # This attribute is really important to avoid resource force new at each apply
  region = "${var.region}"

  settings {
    # db-f1-micro tier is the smallest Cloud SQL Tier: 128 MiB RAM / 256 GiB Disk
    # Second-generation instance tiers are based on the machine
    # to list all available ones: gcloud sql tiers list
    tier = "db-f1-micro"

    ip_configuration = [{
      authorized_networks = [
        {value = "${data.dns_a_record_set.v1.addrs.0}"},
        {value = "${data.dns_a_record_set.v2.addrs.0}"},
      ]
    }]
  }
}

resource "google_sql_database" "bookshelf" {
  count = "${var.enable_secret_engine_db}"
  name      = "bookshelf"
  instance  = "${google_sql_database_instance.master.name}"
}

resource "google_sql_database" "vault-db" {
  count = "${var.enable_secret_engine_db}"
  name      = "${var.db_name}"
  instance  = "${google_sql_database_instance.master.name}"
}

resource "google_sql_user" "user" {
  count = "${var.enable_secret_engine_db}"
  name     = "${var.db_user}"
  instance = "${google_sql_database_instance.master.name}"
  password = "${var.db_password}"
}

resource "vault_mount" "database" {
  count = "${var.enable_secret_engine_db}"
  path        = "db"
  type        = "database"
  description = "A database secret engine"
  default_lease_ttl_seconds = "120"
  max_lease_ttl_seconds = "86400"
}

resource "vault_database_secret_backend_connection" "mysql" {
  count = "${var.enable_secret_engine_db}"
  backend       = "${vault_mount.database.path}"
  name          = "mysql"
  allowed_roles = ["ops", "dev"]
  verify_connection = false

  mysql {
    connection_url = "${var.db_user}:${var.db_password}@tcp(${google_sql_database_instance.master.ip_address.0.ip_address}:3306)/"
  }
}

# Ops can get read only access to the all databases
resource "vault_database_secret_backend_role" "ops" {
  count = "${var.enable_secret_engine_db}"
  backend             = "${vault_mount.database.path}"
  name                = "ops"
  db_name             = "${vault_database_secret_backend_connection.mysql.name}"
  creation_statements = "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';"
  default_ttl         = "${var.db_default_ttl}"
  max_ttl             = "${var.db_max_ttl}"
}

# Dev can get r/w access to all tables of ${var.db_name} database
resource "vault_database_secret_backend_role" "dev" {
  count = "${var.enable_secret_engine_db}"
  backend             = "${vault_mount.database.path}"
  name                = "dev"
  db_name             = "${vault_database_secret_backend_connection.mysql.name}"
  creation_statements = "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON *.* TO '{{name}}'@'%';"
  default_ttl         = "${var.db_default_ttl}"
  max_ttl             = "${var.db_max_ttl}"
}