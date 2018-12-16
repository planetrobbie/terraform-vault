# remote-exec used to overcome lack of support for certain Vault Operations
# will convert them over to native HCL when the provider will support the corresponding operations.

# Bare minimum to run before Ansible can take over
data "template_file" "script" {
  template = "${file("./files/script.tpl")}"

  vars {
    vault_address = "${var.vault_addr}"
    vault_token = "${var.vault_token}"
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
  }
}

# Do out of band operation on Vault Server v1
resource "null_resource" "remote-exec" {
  triggers {
#    public_ip = "${data.dns_a_record_set.v1.addrs.0}"
    version = 40
  }

  connection {
    type = "ssh"
    host = "${data.dns_a_record_set.v1.addrs.0}"
    user = "${var.ssh_user}"
    private_key = "${var.priv_key}"
  }

  // copy our example script to the server
  provisioner "file" {
    content      = "${data.template_file.script.rendered}"
    destination = "/tmp/script.sh"
  }

  // copy Ansible Playbook over
  provisioner "file" {
    content      = "${data.template_file.playbook.rendered}"
    destination = "/home/${var.ssh_user}/playbook.yml"
  }

  // copy our example script to the server
  provisioner "file" {
    content      = "${data.template_file.snippet.rendered}"
    destination = "/tmp/snippet.toml"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh > /tmp/script",
    ]
  }
}
