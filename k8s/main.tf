provider "kubernetes" {
  host     = "${var.k8s_host}"
  username = "${var.k8s_username}"
  password = "${var.k8s_password}"

  client_certificate     = "${base64decode(var.k8s_client_certificate)}"
  client_key             = "${base64decode(var.k8s_client_key)}"
  cluster_ca_certificate = "${base64decode(var.k8s_cluster_ca_certificate)}"
}

# https://www.vaultproject.io/docs/auth/gcp.html
resource "vault_auth_backend" "k8s" {
  count = "${var.enabled}"
  type = "kubernetes"
}

resource "kubernetes_service_account" "vault-auth" {
  count = "${var.enabled}"
  metadata {
    name = "vault-auth"
  }
}

# Config map to store Vault address
resource "kubernetes_config_map" "vault-address" {
  count  = "${var.enabled}"
  metadata {
    name = "vault"
  }

  data {
    vault_addr = "${var.vault_addr}"
  }
}

resource "vault_kubernetes_auth_backend_role" "k8s-role" {
  count                            = "${var.enabled}"
  backend                          = "${vault_auth_backend.k8s.path}"
  role_name                        = "k8s-role"
  bound_service_account_names      = ["default"]
  bound_service_account_namespaces = ["default"]
  ttl                              = "3600"
  policies                         = ["default", "k8s"]
}