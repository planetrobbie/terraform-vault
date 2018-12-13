resource "vault_mount" "kv" {
  path        = "kv"
  type        = "kv"
  description = "This is key/value secret backend"
}