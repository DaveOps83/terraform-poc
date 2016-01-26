output "user_data" { value = "${template_cloudinit_config.tour_api.rendered}" }
