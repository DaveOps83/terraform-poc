resource "aws_security_group" "bastion" {
    name = "${var.bastion_security_group_name}"
    description = "${var.bastion_security_group_tag_environment}"
    vpc_id = "${var.bastion_security_group_vpc_id}"
    tags {
        Name = "${var.bastion_security_group_name}"
        Project = "${var.bastion_security_group_name}"
        Environment = "${var.bastion_security_group_tag_environment}"
    }
}

resource "aws_security_group_rule" "ssh_from_data_centre" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.bastion_security_group_ssh_source_range}"]
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "ssh_to_private_subnets" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.bastion_security_group_primary_private_cidr_block}", "${var.bastion_security_group_secondary_private_cidr_block}"]
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "http_to_private_subnets" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.bastion_security_group_primary_private_cidr_block}", "${var.bastion_security_group_secondary_private_cidr_block}"]
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "https_to_private_subnets" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.bastion_security_group_primary_private_cidr_block}", "${var.bastion_security_group_secondary_private_cidr_block}"]
    security_group_id = "${aws_security_group.bastion.id}"
}
