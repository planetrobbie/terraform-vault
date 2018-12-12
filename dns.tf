data "dns_a_record_set" "v1" {
  host = "v1.${var.gcp_dns_domain}"
}

data "dns_a_record_set" "v2" {
  host = "v2.${var.gcp_dns_domain}"
}