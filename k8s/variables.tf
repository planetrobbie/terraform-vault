variable "enabled" {
  description = "set to false to disable k8s cluster deployment and k8s auth use case"
}
variable "k8s_username" {
  default = "admin"
}
variable "k8s_password" {}
variable "k8s_host" {}
variable "k8s_client_certificate" {}
variable "k8s_client_key" {}
variable "k8s_cluster_ca_certificate" {}