output "dc_ingress_dns" { value = "${aws_route53_record.dc_ingress.name}" }
output "tropics_dns" { value = "${aws_route53_record.tropics.name}" }
output "das_dns" { value = "${aws_route53_record.das.name}" }
output "ldaps_dns" { value = "${aws_route53_record.ldaps.name}" }
