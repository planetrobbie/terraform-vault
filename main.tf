provider "vault" {
  address = "${var.vault_addr}"
}

provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
}

# Enable Google Cloud API - required for `vault-db` database creation.
resource "google_project_service" "project" {
  project = "${var.project_name}"
  service = "sql-component.googleapis.com"
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
