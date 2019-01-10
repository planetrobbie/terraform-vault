
### AUTH
# Documentation
# https://www.vaultproject.io/docs/auth/gcp.html
resource "vault_auth_backend" "gcp" {
  type = "gcp"
}

# Create a Service Account for GCP Auth and Secret Engine use cases
resource "google_service_account" "vault-iam-auth" {
  account_id   = "${var.project_name}-vault-iam-auth"
  display_name = "${var.project_name} Vault IAM Auth Account"
}

# Assign Required Role to Service Account for GCP AUTH
# IAM roles documented @ https://cloud.google.com/iam/docs/understanding-roles
resource "google_project_iam_member" "vault-iam-auth-token-creator-role" {
  project = "${var.project_name}"
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${var.project_name}-vault-iam-auth@${var.project_name}.iam.gserviceaccount.com"
}

# Assign Required Role to Service Account for GCP Secret Engine
resource "google_project_iam_member" "vault-iam-auth-account-create" {
  project = "${var.project_name}"
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${var.project_name}-vault-iam-auth@${var.project_name}.iam.gserviceaccount.com"
}

# Assign Required Role to Service Account for GCP Secret Engine - Token - demo on storage bucket
resource "google_project_iam_member" "vault-iam-auth-storage-admin" {
  project = "${var.project_name}"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${var.project_name}-vault-iam-auth@${var.project_name}.iam.gserviceaccount.com"
}

# Assign Required Role to Service Account for GCP AUTH
resource "google_project_iam_member" "vault-iam-auth-key-admin" {
  project = "${var.project_name}"
  role    = "roles/iam.serviceAccountKeyAdmin"
  member  = "serviceAccount:${var.project_name}-vault-iam-auth@${var.project_name}.iam.gserviceaccount.com"
}

# Assign Required Role to Service Account for GCP AUTH - GCE
# Compute roles documented @ https://cloud.google.com/compute/docs/access/iam
resource "google_project_iam_member" "vault-iam-auth-compute-viewer" {
  project = "${var.project_name}"
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${var.project_name}-vault-iam-auth@${var.project_name}.iam.gserviceaccount.com"
}

# This should be fine grained.
resource "google_project_iam_member" "vault-iam-auth-project-owner" {
  project = "${var.project_name}"
  role    = "roles/owner"
  member  = "serviceAccount:${var.project_name}-vault-iam-auth@${var.project_name}.iam.gserviceaccount.com"
}

# GCP AUTH IAM Role
resource "vault_gcp_auth_backend_role" "gcp" {
    role                   = "iam"
    type                   = "iam"
    backend                = "${vault_auth_backend.gcp.path}"
    project_id             = "${var.project_name}"
    bound_service_accounts = ["${var.project_name}-vault-iam-auth@${var.project_name}.iam.gserviceaccount.com"]
    policies               = ["dev", "ops"]
}

# Create a JSON Key for Vault IAM AUTH Service Account
resource "google_service_account_key" "vault-iam-auth-key" {
  service_account_id = "${google_service_account.vault-iam-auth.name}"
}

# GCP AUTH GCE Role
resource "vault_gcp_auth_backend_role" "gce" {
    role                   = "gce"
    type                   = "gce"
    backend                = "${vault_auth_backend.gcp.path}"
    project_id             = "${var.project_name}"
    bound_zones            = ["${var.region_zone}"]
    bound_labels           = ["auth:yes"]
    policies               = ["dev", "ops"]
}

# GCP Bucket for GCP Secret Engine demo
resource "google_storage_bucket" "demo_bucket" {
  name          = "${var.project_name}"
  location      = "EU"
  force_destroy = "true"
}

# GCP Bucket for Bookshelf image storage
resource "google_storage_bucket" "bookshelf_bucket" {
  name          = "bookshelf-k8s-demo"
  location      = "EU"
  force_destroy = "true"
}

# Open up image storage to public read
resource "google_storage_bucket_acl" "image-store-acl" {
  bucket = "${google_storage_bucket.bookshelf_bucket.name}"

  default_acl = "publicread"
}

### SECRETS
# Documentation
# https://www.vaultproject.io/docs/secrets/gcp.html
# Unfortunately as of Dec, 2018 no support for GCP Secret Engine apart from below.

resource "vault_mount" "gcp" {
  path        = "gcp"
  type        = "gcp"
  description = "This is a Google Cloud Platform secret engine"
}

# Clone Vault official docker image repository
resource "google_sourcerepo_repository" "docker-vault" {
  count   = "${var.enable_auth_k8s}"
  name    = "docker-vault"
  project = "${var.project_name}"
}

# Clone Bookshel application repository
resource "google_sourcerepo_repository" "bookshelf" {
  count   = "${var.enable_auth_k8s}"
  name    = "bookshelf"
  project = "${var.project_name}"
}

# Setup a trigger to build automatically Vault Docker image upon each commit on master.
resource "google_cloudbuild_trigger" "build_trigger" {
  count = "${var.enable_auth_k8s}"
  project  = "${var.project_name}"
  trigger_template {
    branch_name = "master"
    project     = "${var.project_name}"
    repo_name   = "docker-vault"
  }
  build {
    images = ["gcr.io/$PROJECT_ID/$REPO_NAME:latest"]
    step {
      name = "gcr.io/cloud-builders/docker"
      args = "build -t gcr.io/$PROJECT_ID/$REPO_NAME:latest 0.X"
    }
  }
}

# Setup a trigger to build automatically Vault Docker image upon each commit on master.
resource "google_cloudbuild_trigger" "build_trigger_bookshelf" {
  count = "${var.enable_auth_k8s}"
  project  = "${var.project_name}"
  trigger_template {
    branch_name = "master"
    project     = "${var.project_name}"
    repo_name   = "bookshelf"
  }
  build {
    images = ["gcr.io/$PROJECT_ID/$REPO_NAME:latest"]
    step {
      name = "gcr.io/cloud-builders/docker"
      args = "build -t gcr.io/$PROJECT_ID/$REPO_NAME:latest container-engine"
    }
  }
}

# Persistent disk for Jenkins Home Folder
resource "google_compute_disk" "jenkins-home" {
  name  = "jenkins-home"
  size  = 10
  zone  = "${var.region_zone}"
}