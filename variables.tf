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
  default = "vault-mysql-instance"
}

variable "db_name" {
  description = "MySQL Database Instance Name"
  default = "vault-db"
}

variable "db_user" {
  description = "MySQL Database Username"
  default = "vault-user"
}

variable "db_password" {
  description = "MySQL Database Password"
  default = "vpass"
}

variable "db_default_ttl" {
  description = "default TTL associated with dynamic MySQL credentials"
  default = "1m"
}

variable "db_max_ttl" {
  description = "max TTL associated with dynamic MySQL credentials"
  default = "24h"
}

### DNS 

# Google Cloud DNS Domain
variable "dns_domain" {
  description = "DNS Domain where to find Vault and Consul servers"
}