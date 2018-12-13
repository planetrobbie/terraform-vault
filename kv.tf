resource "vault_mount" "kv" {
  path        = "kv"
  type        = "kv"
  description = "This is a key/value secret backend"
  options     = "${var.vault_kv_options}"
}