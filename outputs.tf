output "app_secret" {
  description = "secret out of our Vault"
  value = "${data.vault_generic_secret.app_secret.data["username"]}"
}

output "config_file {
  description = "rendered template which consume Vault secrets"
  value = "${data.template_file.credentials.rendered}"
}`  
