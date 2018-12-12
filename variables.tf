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