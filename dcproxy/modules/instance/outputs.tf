output "instance_id" { value = "${aws_instance.instance.instance_id}" }
output "private_ip" { value = "${aws_instance.instance.private_ip}" }
output "public_ip" { value = "${aws_instance.instance.public_ip}" }
output "key_name" { value = "${aws_instance.instance.key_name}" }
