#output "bookshelf" {
#  description = "secret out of our Vault"
#  value = "${data.vault_generic_secret.bookshelf.data["username"]}"
#}

output "v1_addrs" {
  value = "${data.dns_a_record_set.v1.addrs}"
}

output "v2_addrs" {
  value = "${data.dns_a_record_set.v2.addrs}"
}

#####################################################################
# Output for Google Cloud MySQL Instance
#####################################################################
output "mysql_connection_string" {
  value = "${var.enable_secret_engine_db != 0 ? format("mysql://%s:%s@%s:3306/%s", var.db_user, var.db_password, google_sql_database_instance.master.ip_address.0.ip_address, var.db_name) : "Database secret engine not enabled"}"
}

#####################################################################
# Output for Google Cloud GKE Cluster
#####################################################################
output "client_certificate" {
  value     = "${google_container_cluster.primary.master_auth.0.client_certificate}"
  sensitive = true
}

output "client_key" {
  value     = "${google_container_cluster.primary.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "host" {
  value     = "${google_container_cluster.primary.endpoint}"
  sensitive = true
}