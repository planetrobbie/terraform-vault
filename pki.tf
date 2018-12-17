# root Certificate Authority Secret Engine
resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "PKI as a Service engine"
}

# Intermediate Certificate Authoriry Secret Engine
resource "vault_mount" "pki_int" {
  path        = "pki_int"
  type        = "pki"
  description = "PKI as a Service engine"
}