resource "aws_security_group" "group" {
    name = "${var.http_security_group_name}"
    description = "${var.http_security_group_description}"
    vpc_id = "${var.http_security_group_vpc_id}"
    tags {
        Name = "${var.http_security_group_name}"
        Project = "${var.http_security_group_name}"
        Environment = "${var.http_security_group_tag_environment}"
    }
}

resource "aws_security_group_rule" "ssh_from_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.http_security_group_bastion_private_ip}/32"]
    security_group_id = "${aws_security_group.group.id}"
}

resource "aws_security_group_rule" "http_from_all" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.group.id}"
}

resource "aws_security_group_rule" "http_to_nat_gateways" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.http_security_group_primary_nat_gateway_ip}/32", "${var.http_security_group_secondary_nat_gateway_ip}/32"]
    security_group_id = "${aws_security_group.group.id}"
}

resource "aws_security_group_rule" "https_to_nat_gateways" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.http_security_group_primary_nat_gateway_ip}/32", "${var.http_security_group_secondary_nat_gateway_ip}/32"]
    security_group_id = "${aws_security_group.group.id}"
}
