resource "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"
}

resource "template_cloudinit_config" "cloudinit_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.user_data.rendered}"
  }
}
