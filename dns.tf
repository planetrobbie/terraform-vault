data "dns_a_record_set" "v1" {
  host = "v1.${var.domain_name}"
}

data "dns_a_record_set" "v2" {
  host = "v2.${var.domain_name}"
}