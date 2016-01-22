output "private_ip" { value = "${aws_instance.bastion.private_ip}" }
output "public_ip" { value = "${aws_instance.bastion.public_ip}" }
output "key_name" { value = "${aws_instance.bastion.key_name}" }
