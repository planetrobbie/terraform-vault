# Vault Demo as a Service built using [Vault Terraform provider](https://www.terraform.io/docs/providers/vault/)

# Snippets built by this repository

## Auth backends

- [Username & Password](https://www.vaultproject.io/docs/auth/userpass.html) auth backend
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
- [Google Cloud Platform (GCP)](https://www.vaultproject.io/docs/auth/gcp.html) Auth backend
    + using both IAM and GCE roles.
- [AppRole](https://www.vaultproject.io/docs/auth/approle.html) Auth Backend

## Secret Engines

- [Database](https://www.vaultproject.io/docs/secrets/databases/mysql-maria.html) Secret Engine
    + Cloud SQL Manage Services, MySQL Instance provisioned on GCP
    + Secret Backend mounted
    + ops and dev roles created to do read/write or read only operations on MySQL database.

- [GCP Secrets Engine](https://www.vaultproject.io/docs/secrets/gcp/index.html)
    + Service Account key generation (limited to 10 per account)
    + OAuth token generation

- [PKI](https://www.vaultproject.io/docs/secrets/pki/index.html) Secrets Engine
    + certificate auto renewal with [Vault agent](https://www.vaultproject.io/docs/agent/) and [Consul-template](https://github.com/hashicorp/consul-template) for NGINX 

# Teraform Enteprise Workspace setup

You can provision easily all the use cases up above on top of your Vault/Consul cluster deployed automatically itself using [terraform-gcp-hashistack](https://github.com/planetrobbie/terraform-gcp-hashistack) repository with Terraform.

Create a Workspace linked to a fork of this repository with the following specifications.

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

## Provision

You can now plan/apply your workspace, once it's done test the different use cases following our demoflow detailed below.

# Demo Flow

## Database

First login to your Vault cluster from your first vault server node
    
        ssh -i ~/.ssh/id_rsa <SSH_USER>@v1.<YOUR_DOMAIN>
        vault login -method=userpass username=admin

Use the password configured in your Terraform Workspace variable `userpass_password`

You can now generate read only MySQL credentials for ops people

        vault read db/creds/ops

Or generate read/write Credentials for dev people

        vault read db/creds/dev

You can watch user count in your MySQL DB:

        watch 'mysql -u vault-user -p<db_password> -D mysql -h db.<DOMAIN_NAME> -e "select user from user;"'

# PKI - Consul-template - Vault Agent.

Before you run the demo, make sure ou have to inject you CA CERT to your demo machine. Grab it with

    curl -s https://vault.<DNS_DOMAIN>/v1/pki/ca/pem > pki_ca.pem

Now you can renew NGINX Certificate once with

    sudo /usr/local/bin/consul-template -vault-ssl-ca-cert=/etc/vault/tls/ca.crt -config='/etc/consul-template.d/pki-demo.hcl' -once

To Constantly renew start consul-template service

    sudo systemctl start consul-template

Show web server runnning expired and updated certificate

    watch -n 5 "curl --cacert /home/<SSH_USER>/pki/ca.pem  --insecure -v https://www.<DOMAIN_NAME> 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'"

You can also simply connect using your browser

    https://www.<DNS_DOMAIN>

# GCP Auth

## IAM

    to authenticate thru IAM Service Account

    vault login -method=gcp role="iam" jwt_exp="15m" credentials=@/home/<SSH_USER>/creds.json

## GCE

After generating a token from within a GCP Instance like `v1`, your first vault server, which is in the correct zone `europe-west1-c` with the correct lable `auth:yes` generate a JWT Token like this

    export JWT_TOKEN="$(curl -sS -H 'Metadata-Flavor: Google' --get --data-urlencode 'audience=http://vault/gce' --data-urlencode 'format=full' 'http://metadata/computeMetadata/v1/instance/service-accounts/default/identity')"

Now you can authenticate to Vault using this token

    vault write auth/gcp/login role="gce" jwt="$JWT_TOKEN"

Remove the `auth:yes` label, run the authentication again, to show it fails with the message

    Error writing data to auth/gcp/login: Error making API request.

    URL: PUT https://v1.<DOMAIN_NAME>:8200/v1/auth/gcp/login
    Code: 400. Errors:

    * instance missing bound label "auth:yes"

# GCP Secret Engine

## Service Account

Generate Service account key

    vault read gcp/key/key

Use base64 to decode your key

    echo 'PUT YOUR KEY HERE' | base64 --decode

# Instance auth 

Generate OAuth GCP token
    
    vault read gcp/token/token

A storage bucket has been specifically created to demo the validity of your generated token. Try to upload a file to your bucket using the generated token

    cd ~
    curl -X POST --data-binary @playbook.yml -H "Authorization: Bearer <PUT_TOKEN_HERE>" -H "Content-Type: text/html" "https://www.googleapis.com/upload/storage/v1/b/<PROJECT_NAME>/o?uploadType=media&name=playbook.yml"

You should have the `playbook.yml` file uploaded to your Google Project bucket.

# Commands Snippets

To help you demo a lot more use cases, many command are available thru [Pet](https://github.com/knqyf263/pet) a Simple command-line snippet manager, written in Go.

To access the list of snippets and search within them just use `CTRL+s`.

# Terraform Vault Provider improvement

HashiCorp is currently working on improving support on some auth and secret engines. Things that I'd like to see supported in the next releases are

- User/Userpass creation
- Transit key creation
- Google Secret Engine
- PKI Secret Engine
