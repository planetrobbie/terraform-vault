resource "vault_auth_backend" "gcp" {
  type = "gcp"
}

# Create a Service Account specifically for this IAM GCP Auth use case
resource "google_service_account" "vault-iam-auth" {
  account_id   = "${var.project_name}-vault-iam-auth"
  display_name = "${var.project_name} Vault IAM Auth Account"
}