resource "template_file" "bastion_user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"
}

resource "template_cloudinit_config" "bastion" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.bastion_user_data.rendered}"
  }
}
