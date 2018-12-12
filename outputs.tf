output "app_secret" {
  description = "secret out of our Vault"
  value = "${data.vault_generic_secret.app_secret.data["username"]}"
}

output "v1_addrs" {
  value = "${data.dns_a_record_set.v1.addrs}"
}

output "v2_addrs" {
  value = "${data.dns_a_record_set.v2.addrs}"
}

output "mysql_ip" {
  value = "mysql://${var.db_user}:${var.db_password}@${google_sql_database_instance.master.ip_address.0.ip_address}:3306/${var.db_name}"
}