resource "aws_iam_instance_profile" "instance_profile" {
    name = "${var.instance_profile_name}"
    roles = ["${var.instance_profile_roles}"]
}
