resource "aws_security_group" "group" {
    name = "${var.bastion_security_group_name}"
    description = "${var.bastion_security_group_description}"
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
    security_group_id = "${aws_security_group.group.id}"
}

resource "aws_security_group_rule" "ssh_to_tropics_nodes" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id  = "${var.bastion_security_group_tropics_security_group}"
    security_group_id = "${aws_security_group.group.id}"
}

resource "aws_security_group_rule" "ssh_to_das_nodes" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id  = "${var.bastion_security_group_das_security_group}"
    security_group_id = "${aws_security_group.group.id}"
}

/*
resource "aws_security_group_rule" "ssh_to_ldaps_nodes" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id  = "${var.bastion_security_group_ldaps_security_group}"
    security_group_id = "${aws_security_group.group.id}"
}
*/

resource "aws_security_group_rule" "ssh_to_tour_api_nodes" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id  = "${var.bastion_security_group_tour_api_security_group}"
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
