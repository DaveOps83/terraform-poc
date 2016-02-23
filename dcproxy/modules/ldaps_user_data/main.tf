resource "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"
  vars {
    dc_dns = "${var.ldaps_dc_dns}"
    log_group_name = "${var.ldaps_log_group_name}"
    log_stream_name = "${var.ldaps_log_stream_name}"
  }
}

resource "template_cloudinit_config" "cloudinit_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.user_data.rendered}"
  }
}
