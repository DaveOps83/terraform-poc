resource "template_file" "tropics_user_data" {
  template = "${file("${path.module}/user_data/tropics.sh")}"
  vars {
    dc_dns = "${var.tropics_dc_dns}"
  }
}

resource "template_cloudinit_config" "tropics" {
  gzip          = false
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.tropics_user_data.rendered}"
  }
}

resource "aws_instance" "tropics" {
    instance_type = "${var.tropics_instance_type}"
    ami = "${var.tropics_ami}"
    key_name = "${var.tropics_key_pair}"
    subnet_id = "${var.tropics_subnet}"
    vpc_security_group_ids = ["${var.tropics_security_group}"]
    monitoring = "true"
    disable_api_termination = "false"
    user_data = "${template_cloudinit_config.tropics.rendered}"
    tags {
        Name = "${var.tropics_tag_name}"
        Description = "${var.tropics_tag_description}"
        Project = "${var.tropics_tag_project}"
        Environment = "${var.tropics_tag_environment}"
    }
}
