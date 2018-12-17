# remote-exec used to overcome lack of support for certain Vault Operations
# will convert them over to native HCL when the provider will support the corresponding operations.

# Bare minimum to run before Ansible can take over
data "template_file" "script" {
  template = "${file("./files/script.tpl")}"

  vars {
    vault_address = "${var.vault_addr}"
    vault_token = "${var.vault_token}"
    dns_domain = "${var.dns_domain}"
    pki_role = "${replace(substr(var.dns_domain, 0, length(var.dns_domain) - 1), ".", "-")}"
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
    dns_domain = "${var.dns_domain}"
    pki_role = "${replace(substr(var.dns_domain, 0, length(var.dns_domain) - 1), ".", "-")}"
  }
}

# NGINX configuration
data "template_file" "nginx" {
  template = "${file("./files/nginx.tpl")}"

  vars {
    ssh_user = "${var.ssh_user}"
    dns_domain = "${var.dns_domain}"
  }
}

# Consul-template configuration for PKI as a Service demo
data "template_file" "pki-demo" {
  template = "${file("./files/pki-demo.tpl")}"

  vars {
    vault_address = "${var.vault_addr}"
  }
}

# Consul-template
data "template_file" "cert" {
  template = "${file("./files/cert.tpl")}"

  vars {
    dns_domain = "${var.dns_domain}"
    pki_role = "${replace(substr(var.dns_domain, 0, length(var.dns_domain) - 1), ".", "-")}"
  }
}

# Consul-template
data "template_file" "key" {
  template = "${file("./files/key.tpl")}"

  vars {
    dns_domain = "${var.dns_domain}"
    pki_role = "${replace(substr(var.dns_domain, 0, length(var.dns_domain) - 1), ".", "-")}"
  }
}


# Do out of band operation on Vault Server v1
resource "null_resource" "remote-exec" {
  triggers {
    version = 48,
    script = "${data.template_file.script.rendered}",
    playbook = "${data.template_file.playbook.rendered}",
    snippets = "${data.template_file.snippet.rendered}",
    nginx = "${data.template_file.nginx.rendered}",
    pki-demo = "${data.template_file.pki-demo.rendered}",
    cert = "${data.template_file.cert.rendered}",
    key = "${data.template_file.key.rendered}"
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

  // change permissions to executable and pipe its output execution into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh > /tmp/script",
    ]
  }
}
