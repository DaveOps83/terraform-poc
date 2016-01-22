#Variables
variable "vpc_id" {}
variable "ssh_source_range" {}
variable "primary_private_cidr_block" {}
variable "secondary_private_cidr_block" {}
variable "name" {}
variable "description" {}
variable "tag_project" {}
variable "tag_environment" {}

#Outputs
output "id" { value = "${aws_security_group.bastion.id}" }

resource "aws_security_group" "bastion" {
    name = "${var.name}-bastion-node"
    description = "${var.tag_environment}"
    vpc_id = "${var.vpc_id}"
    tags {
        Name = "${var.name}-bastion"
        Project = "${var.name}"
        Environment = "${var.tag_environment}"
    }
}

resource "aws_security_group_rule" "ssh_from_london" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.ssh_source_range}"]
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "ssh_to_private_subnets" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.primary_private_cidr_block}", "${var.secondary_private_cidr_block}"]
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "http_to_private_subnets" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.primary_private_cidr_block}", "${var.secondary_private_cidr_block}"]
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "https_to_private_subnets" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.primary_private_cidr_block}", "${var.secondary_private_cidr_block}"]
    security_group_id = "${aws_security_group.bastion.id}"
}
