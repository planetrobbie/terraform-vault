resource "vault_auth_backend" "gcp" {
  type = "gcp"
}

# Create a Service Account specifically for this IAM GCP Auth use case
resource "google_service_account" "vault-iam-auth" {
  account_id   = "${var.project_name}-vault-iam-auth"
  display_name = "${var.project_name} Vault IAM Auth Account"
}

# Assign Required Role to Service Account
resource "google_project_iam_member" "vault-iam-auth-token-creator-role" {
  project = "${project_id}"
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${project_id}-vault-iam-auth@sb-vault.iam.gserviceaccount.com"
}