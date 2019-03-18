variable "region" {
  description = "GCP region targeted"
  default     = "europe-west1"
}

variable "region_zone" {
  description = "GCP zone targeted"
  default     = "europe-west1-c"
}

variable "project_name" {
  description = "GCP project targeted"
}

### Vault Provider

variable "vault_addr" {
  description = "Vault API Address"
}

variable "vault_token" {
  description = "Vault Token"
}

### Auth

variable "userpass_password" {
  description = "vault userpass password"
  default     = "vpass"
}

### K8S Auth

variable "enable_auth_k8s" {
  description = "set to false to disable k8s cluster deployment and k8s auth use case"
  default     = true
}

variable "k8s_username" {
  default = "admin"
}

variable "k8s_password" {}

### MySQL Secret Engine

variable "enable_secret_engine_db" {
  description = "set to false to disable MySQL Secret Engine use case"
  default     = true
}

variable "db_instance_name" {
  description = "MySQL Database Instance Name"
  default     = "vault-mysql-instance"
}

variable "db_name" {
  description = "MySQL Database Instance Name"
  default     = "vault-db"
}

variable "db_user" {
  description = "MySQL Database Username"
  default     = "vault-user"
}

variable "db_password" {
  description = "MySQL Database Password"
}

variable "db_default_ttl" {
  description = "default TTL associated with dynamic MySQL credentials (seconds)"
  default     = "60"
}

variable "db_max_ttl" {
  description = "max TTL associated with dynamic MySQL credentials (seconds)"
  default     = "86400"
}

### KV Secret Engine

variable vault_kv_options {
  type = "map"

  default = {
    version = 1
  }
}

### Transit Secret Engine
variable "enable_secret_engine_transit" {
  description = "set to false to disable Transit Secret Engine use case"
  default     = true
}

### Bookshelf App

variable "db_bookshelf_password" {
  description = "password to access bookshelf db"
  default     = ""
}

### DNS 

# Google Cloud DNS Zone
variable "dns_zone" {
  description = "Google Cloud zone name to create"
}

# Google Cloud DNS Domain
variable "dns_domain" {
  description = "DNS Domain where to find Vault and Consul servers"
}

# DNS TTL
variable "ttl" {
  description = "DNS ttl of entry"
  default     = "300"
}

### Remote-exec [SSH]

variable ssh_user {
  description = "users to connect to instances thru SSH"
  default     = "sebastien"
}

variable priv_key {
  description = "private key to connect to Vault Instances."
}
