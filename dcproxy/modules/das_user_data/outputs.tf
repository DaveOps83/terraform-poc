output "user_data" { value = "${template_cloudinit_config.das.rendered}" }
