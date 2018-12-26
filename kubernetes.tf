module "gke" {
  source   = "./gke"
  project  = "${var.project_name}"
  region   = "${var.region}"
  username = "${var.username}"
  password = "${var.password}"
}

module "k8s" {
  source   = "./k8s"
  host     = "${module.gke.host}"
  username = "${var.username}"
  password = "${var.password}"

  client_certificate     = "${module.gke.client_certificate}"
  client_key             = "${module.gke.client_key}"
  cluster_ca_certificate = "${module.gke.cluster_ca_certificate}"
}