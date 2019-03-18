variable "enabled" {
  description = "set to false to disable k8s cluster deployment and k8s auth use case"
}

variable "project_name" {
  description = "GCP project targeted"
}

variable "region" {}

variable "main_zone" {
  default = "europe-west1-c"
}

variable "additional_zones" {
  description = "k8s nodes spread out to these additional zones"

  default = [
    "europe-west1-b",
    "europe-west1-d",
  ]
}

variable "node_count" {
  description = "Number of nodes per NodePool"
  default     = "1"
}

variable "min_node_count" {
  description = "Minimum number of nodes in the NodePool, used for autoscaling. Must be >=1 and <= max_node_count"
  default     = "1"
}

variable "max_node_count" {
  description = "Maximum number of nodes in the NodePool, used for autoscaling. Must be >= min_node_count"
  default     = "4"
}

variable "cluster_name" {
  description = "name of your GKE cluster"
  default     = "demo-k8s-cluster"
}

variable "k8s_username" {
  default = "admin"
}

variable "k8s_password" {}
