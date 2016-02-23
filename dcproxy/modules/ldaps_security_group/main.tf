resource "aws_security_group" "group" {
    name = "${var.ldaps_security_group_name}"
    description = "${var.ldaps_security_group_description}"
    vpc_id = "${var.ldaps_security_group_vpc_id}"
    tags {
        Name = "${var.ldaps_security_group_name}"
        Project = "${var.ldaps_security_group_tag_project}"
        Environment = "${var.ldaps_security_group_tag_environment}"
    }
}

resource "aws_security_group_rule" "ssh_from_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id  = "${var.ldaps_security_group_bastion_security_group}"
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

resource "aws_security_group_rule" "http_to_all" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.group.id}"
}

resource "aws_security_group_rule" "https_to_all" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.group.id}"
}
