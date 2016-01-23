resource "template_file" "ldaps_user_data" {
  template = "${file("${path.module}/user_data/ldaps.sh")}"
  vars {
    dc_dns = "${var.ldaps_dc_dns}"
  }
}

resource "template_cloudinit_config" "ldaps" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.ldaps_user_data.rendered}"
  }
}

resource "aws_instance" "ldaps" {
    instance_type = "${var.ldaps_instance_type}"
    ami = "${var.ldaps_ami}"
    key_name = "${var.ldaps_key_pair}"
    subnet_id = "${var.ldaps_subnet}"
    vpc_security_group_ids = ["${var.ldaps_security_group}"]
    monitoring = "true"
    disable_api_termination = "false"
    user_data = "${template_cloudinit_config.ldaps.rendered}"
    tags {
        Name = "${var.ldaps_tag_name}"
        Description = "${var.ldaps_tag_description}"
        Project = "${var.ldaps_tag_project}"
        Environment = "${var.ldaps_tag_environment}"
    }
}
