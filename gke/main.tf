# GKE Cluster
resource "google_container_cluster" "primary" {
  count = "${var.enabled}"
  name               = "${var.cluster_name}"
  # If we want a regional cluster, should we be looking at https://cloud.google.com/kubernetes-engine/docs/concepts/regional-clusters#regional
  #  region = "${var.region}"
  zone               = "${var.main_zone}"
  additional_zones   = "${var.additional_zones}"
  # Node count for every region
  initial_node_count = 1
  project            = "${var.project_name}"
  remove_default_node_pool = true
  enable_legacy_abac = true

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  master_auth {
    username = "${var.k8s_username}"
    password = "${var.k8s_password}"
  }
}

# GKE Node Pool
resource "google_container_node_pool" "nodepool" {
  count = "${var.enabled}"
  name               = "${var.cluster_name}nodepool"
  zone               = "${var.main_zone}"
  cluster            = "${google_container_cluster.primary.name}"
  node_count         = "${var.node_count}"

  autoscaling {
    min_node_count = "${var.min_node_count}"
    max_node_count = "${var.max_node_count}"
  }
  
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/sqlservice.admin",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/projecthosting",
    ]
  }
}