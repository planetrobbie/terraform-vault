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
}
EOT
}

#  "type": "aes256-gcm96",
#  "deletion_allowed": true
#  "exportable": true,
#  "allow_plaintext_backup": true,
#  "derived": true,
#  "exportable": true,
#  "supports_decryption": true,
#  "supports_derivation": true,
#  "supports_encryption": true,
#  "supports_signing": true,
#
#
# allow key deletion
# following operation happens but errors occurs.
#resource "vault_generic_secret" "key-config" {
#  path = "transit/keys/key/config"
#  data_json = <<EOT
#{
#  "deletion_allowed": true
#}
#EOT
#}