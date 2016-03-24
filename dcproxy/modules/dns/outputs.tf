output "tropics_dns" { value = "${aws_route53_record.tropics.name}" }
output "tropics_dc_dns" { value = "${aws_route53_record.tropics_dc.name}" }
output "das_dns" { value = "${aws_route53_record.das.name}" }
output "das_dc_dns" { value = "${aws_route53_record.das_dc.name}" }
#output "ldaps_dns" { value = "${aws_route53_record.ldaps.name}" }
#output "ldaps_dc_dns" { value = "${aws_route53_record.ldaps_dc.name}" }
output "tour_api_dns" { value = "${aws_route53_record.tour_api.name}" }
output "tour_api_dc_dns" { value = "${aws_route53_record.tour_api_dc.name}" }
