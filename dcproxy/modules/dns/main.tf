resource "aws_route53_record" "tropics" {
   zone_id = "${var.dns_hosted_zone_id}"
   name = "${var.dns_tropics_dns}"
   type = "A"
   ttl = "60"
   records = ["${var.dns_primary_tropics_instance_private_ip}"]
}

resource "aws_route53_record" "tropics_dc" {
   zone_id = "${var.dns_hosted_zone_id}"
   name = "${var.dns_tropics_dc_dns}"
   type = "A"
   ttl = "300"
   records = ["${var.dns_dc_ingress_ip}"]
}

resource "aws_route53_record" "das" {
   zone_id = "${var.dns_hosted_zone_id}"
   name = "${var.dns_das_dns}"
   type = "A"
   ttl = "60"
   records = ["${var.dns_primary_das_instance_private_ip}"]
}

resource "aws_route53_record" "das_dc" {
   zone_id = "${var.dns_hosted_zone_id}"
   name = "${var.dns_das_dc_dns}"
   type = "A"
   ttl = "300"
   records = ["${var.dns_dc_ingress_ip}"]
}

/*
resource "aws_route53_record" "ldaps" {
   zone_id = "${var.dns_hosted_zone_id}"
   name = "${var.dns_ldaps_dns}"
   type = "A"
   ttl = "60"
   records = ["${var.dns_primary_ldaps_instance_private_ip}"]
}

resource "aws_route53_record" "ldaps_dc" {
   zone_id = "${var.dns_hosted_zone_id}"
   name = "${var.dns_ldaps_dc_dns}"
   type = "A"
   ttl = "300"
   records = ["${var.dns_dc_ingress_ip}"]
}
*/

resource "aws_route53_record" "tour_api" {
   zone_id = "${var.dns_hosted_zone_id}"
   name = "${var.dns_tour_api_dns}"
   type = "CNAME"
   ttl = "300"
   records = ["${var.dns_tour_api_elb_dns_name}"]
}

resource "aws_route53_record" "tour_api_dc" {
   zone_id = "${var.dns_hosted_zone_id}"
   name = "${var.dns_tour_api_dc_dns}"
   type = "A"
   ttl = "300"
   records = ["${var.dns_dc_ingress_ip}"]
}
