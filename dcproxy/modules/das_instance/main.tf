resource "template_file" "das_user_data" {
  template = "${file("${path.module}/user_data/das.sh")}"
  vars {
    dc_dns = "${var.das_dc_dns}"
  }
}

resource "template_cloudinit_config" "das" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.das_user_data.rendered}"
  }
}

resource "aws_instance" "das" {
    instance_type = "${var.das_instance_type}"
    ami = "${var.das_ami}"
    key_name = "${var.das_key_pair}"
    subnet_id = "${var.das_subnet}"
    vpc_security_group_ids = ["${var.das_security_group}"]
    monitoring = "true"
    disable_api_termination = "false"
    user_data = "${template_cloudinit_config.das.rendered}"
    tags {
        Name = "${var.das_tag_name}"
        Description = "${var.das_tag_description}"
        Project = "${var.das_tag_project}"
        Environment = "${var.das_tag_environment}"
    }
}
