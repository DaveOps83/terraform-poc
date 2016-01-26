resource "aws_elb" "https_elb" {
  name = "${var.https_elb_tag_name}"
  subnets = ["${split(",", var.https_elb_subnets)}"]
  instances = ["${split(",", var.https_elb_instances)}"]
  cross_zone_load_balancing = "${var.https_elb_cross_zone}"
  idle_timeout = "${var.https_elb_idle_timeout}"
  connection_draining = "${var.https_elb_connection_draining}"
  connection_draining_timeout = "${var.https_elb_connection_draining_timeout}"
  security_groups = ["${var.https_elb_security_groups}"]
  listener {
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.https_elb_ssl_cert_arn}"
    instance_port = "${var.https_elb_instance_port}"
    instance_protocol = "${var.https_elb_instance_protocol}"
  }
  health_check {
    healthy_threshold = "${var.https_elb_healthy_threshold}"
    unhealthy_threshold = "${var.https_elb_unhealthy_threshold}"
    timeout = "${var.https_elb_health_check_timeout}"
    target = "${var.https_elb_instance_protocol}:${var.https_elb_instance_port}/${var.https_elb_health_check_target_path}"
    interval = "${var.https_elb_health_check_interval}"
  }
  tags {
    Description = "${var.https_elb_tag_description}"
    Project = "${var.https_elb_tag_project}"
    Environment = "${var.https_elb_tag_environment}"
  }
}
