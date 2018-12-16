resource "vault_mount" "transit" {
  count = "${var.enable_secret_engine_transit}"
  path        = "transit"
  type        = "transit"
  description = "Encryption as a Service engine"
}

# create a transit key
resource "vault_generic_secret" "key" {
  path = "transit/keys/key"
  data_json = <<EOT
{
  "exportable": true
}
EOT
}

# allow key deletion
# following operation happens but 
resource "vault_generic_secret" "key-config" {
  path = "transit/keys/key/config"
  data_json = <<EOT
{
  "deletion_allowed": true
}
EOT
}