provider "vault" {
  address = "https://vault-gcp.yet.org"
}

data "vault_generic_secret" "app_secret" {
  path = "kv/app_secret"
}

# Adding a policy
resource "vault_policy" "policy_from_terraform_provider" {
  name = "policy_from_terraform_provider"

  policy = <<EOF
path "kv/*" {
        policy = "read"
}
EOF
}
