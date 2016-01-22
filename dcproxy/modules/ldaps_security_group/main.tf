#Variables
variable "vpc_id" {}
variable "bastion_private_ip" {}
variable "primary_nat_gateway_ip" {}
variable "secondary_nat_gateway_ip" {}
variable "name" {}
variable "description" {}
variable "tag_project" {}
variable "tag_environment" {}

#Outputs
output "id" { value = "${aws_security_group.ldaps.id}" }

resource "aws_security_group" "ldaps" {
    name = "${var.name}-ldaps"
    description = "${var.description}"
    vpc_id = "${var.vpc_id}"
    tags {
        Name = "${var.name}-ldaps"
        Project = "${var.name}"
        Environment = "${var.tag_environment}"
    }
}

resource "aws_security_group_rule" "ssh_from_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.bastion_private_ip}/32"]
    security_group_id = "${aws_security_group.ldaps.id}"
}

resource "aws_security_group_rule" "http_from_all" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.ldaps.id}"
}

resource "aws_security_group_rule" "http_to_nat_gateways" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.primary_nat_gateway_ip}/32", "${var.secondary_nat_gateway_ip}/32"]
    security_group_id = "${aws_security_group.ldaps.id}"
}

resource "aws_security_group_rule" "https_to_nat_gateways" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.primary_nat_gateway_ip}/32", "${var.secondary_nat_gateway_ip}/32"]
    security_group_id = "${aws_security_group.ldaps.id}"
}
