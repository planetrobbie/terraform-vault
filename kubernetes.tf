module "gke" {
  source  = "./gke"
  enabled = "${var.enable_auth_k8s}"

  project_name  = "${var.project_name}"
  region        = "${var.region}"
  k8s_username      = "${var.k8s_username}"
  k8s_password      = "${var.k8s_password}"
}

module "k8s" {
  source   = "./k8s"
  enabled  = "${var.enable_auth_k8s}"
  k8s_host     = "${module.gke.host[0]}"
  k8s_username = "${var.k8s_username}"
  k8s_password = "${var.k8s_password}"

  k8s_client_certificate     = "${module.gke.client_certificate}"
  k8s_client_key             = "${module.gke.client_key}"
  k8s_cluster_ca_certificate = "${module.gke.cluster_ca_certificate}"

  vault_addr                 = "${var.vault_addr}"
}