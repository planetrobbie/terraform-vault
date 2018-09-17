output "app_secret" {
  value = "${data.vault_generic_secret.app_secret.data["username"]}"
}
