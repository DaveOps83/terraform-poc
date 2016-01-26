resource "template_file" "das_user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"
  vars {
    dc_dns = "${var.das_dc_dns}"
  }
}

resource "template_cloudinit_config" "das" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.das_user_data.rendered}"
  }
}
