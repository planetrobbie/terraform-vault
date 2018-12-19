# Demonstrate Terraform Vault provider

# Demo Snippets built by this repository

- userpass auth backend
    + user admin associated with admin policy
        * vault superuser
    + user ops associated with ops policy
        * can edit policies
        * can access kv/ apart from kv/priv
        * can get read access to all databases
    + user dev associated with dev policy
        * can consume static & dynamic secrets
        * apart from kv/priv
        * can get read/write access to a specific db
    
- Database Secret Engine
    + Cloud SQL MySQL Instance provisioned on GCP
    + Secret Backend mounted
    + 

resource "google_project" "project" {
  name = "${var.project_name}"
  project_id = "${random_id.id.hex}"
  billing_account = "${var.billing_account}"
  org_id = "${var.org_id}"
}
    + creating MySQL managed service on GCP

# Teraform Enteprise Workspace setup

## Variables

You need the following variable to be set, it's just an example, update it according to your needs:

        vault_addr: <VAULT_API_ADDR>
        vault_token: <SEN-SI-TI-VE>
        region: <GCP_REGION>
        region_zone: <GCP_ZONE>
        project_name: <GCP_PROJECT_NAME>
        dns_zone: <GCP_ZONE_WHERE_TO_CREATE_DNS_ENTRIES>
        dns_domain: <GCP_DOMAIN_NAME>
        ssh_user: <SSH_USER_TO_CONNECT_TO_INSTANCES>
        priv_key: <USED_TO_REMOTE_EXEC>
        userpass_password: <VAULT_USERPASS_AUTH_PASSWORD_FOR_ALL_USERS>
        db_password: <DB_INSTANCE_PASSWORD>
        db_bookshelf_password: <BOOKSHELF_SENSITIVE_PWD>


Note: Make sure you end your `dns_domain` by a dot at the end !

## Environment Variables

Some environment variables also need to be set

        GOOGLE_CREDENTIALS: <JSON_SENSITIVE_ACCESS_KEY>

To be able to destroy the deployment, you can also add

        CONFIRM_DESTROY: 1

## Certificate Chain

Before Applying this repo make sure you update `files/ca.crt` to your own Certificate Chain if your Vault certificate isn't signed by [Let's Encrypt](https://letsencrypt.org/). Also setup the following environment variable to this file location:

        VAULT_CACERT: ./files/ca.cert

If you can't do that or if your certificate is self signed add the following Environment variable instead

        VAULT_SKIP_VERIFY: true

# Outputs

# Demo Flow

# Database

Generate read only Credentials for ops people

        vault read db/creds/ops

Generate read/write Credentials for dev people

        

You can watch user count in your MySQL DB:

        watch 'mysql -u vault-user -pvpass -D mysql -h 35.233.43.216 -e "select user from user;"'

# PKI - Consul-template - Vault Agent.

# GCP Auth

## IAM
## GCE


# Terraform Vault Provider improvement

- User/Userpass creation
- Transit key creation