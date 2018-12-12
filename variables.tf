variable "region" {
  description = "GCP region targeted"
  default = "europe-west1"
}

variable "region_zone" {
  description = "GCP zone targeted"
  default = "europe-west1-c"
}

variable "project_name" {
  description = "GCP project targeted"
}

variable "vault_addr" {
  description = "Vault API Address"
}

### MySQL Database

variable "db_instance_name" {
  description = "MySQL Database Instance Name"
  default = "vault_mysql_instance"
}

variable "db_name" {
  description = "MySQL Database Instance Name"
  default = "vault_db"
}

variable "db_user" {
  description = "MySQL Database Username"
  default = "vault_user"
}

variable "db_password" {
  description = "MySQL Database Password"
  default = "vpass"
}