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
  "exportable": true,
  "allow_plaintext_backup": true,
  "deletion_allowed": true,
  "derived": true,
  "exportable": true,
  "min_available_version": 0,
  "min_decryption_version": 1,
  "min_encryption_version": 0,
  "supports_decryption": true,
  "supports_derivation": true,
  "supports_encryption": true,
  "supports_signing": true,
  "type": aes256-gcm96
}
EOT
}

# allow key deletion
# following operation happens but 
#resource "vault_generic_secret" "key-config" {
#  path = "transit/keys/key/config"
#  data_json = <<EOT
#{
#  "deletion_allowed": true
#}
#EOT
#}