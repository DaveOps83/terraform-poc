output "name" { value = "${aws_cloudwatch_log_group.logs.name}" }
output "role" { value = "${aws_iam_role.logs_role.name}" }
