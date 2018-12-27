# remote-exec used to overcome lack of support for certain Vault Operations
# will convert them over to native HCL when the provider will support the corresponding operations.

# Bare minimum to run before Ansible can take over
data "template_file" "script" {
  template = "${file("./files/script.sh")}"

  vars {
    vault_address   = "${var.vault_addr}"
    vault_token     = "${var.vault_token}"
    project_name    = "${var.project_name}"
    dns_domain      = "${var.dns_domain}"
    pki_role        = "${replace(substr(var.dns_domain, 0, length(var.dns_domain) - 1), ".", "-")}"
    role_id         = "${vault_approle_auth_backend_role.consul-template.role_id}"
    secret_id       = "${vault_approle_auth_backend_role_secret_id.consul-template.secret_id}"
    gcp_json_key    = "${google_service_account_key.vault-iam-auth-key.private_key}"
    enable_auth_k8s = "${var.enable_auth_k8s}"
    k8s_host        = "${module.gke.host[0]}"
    k8s_client_crt  = "${module.gke.client_certificate}"
    k8s_client_key  = "${module.gke.client_key}"
    k8s_cluster_crt = "${module.gke.cluster_ca_certificate}"
  }
}

# Ansible Playbook
data "template_file" "playbook" {
  template = "${file("./files/playbook.yml")}"

  vars {
    vault_address = "${var.vault_addr}"
    vault_token = "${var.vault_token}"
  }
}

# Pet cheatsheet commands snippets
data "template_file" "snippet" {
  template = "${file("./files/snippet.tpl")}"

  vars {
    vault_address = "${var.vault_addr}"
    project_name = "${var.project_name}"
    ssh_user = "${var.ssh_user}"
    db_user = "${var.db_user}"
    db_password = "${var.db_password}"
    dns_domain = "${substr(var.dns_domain, 0, length(var.dns_domain) - 1)}"
    pki_role = "${replace(substr(var.dns_domain, 0, length(var.dns_domain) - 1), ".", "-")}"
    role_id = "${vault_approle_auth_backend_role.consul-template.role_id}"
    secret_id = "${vault_approle_auth_backend_role_secret_id.consul-template.secret_id}"
  }
}

# NGINX configuration
data "template_file" "nginx" {
  template = "${file("./files/nginx.tpl")}"

  vars {
    dns_domain = "${var.dns_domain}"
  }
}

# Consul-template configuration for PKI as a Service demo
data "template_file" "pki-demo" {
  template = "${file("./files/pki-demo.tpl")}"

  vars {
    vault_address = "${var.vault_addr}"
    vault_consul_template_token = "${vault_approle_auth_backend_login.login.client_token}"
  }
}

# Consul-template
data "template_file" "cert" {
  template = "${file("./files/cert.tpl")}"

  vars {
    dns_domain = "${substr(var.dns_domain, 0, length(var.dns_domain) - 1)}"
    pki_role = "${replace(substr(var.dns_domain, 0, length(var.dns_domain) - 1), ".", "-")}"
  }
}

# Consul-template
data "template_file" "key" {
  template = "${file("./files/key.tpl")}"

  vars {
    dns_domain = "${substr(var.dns_domain, 0, length(var.dns_domain) - 1)}"
    pki_role = "${replace(substr(var.dns_domain, 0, length(var.dns_domain) - 1), ".", "-")}"
  }
}

# Vault Agent configuration
data "template_file" "vault-agent" {
  template = "${file("./files/vault-agent.tpl")}"

  vars {
    ssh_user = "${var.ssh_user}"
    role_id = "${vault_approle_auth_backend_role.consul-template.role_id}"
    secret_id = "${vault_approle_auth_backend_role_secret_id.consul-template.secret_id}"
  }
}

# Do out of band operation on Vault Server v1
resource "null_resource" "remote-exec" {
  triggers {
    version = 60,
    script = "${data.template_file.script.rendered}",
    playbook = "${data.template_file.playbook.rendered}",
    snippets = "${data.template_file.snippet.rendered}",
    nginx = "${data.template_file.nginx.rendered}",
    pki-demo = "${data.template_file.pki-demo.rendered}",
    cert = "${data.template_file.cert.rendered}",
    key = "${data.template_file.key.rendered}",
    vault-agent = "${data.template_file.vault-agent.rendered}"
  }

  connection {
    type = "ssh"
    host = "${data.dns_a_record_set.v1.addrs.0}"
    user = "${var.ssh_user}"
    private_key = "${var.priv_key}"
  }

  // copy our bootstrap script to the server
  provisioner "file" {
    content      = "${data.template_file.script.rendered}"
    destination = "/tmp/script.sh"
  }

  // copy Ansible Playbook over
  provisioner "file" {
    content      = "${data.template_file.playbook.rendered}"
    destination = "/home/${var.ssh_user}/playbook.yml"
  }

  // copy our Pet Snippets over
  provisioner "file" {
    content      = "${data.template_file.snippet.rendered}"
    destination = "/tmp/snippet.toml"
  }

 // copy our NGINX configuration over
  provisioner "file" {
    content      = "${data.template_file.nginx.rendered}"
    destination = "/tmp/nginx.cfg"
  }

  // copy our Comnsul-template configuration over
  provisioner "file" {
    content      = "${data.template_file.pki-demo.rendered}"
    destination = "/tmp/pki-demo.hcl"
  }

  // copy Comnsul-template TLS cert template
  provisioner "file" {
    content      = "${data.template_file.cert.rendered}"
    destination = "/tmp/cert.tpl"
  }

  // copy Comnsul-template TLS private key template
  provisioner "file" {
    content      = "${data.template_file.key.rendered}"
    destination = "/tmp/key.tpl"
  }

  // copy Comnsul-template systemd service over
  provisioner "file" {
    source      = "./files/consul-template.service"
    destination = "/tmp/consul-template.service"
  }

  // copy Vault Agent Configuration over
  provisioner "file" {
    content      = "${data.template_file.vault-agent.rendered}"
    destination = "/tmp/vault-agent.hcl"
  }

  // change permissions to executable and pipe its output execution into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh > /tmp/script",
    ]
  }

  depends_on = ["google_sql_database_instance.master", "vault_auth_backend.approle", "vault_mount.pki", "vault_mount.gcp", "vault_mount.kv", "vault_auth_backend.userpass", "vault_auth_backend.gcp", "google_sourcerepo_repository.docker-vault"]
}
