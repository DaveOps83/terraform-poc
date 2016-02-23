resource "aws_instance" "instance" {
    instance_type = "${var.instance_type}"
    ami = "${var.instance_ami}"
    key_name = "${var.instance_key_pair}"
    subnet_id = "${var.instance_subnet}"
    associate_public_ip_address = "${var.instance_associate_public_ip_address}"
    vpc_security_group_ids = ["${var.instance_security_group}"]
    iam_instance_profile = "${var.instance_profile}"
    monitoring = "${var.instance_monitoring}"
    disable_api_termination = "${var.instance_disable_api_termination}"
    user_data = "${var.instance_user_data}"
    tags {
        Name = "${var.instance_tag_name}"
        Description = "${var.instance_tag_description}"
        Project = "${var.instance_tag_project}"
        Environment = "${var.instance_tag_environment}"
    }
}
