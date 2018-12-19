provider "vault" {
  address = "${var.vault_addr}"
  token = "${var.vault_token}"
}

provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
}

provider "dns" {
}

# COMMENTED OUT - as of TF 0.11.10 and Google provider 1.19.1 services are enabled asynchrously which cause issues
# TF wait wait while API are correctly enabled = bad detection it seems !!!
# So until it is fixed read our [GCP Getting Started Guide](https://github.com/planetrobbie/terraform-gcp-hashistack/blob/master/GCP.md) to see how to enable GCP APIs.
#
# Enable required Google Cloud API
#resource "google_project_services" "project" {
#  project = "${var.project_name}"
#  services = [
#    "cloudapis.googleapis.com",
#    "cloudkms.googleapis.com",
#    "cloudresourcemanager.googleapis.com",
#    "compute.googleapis.com",
#    "datastore.googleapis.com",
#    "dns.googleapis.com",
#    "iam.googleapis.com",
#    "iamcredentials.googleapis.com",
#    "logging.googleapis.com",
#    "monitoring.googleapis.com",
#    "oslogin.googleapis.com",
#    "servicemanagement.googleapis.com",
#    "serviceusage.googleapis.com",
#    "storage-api.googleapis.com",
#    "storage-component.googleapis.com",
#    "sqladmin.googleapis.com",
#    "sql-component.googleapis.com",
#    "cloudresourcemanager.googleapis.com"
#  ]
#}