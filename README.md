# Vault Demo as a Service (DaaS)

# built with

- [HashiCorp Vault](https://www.vaultproject.io/)
- [HashiCorp Terraform](https://www.terraform.io/)
- [terraform-gcp-hashistack repository](https://github.com/planetrobbie/terraform-gcp-hashistack)
- [Vault Terraform provider](https://www.terraform.io/docs/providers/vault/)
- [Google Cloud Terraform provider](https://www.terraform.io/docs/providers/google/index.html)
- [Kubernetes Terraform Provider](https://www.terraform.io/docs/providers/kubernetes/)
- [DNS Terraform Provider](https://www.terraform.io/docs/providers/dns/)
- [Google Cloud Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/)
- [Google Cloud SQL](https://cloud.google.com/sql/docs/)
- [Google Cloud Build](https://cloud.google.com/cloud-build/)
- [Google Cloud Container Registry](https://cloud.google.com/container-registry/)
- [Google Cloud Storage](https://cloud.google.com/storage/)

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
- [Google Cloud Platform (GCP)](https://www.vaultproject.io/docs/auth/gcp.html) Auth method
    + using both IAM and GCE roles.
- [AppRole](https://www.vaultproject.io/docs/auth/approle.html) Auth method
- [Kubernetes](https://www.vaultproject.io/docs/auth/kubernetes.html) Auth method

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
    k8s_password: <K8S_CLUSTER_PASSWORD_AT_LEAST_16_CHARS>

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

## Provision Demo as Service environment.

You can now plan/apply your workspace, once it's done test the different use cases following our demo flow detailed below.

# Demo Flow

## Database Secret Engine

First login to your Vault cluster from your first vault server node
    
    $ ssh -i ~/.ssh/id_rsa <SSH_USER>@v1.<YOUR_DOMAIN>
    $ vault login -method=userpass username=admin

Use the password configured in your Terraform Workspace variable `userpass_password`

You can now generate read only MySQL credentials for ops people

    $ vault read db/creds/ops

Or generate read/write Credentials for dev people

    $ vault read db/creds/dev

You can watch user count in your MySQL DB:

    $ watch 'mysql -u vault-user -p<DB_PASSWORD> -D mysql -h db.<DOMAIN_NAME> -e "select user from user;"'

## PKI - Consul-template - Vault Agent.

Before you run the demo, make sure ou have to inject you CA CERT to your demo machine. Grab it with

    $ curl -s https://vault.<DNS_DOMAIN>/v1/pki/ca/pem > pki_ca.pem

On MacOS you just have to double click on the file you just downloaded and trust the corresponding certificate authority.

Now you can renew NGINX Certificate once with

    $ sudo /usr/local/bin/consul-template -vault-ssl-ca-cert=/etc/vault/tls/ca.crt -config='/etc/consul-template.d/pki-demo.hcl' -once

To Constantly renew start consul-template service

    $ sudo systemctl start consul-template

Show web server runnning expired and updated certificate

    $ watch -n 5 "curl --cacert /home/<SSH_USER>/pki/ca.pem  --insecure -v https://www.<DOMAIN_NAME> 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'"

You can also simply connect using your browser

    https://www.<DNS_DOMAIN>

## GCP Auth

### IAM

    to authenticate thru IAM Service Account

    $ vault login -method=gcp role="iam" jwt_exp="15m" credentials=@/home/<SSH_USER>/creds.json

### GCE

After generating a token from within a GCP Instance like `v1`, your first vault server, which is in the correct zone `europe-west1-c` with the correct lable `auth:yes` generate a JWT Token like this

    $ export JWT_TOKEN="$(curl -sS -H 'Metadata-Flavor: Google' --get --data-urlencode 'audience=http://vault/gce' --data-urlencode 'format=full' 'http://metadata/computeMetadata/v1/instance/service-accounts/default/identity')"

Now you can authenticate to Vault using this token

    $ vault write auth/gcp/login role="gce" jwt="$JWT_TOKEN"

Remove the `auth:yes` label, run the authentication again, to show it fails with the message

    Error writing data to auth/gcp/login: Error making API request.

    URL: PUT https://v1.<DOMAIN_NAME>:8200/v1/auth/gcp/login
    Code: 400. Errors:

    * instance missing bound label "auth:yes"

## Kubernetes Auth

This code install and configure `kubectl` for the deployed Google Cloud Kubernetes Cluster (GKE). You can check it is working properly by running

    $ kubectl cluster-info

We've also prepared all the required components, service account, Cluster role binding, config maps for Vault Kubernetes Auth method to work without any more effort on your side.

You can check all has been correctly configured like this

    $ kubectl get serviceaccount | grep vault-auth
    $ kubectl get clusterrolebinding | grep tokenreview
    $ kubectl get configmap vault -o yaml
    $ vault read auth/kubernetes/config

### Authenticate from a Vault container

It also fetch source and build an official Vault docker container. Make sure the underlying storage bucket is open to public consumption with

    $ gsutil iam ch allUsers:objectViewer gs://artifacts.<PROJECT_NAME>.appspot.com/

To check everything works as expected, you can launch a Vault docker container that has been built by this Terraform code. From instance `v1` run

    $ kubectl apply -f ~/k8s/dep-vault.yaml
    deployment.extensions/vault created

Check your pod is running

    $ kubectl get po
    NAME                     READY   STATUS    RESTARTS   AGE
    vault-658995c69c-gw7h2   1/1     Running   0          30s

Enter your pod
    
    $ kubectl exec -it $(kubectl get pod -l "app=vault" -o jsonpath='{.items[0].metadata.name}') -- /bin/sh

From within the pod, get your k8s token

    $ JWT=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

Authenticate to Vault using that token

    $ vault write -tls-skip-verify auth/kubernetes/login role=k8s-role jwt=$JWT
    Key                                       Value
    ---                                       -----
    token                                     s.5tUFMFKshInt2knZZ3omSAVf
    token_accessor                            81UGJ0zssFAKzl4HVQ6vS44L
    token_duration                            1h
    token_renewable                           true
    token_policies                            ["default" "k8s"]
    identity_policies                         []
    policies                                  ["default" "k8s"]
    token_meta_role                           k8s-role
    token_meta_service_account_name           default
    token_meta_service_account_namespace      default
    token_meta_service_account_secret_name    default-token-5vgcs
    token_meta_service_account_uid            42dcea27-0917-11e9-855c-42010af0006e

As you can see above you got back a token associated with our k8s policies.

### Bookshelf - Dynamic Database Credentials demo

`terraform-vault` code configured a Google Cloud Build trigger which automatically rebuild our demo application container, bookshelf, after each commit to the master branch of the repository. You can check that bookshelf container has been correctly rebuild by going on the Cloud Registry of your Google Cloud Project.

Once Bookshelf container is built, you can deploy this application to your Kubernetes cluster

    $ kubectl apply -f ~/k8s/bookshelf-frontend.yaml
 
Check all pods are running

    $ kubectl get po
    NAME                       READY   STATUS    RESTARTS   AGE
    bookshelf-frontend-5kdhz   1/1     Running   0          41s
    bookshelf-frontend-jl8dw   1/1     Running   0          41s
    bookshelf-frontend-mjqkh   1/1     Running   0          41s

Get Bookshelf Service Details

    $ kubectl get services bookshelf-frontend
    NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
    bookshelf-frontend   LoadBalancer   10.43.243.23   35.189.239.48   80:32485/TCP   1m

You should now be able to access it on `http://<EXTERNAL_IP>` to add books to your library.

To terminate bookshelf application

    $ kubectl delete -f bookshelf-frontend.yaml

This section demonstrated how a Kubernetes Pod can authenticate to Vault to access secrets to connect to a Database.

You can get more details on the bookshelf application below:

https://cloud.google.com/python/getting-started/tutorial-app

Our application is connecting to a Google Cloud SQL instance using a dynamic credential from Vault DB Secret Engine. A Side car target Vault API to make sure bookshelf DB credentials stays valid throughout the lifecycle of it.

You can verify the current lease ID TTL by entering one of the container listed above and grabbing the `lease_id`

    $ kubectl exec -it bookshelf-frontend-5kdhz -- cat /etc/vault-assets/lease_id
    db/creds/dev/5WoOKWxwc3SLKoUEkgOswHhc

Exit the container to get target Vault API to gather details about it

    $ export TOKEN=`cat ~/.vault-token`    
    $ curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H "X-Vault-Token: $TOKEN" --data '{ "lease_id": "db/creds/dev/5WoOKWxwc3SLKoUEkgOswHhc"}' https://<VAULT_ADDRESS:PORT>/v1/sys/leases/lookup | jq .
    {
      "request_id": "60703585-7bef-8089-f693-25d4cf1834e7",
      "lease_id": "",
      "renewable": false,
      "lease_duration": 0,
      "data": {
        "expire_time": "2019-01-07T16:00:08.852131177Z",
        "id": "db/creds/dev/5WoOKWxwc3SLKoUEkgOswHhc",
        "issue_time": "2019-01-07T15:00:08.087493659Z",
        "last_renewal": "2019-01-07T15:00:08.85213134Z",
        "renewable": true,
        "ttl": 730
      },
      "wrap_info": null,
      "warnings": null,
      "auth": null
    }

As soon as the application is going away, the corresponding DB credentials will be revoked. Let's check that

    $ kubectl delete -f ~/k8s/bookshelf-frontend.yaml
    $ curl --cacert /etc/vault/tls/ca.crt -sS -X POST -H "X-Vault-Token: $TOKEN" --data '{ "lease_id": "db/creds/dev/5WoOKWxwc3SLKoUEkgOswHhc"}' https://<VAULT_ADDRESS:PORT>/v1/sys/leases/lookup | jq .
    {
      "errors": [
        "invalid lease"
      ]
    }

## CSI driver demo

At the last KubeCon event in Barcelona HashiCorp announced support for a [Container Storage Interface driver](https://github.com/deislabs/secrets-store-csi-driver/tree/master/pkg/providers/vault#prerequisites) that allows containers to mount secret as volumes. This section illustrate this new functionnality.

First you have to deploy the driver on your Kubernetes 1.13+ cluster (required to support CSI drivers).

    git clone https://github.com/deislabs/secrets-store-csi-driver.git
    cd secrets-store-csi-driver.git
    kubectl apply -f deploy/crd-csi-driver-registry.yaml
    kubectl apply -f deploy/rbac-csi-driver-registrar.yaml
    kubectl apply -f deploy/rbac-csi-attacher.yaml
    kubectl apply -f deploy/csi-secrets-store-attacher.yaml
    kubectl apply -f pkg/providers/vault/examples/secrets-store-csi-driver.yaml

Check that everything is running smoothly

    watch kubectl get po

You can now run our example nginx pod with the required Persistent Volume and Volume Claim as follows

    kubectl apply -f ~/k8s/pv-vault-csi.yaml; kubectl apply -f ~/k8s/pvc-vault-csi-static.yaml; kubectl apply -f ~/k8s/pod-nginx.yaml

Secret should now be mounted within our nginx pod below `/mnt/vault`

    kubectl exec -it nginx -- cat /mnt/vault/apikey

If that's not the case you can troubleshoot it by first identifying the nodes where nginx pod is running

    kubectl get pods -o wide
    csi-secrets-store-attacher-0 1/1 Running 0 3h19m 10.40.1.2 gke-demo-k8s-cluster-demo-k8s-cluster-d6d9a3b5-df96 <none> <none>
    csi-secrets-store-bl6rz 2/2 Running 0 3h19m 10.132.0.19 gke-demo-k8s-cluster-demo-k8s-cluster-a2e42959-07zv <none> <none>
    csi-secrets-store-k4p2m 2/2 Running 0 3h19m 10.132.0.17 gke-demo-k8s-cluster-demo-k8s-cluster-d6ab08a8-c6zv <none> <none>
    csi-secrets-store-t576h 2/2 Running 0 3h19m 10.132.0.20 gke-demo-k8s-cluster-demo-k8s-cluster-d6d9a3b5-df96 <none> <none>
    nginx 1/1 Running 0 16m 10.40.1.25 gke-demo-k8s-cluster-demo-k8s-cluster-d6d9a3b5-df96 <none> <none>

On my case it's running on `gke-demo-k8s-cluster-demo-k8s-cluster-d6d9a3b5-df96` so I can look at the corresponding pod logs, which is the csi driver daemon set running on this node.

    kubectl logs -f csi-secrets-store-t576h secrets-store

You should see something like that

    I0725 12:36:41.673174       1 provider.go:64] NewProvider
    I0725 12:36:41.680714       1 provider.go:283] vault: roleName k8s-csi
    I0725 12:36:41.680725       1 provider.go:289] vault: vault address     https://vault.prod.yet.org
    objectsStrings: [array:
      - |
        objectPath: "/apikey"
        objectName: "value"
        objectVersion: ""
    ]
    objects: [[objectPath: "/apikey"
    objectName: "value"
    objectVersion: ""
    ]]unmarshal object: [objectPath: "/apikey"
    objectName: "value"
    objectVersion: ""
    ]
    I0725 12:36:41.682431       1 provider.go:70] vault: reading jwt token.....
    I0725 12:36:41.682492       1 provider.go:113] vault: performing vault  login.....
    I0725 12:36:41.682633       1 provider.go:123] vault: vault address:    https://vault.prod.yet.org/v1/auth/kubernetes/login
    I0725 12:36:41.762511       1 provider.go:158] vault: getting secrets from  vault.....
    I0725 12:36:41.779062       1 provider.go:349] secrets-store csi driver wrote / apikey at /var/lib/kubelet/pods/d3479025-aed8-11e9-a1d5-42010a8400f2/volumes/    kubernetes.io~csi/pv-vault/mount
    I0725 12:36:41.779142       1 nodeserver.go:112] after  MountSecretsStoreObjectContent, notMnt: false
    I0725 12:36:41.779152       1 utils.go:102] GRPC response:

It helps identifying the problem which prevent the driver to mount the secret, it could be related to the policy which doesn't allow access, or the k8s role which is not correctly configured, etc.

By the way the k8s role should look like that

    vault read auth/kubernetes/role/k8s-csi
    Key                                 Value
    ---                                 -----
    bound_cidrs                         []
    bound_service_account_names         [csi-driver-registrar]
    bound_service_account_namespaces    [default]
    max_ttl                             0s
    num_uses                            0
    period                              0s
    policies                            [default k8s]
    ttl                                 8h

Also as of July 2019, this driver only support a version 2 kv secret engine mounted as `secret`.

This driver also support inline volume mount to avoid having to create persistent volume and persistent volume claim. But it requires Kubernetes 1.15+ which isn't yet available on GCP. So this demo doesn't demonstrate that part yet.

Lastly to cleanup this demo section you can run

    kubectl delete -f ~/k8s/pod-nginx.yaml; kubectl delete -f ~/k8s/pvc-vault-csi-static.yaml; kubectl delete -f ~/k8s/pv-vault-csi.yaml

## GCP Secret Engine

### Service Account

Generate Service account key

    vault read gcp/key/key

Use base64 to decode your key

    echo 'PUT YOUR KEY HERE' | base64 --decode

## Instance auth 

Generate OAuth GCP token
    
    vault read gcp/token/token

A storage bucket has been specifically created to demo the validity of your generated token. Try to upload a file to your bucket using the generated token

    cd ~
    curl -X POST --data-binary @playbook.yml -H "Authorization: Bearer <PUT_TOKEN_HERE>" -H "Content-Type: text/html" "https://www.googleapis.com/upload/storage/v1/b/<PROJECT_NAME>/o?uploadType=media&name=playbook.yml"

You should have the `playbook.yml` file uploaded to your Google Project bucket.

# Additional details

## Commands Snippets

To help you demo a lot more use cases, and to avoid typing all these commands, we've made all of them available thru [Pet](https://github.com/knqyf263/pet) a Simple command-line snippet manager, written in Go.

To access the list of snippets and search within them just use `CTRL-s` from `v1.<DOMAIN_NAME>`.

# Terraform Vault Provider improvement

HashiCorp worked on improving support on some auth and secret engines with Terraform Vault provider v2. I still need to update this demo to leverage the new features of this new provider ! For example I'd like to manage the following resources using this provider instead of Vault CLI:

- User/Userpass creation
- Transit key creation
- Google Secret Engine
- PKI Secret Engine
