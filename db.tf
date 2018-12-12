# It's not possible to reuse an instance name for up to a week after deletion.
# so we randomize the db name to avoid conflicting names.
resource "random_id" "name" {
  byte_length = 2
}

resource "google_sql_database_instance" "master" {
  name = "${var.db_instance_name}-${random_id.name.hex}"
  database_version = "MYSQL_5_7"
  settings {
    # db-f1-micro tier is the smallest Cloud SQL Tier: 128 MiB RAM / 256 GiB Disk
    # Second-generation instance tiers are based on the machine
    # to list all available ones: gcloud sql tiers list
    tier = "db-f1-micro"
    location_preference {
      zone = "${var.region_zone}"
    }
    ip_configuration = [{
      authorized_networks = [
        {value = "${data.dns_a_record_set.v1.addrs}"},
        {value = "${data.dns_a_record_set.v2.addrs}"},
      ]
    }]
  }
}

resource "google_sql_database" "vault-db" {
  name      = "${var.db_name}"
  instance  = "${google_sql_database_instance.master.name}"
}

resource "google_sql_user" "user" {
  name     = "${var.db_user}"
  instance = "${google_sql_database_instance.master.name}"
  password = "${var.db_password}"
}

resource "vault_mount" "database" {
  path        = "db"
  type        = "database"
  description = "A database secret engine"
  default_lease_ttl_seconds = "120"
  max_lease_ttl_seconds = "86400"
}

resource "vault_database_secret_backend_connection" "mysql" {
  backend       = "${vault_mount.database.path}"
  name          = "mysql"
  allowed_roles = ["ops", "dev"]

  mysql {
    connection_url = "${var.db_user}:${var.db_password}@tcp(${google_sql_database_instance.master.ip_address.0.ip_address}:3306)/"
  }
}