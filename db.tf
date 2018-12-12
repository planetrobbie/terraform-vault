resource "google_sql_database_instance" "master" {
  name = "vault-instance"
  database_version = "MYSQL_5_7"
  settings {
    # D0 is the smallest Cloud SQL Tier: 128 MiB RAM / 256 GiB Disk
    # to list all available ones: gcloud sql tiers list
    tier = "D0"
  }
}

resource "google_sql_database" "users" {
  name      = "vault"
  password  = "vpass"
  instance  = "${google_sql_database_instance.master.name}"
}