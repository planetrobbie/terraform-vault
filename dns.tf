data "dns_a_record_set" "v1" {
  host = "v1.${var.dns_domain}"
}

data "dns_a_record_set" "v2" {
  host = "v2.${var.dns_domain}"
}