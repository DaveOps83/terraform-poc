resource "aws_security_group" "group" {
    name = "${var.tour_api_security_group_name}"
    description = "${var.tour_api_security_group_description}"
    vpc_id = "${var.tour_api_security_group_vpc_id}"
    tags {
        Name = "${var.tour_api_security_group_name}"
        Project = "${var.tour_api_security_group_tag_project}"
        Environment = "${var.tour_api_security_group_tag_environment}"
    }
}

resource "aws_security_group_rule" "ssh_from_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id  = "${var.tour_api_security_group_bastion_security_group}"
    security_group_id = "${aws_security_group.group.id}"
}

resource "aws_security_group_rule" "http_from_elb" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id  = "${var.tour_api_security_group_elb_security_group}"
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
