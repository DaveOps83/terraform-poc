resource "template_file" "tour_api_user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"
  vars {
    dc_dns = "${var.tour_api_dc_dns}"
  }
}

resource "template_cloudinit_config" "tour_api" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.tour_api_user_data.rendered}"
  }
}
