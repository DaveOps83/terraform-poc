resource "template_file" "bastion_user_data" {
  template = "${file("${path.module}/user_data/bastion.sh")}"
}

resource "template_cloudinit_config" "bastion" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.bastion_user_data.rendered}"
  }
}

resource "aws_instance" "bastion" {
    instance_type = "${var.bastion_instance_type}"
    ami = "${var.bastion_ami}"
    key_name = "${var.bastion_key_pair}"
    subnet_id = "${var.bastion_subnet}"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["${var.bastion_security_group}"]
    monitoring = "true"
    disable_api_termination = "false"
    user_data = "${template_cloudinit_config.bastion.rendered}"
    tags {
        Name = "${var.bastion_tag_name}"
        Description = "${var.bastion_tag_description}"
        Project = "${var.bastion_tag_project}"
        Environment = "${var.bastion_tag_environment}"
    }
}
