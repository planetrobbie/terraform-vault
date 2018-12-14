# remote-exec used to overcome lack of support for certain Vault Operations
# will convert them over to native HCL when the provider will support the corresponding operations.

data "template_file" "script" {
  template = "${file("./files/script.tpl")}"

  vars {
    vault_address = "${var.vault_addr}"
    vault_token = "${var.vault_token}"
  }
}

resource "null_resource" "remote-exec" {
  triggers {
#    public_ip = "${data.dns_a_record_set.v1.addrs.0}"
    version = 3
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

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh > /tmp/script",
    ]
  }
}
