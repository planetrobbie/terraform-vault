# sudo policy
resource "vault_policy" "admin" {
  name = "admin"

  policy = <<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF
}

# allow to access all db roles
resource "vault_policy" "db" {
  name = "db"

  policy = <<EOF
path "db/creds/*" {
   capabilities = ["read"]
}
EOF
}

# allow read only access to key/value secret engine mounted at kv/
# restrict access to kv/priv
resource "vault_policy" "dev" {
  name = "dev"

  policy = <<EOF
path "sys/policies/*" {
  capabilities = ["read", "list"] 
}

path "kv/*" {
  capabilities = ["read", "list"]
}

path "kv/priv" {
  capabilities = ["deny"]
}

path "db/creds/dev" {
   capabilities = ["read"]
}
EOF
}

# allow all operations on kv/
# restrict access to kv/priv
resource "vault_policy" "ops" {
  name = "ops"

  policy = <<EOF
path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list"] 
}

path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/priv" {
  capabilities = ["deny"]
}

path "db/creds/ops" {
   capabilities = ["read"]
}
EOF
}

resource "vault_policy" "pki_int" {
  name = "pki"

  policy = <<EOF
path "pki_int/issue/*" {
  capabilities = ["create", "update"]
}

path "pki_int/certs" {
  capabilities = ["list"]
}

path "pki_int/revoke" {
  capabilities = ["create", "update"]
}

path "pki_int/tidy" {
  capabilities = ["create", "update"]
}

path "pki/cert/ca" {
  capabilities = ["read"]
}

path "auth/token/renew" {
  capabilities = ["update"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF
}


# This creates a policy for k8s pods
resource "vault_policy" "k8s-acl" {
  count = "${var.enable_auth_k8s}"
  name = "k8s-acl"

  policy = <<EOF
path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "db/creds/dev" {
  capabilities = ["read"]
}
path "pki_int/issue/*" {
  capabilities = ["create", "update"]
}
EOF
}