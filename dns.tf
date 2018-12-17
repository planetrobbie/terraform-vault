data "dns_a_record_set" "v1" {
  host = "v1.${var.dns_domain}"
}

data "dns_a_record_set" "v2" {
  host = "v2.${var.dns_domain}"
}

resource "google_dns_record_set" "db" {
  name = "db.${var.dns_domain}"
  type = "A"
  ttl  = "${var.ttl}"

  managed_zone = "${var.dns_zone}"

  rrdatas = ["${google_sql_database_instance.master.ip_address.0.ip_address}"]
}

resource "google_dns_record_set" "www" {
  name = "www.${var.dns_domain}"
  type = "A"
  ttl  = "${var.ttl}"

  managed_zone = "${var.dns_zone}"

  rrdatas = ["${data.dns_a_record_set.v1.addrs.0}"]
}