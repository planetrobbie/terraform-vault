# remote-exec used to overcome lack of support for certain Vault Operations
# will convert them over to native HCL when the provider will support the corresponding operations.

data "template_file" "script" {
  template = "${file("./files/script.tpl")}"

  vars {
    vault_address = "${var.vault_addr}"
    vault_token = "${var.vault_token}"
  }
}

data "template_file" "demo" {
  template = "${file("./files/demo.tpl")}"

  vars {
    db_user = "${var.db_user}"
    db_password = "${var.db_password}"
    dns_domain = "${var.dns_domain}"
  }
}

data "template_file" "snippet" {
  template = "${file("./files/snippet.tpl")}"

  vars {
    }
}

# Do out of band operation on Vault Server v1
resource "null_resource" "remote-exec" {
  triggers {
#    public_ip = "${data.dns_a_record_set.v1.addrs.0}"
    version = 17
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

  // copy our example script to the server
  provisioner "file" {
    content      = "${data.template_file.snippet.rendered}"
    destination = "/tmp/snippet.toml"
  }

  // copy Ansible Playbook over
  provisioner "file" {
    source      = "./files/playbook"
    destination = "/home/${var.ssh_user}/"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh > /tmp/script",
    ]
  }
}

# Copy over MySQL connection script to v1 if DB Secret Engine enabled
resource "null_resource" "demo" {
  count = "${var.enable_secret_engine_db}"
  triggers {
    demo = "${data.template_file.demo.rendered}"
    db_user = "${var.db_user}"
    db_password = "${var.db_password}"
    dns_domain = "${var.dns_domain}"
  }

  connection {
    type = "ssh"
    host = "${data.dns_a_record_set.v1.addrs.0}"
    user = "${var.ssh_user}"
    private_key = "${var.priv_key}"
  }

  // copy our example script to the server
  provisioner "file" {
    content      = "${data.template_file.demo.rendered}"
    destination = "/home/${var.ssh_user}/demo.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/demo.sh",
    ]
  }
}
