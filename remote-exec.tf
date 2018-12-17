# remote-exec used to overcome lack of support for certain Vault Operations
# will convert them over to native HCL when the provider will support the corresponding operations.

# Bare minimum to run before Ansible can take over
data "template_file" "script" {
  template = "${file("./files/script.tpl")}"

  vars {
    vault_address = "${var.vault_addr}"
    vault_token = "${var.vault_token}"
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

# Do out of band operation on Vault Server v1
resource "null_resource" "remote-exec" {
  triggers {
#    public_ip = "${data.dns_a_record_set.v1.addrs.0}"
    version = 46,
    script = "${data.template_file.script.rendered}",
    playbook = "${data.template_file.playbook.rendered}",
    snippets = "${data.template_file.snippet.rendered}",
    nginx = "${data.template_file.nginx.rendered}"
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

  // change permissions to executable and pipe its output execution into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh > /tmp/script",
    ]
  }
}
