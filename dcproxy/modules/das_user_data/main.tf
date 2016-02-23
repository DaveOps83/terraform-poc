resource "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"
  vars {
    dc_dns = "${var.das_dc_dns}"
    log_group_name = "${var.das_log_group_name}"
    log_stream_name = "${var.das_log_stream_name}"
    log_region = "${var.das_log_region}"
  }
}

resource "template_file" "bootstrap_tests" {
  template = "${file("${path.module}/bootstrap_tests.sh")}"
}

resource "template_cloudinit_config" "cloudinit_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.user_data.rendered}"
  }
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.bootstrap_tests.rendered}"
  }
}
