resource "aws_cloudwatch_log_group" "logs" {
  name = "${var.log_group_name}"
  retention_in_days = "30"
}

resource "template_file" "logs_trust_policy_document" {
  template = "${file("${path.module}/trust_policy.json")}"
}

resource "aws_iam_role" "logs_role" {
    name = "${var.log_group_name}-logs"
    assume_role_policy = "${template_file.logs_trust_policy_document.rendered}"
}

resource "template_file" "logs_role_policy_document" {
  template = "${file("${path.module}/role_policy.json")}"
  vars {
    arn_log_group_name = "${aws_cloudwatch_log_group.logs.name}"
    arn_log_group_region = "${var.log_group_region}"
  }
}

  resource "aws_iam_role_policy" "role_policy" {
    name = "${var.log_group_name}"
    role = "${aws_iam_role.logs_role.id}"
    policy = "${template_file.logs_role_policy_document.rendered}"
}
