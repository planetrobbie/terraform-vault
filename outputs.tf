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

output "mysql_connection_string" {
  value = "${var.enable_secret_engine_db != 0 ? "mysql://var.db_user:var.db_password@google_sql_database_instance.master.ip_address.0.ip_address:3306/var.db_name" : "Database secret engine not enabled"}"
}