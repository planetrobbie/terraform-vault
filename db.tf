resource "google_sql_database_instance" "master" {
  name = "${var.db_instance_name}"
  database_version = "MYSQL_5_7"
  zone = "${var.region_zone}"
  settings {
    # db-f1-micro tier is the smallest Cloud SQL Tier: 128 MiB RAM / 256 GiB Disk
    # Second-generation instance tiers are based on the machine
    # to list all available ones: gcloud sql tiers list
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "users" {
  name      = "${var.db_name}"
  instance  = "${google_sql_database_instance.master.name}"
}

resource "google_sql_user" "users" {
  name     = "${var.db_user}"
  instance = "${google_sql_database_instance.master.name}"
  password = "${var.db_password}"
}