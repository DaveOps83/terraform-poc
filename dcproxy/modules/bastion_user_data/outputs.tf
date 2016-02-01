output "user_data" { value = "${template_cloudinit_config.cloudinit_config.rendered}" }
