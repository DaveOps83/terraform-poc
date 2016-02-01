resource "aws_security_group" "group" {
    name = "${var.tour_api_elb_security_group_name}"
    description = "${var.tour_api_elb_security_group_description}"
    vpc_id = "${var.tour_api_elb_security_group_vpc_id}"
    tags {
        Name = "${var.tour_api_elb_security_group_name}"
        Project = "${var.tour_api_elb_security_group_tag_project}"
        Environment = "${var.tour_api_elb_security_group_tag_environment}"
    }
}

resource "aws_security_group_rule" "https_from_all" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.group.id}"
}

resource "aws_security_group_rule" "http_to_tour_api_security_group" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = "${var.tour_api_elb_security_group_tour_api_security_group}"
    security_group_id = "${aws_security_group.group.id}"
}
