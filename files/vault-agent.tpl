pid_file = "./pidfile"
exit_after_auth = true

auto_auth {
        method "AppRole" {
                config = {
                        role_id_file_path = "/home/${ssh_user}/approle/${role_id}"
                        secret_id_file_path = "/home/${ssh_user}/approle/${secret_id}"
                        remove_secret_id_file_after_reading = false
                }
        }

        sink "file" {
                config = {
                        path = "/tmp/consul-template-token"
                }
        }
}
