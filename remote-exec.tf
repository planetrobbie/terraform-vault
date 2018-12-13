# remote-exec used to overcome lack of support for certain Vault Operations

resource "null_resource" "remote-exec" {
  triggers {
    public_ip = "${data.dns_a_record_set.v1.addrs.0}"
  }

  connection {
    type = "ssh"
    host = "${data.dns_a_record_set.v1.addrs.0}"
    user = "${var.ssh_user}"
    private_key = "${var.priv_key}"
  }

  // copy our example script to the server
  provisioner "file" {
    source      = "./files/script.sh"
    destination = "/tmp/scriptp.sh"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh > /tmp/script",
    ]
  }
}
