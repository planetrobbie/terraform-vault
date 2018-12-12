provider "vault" {
  address = "${var.vault_addr}"
}

provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
}

# Enable required Google Cloud API
resource "google_project_services" "project" {
  project = "${var.project_name}"
  services = [
    "cloudapis.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "datastore.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "sqladmin.googleapis.com",
    "sql-component.googleapis.com",
    "clouddebugger.googleapis.com",
    "cloudtrace.googleapis.com",
    "bigquery-json.googleapis.com",
  ]
}

data "vault_generic_secret" "app_secret" {
  path = "kv/app_secret"
}

# Adding a policy
resource "vault_policy" "policy_from_terraform_provider" {
  name = "policy_from_terraform_provider"

  policy = <<EOF
path "kv/*" {
        policy = "read"
}
EOF
}
