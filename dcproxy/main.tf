provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${lookup(var.region, var.aws_target_env)}"
}

module "vpc" {
    source = "modules/vpc"
    vpc_cidr_block = "10.0.0.0/25"
    vpc_primary_private_cidr_block = "10.0.0.0/27"
    vpc_primary_public_cidr_block = "10.0.0.32/27"
    vpc_secondary_private_cidr_block = "10.0.0.64/27"
    vpc_secondary_public_cidr_block = "10.0.0.96/27"
    vpc_primary_az = "${lookup(var.primary_az, var.aws_target_env)}"
    vpc_secondary_az = "${lookup(var.secondary_az, var.aws_target_env)}"
    vpc_primary_nat_gateway_eip = "${lookup(var.primary_nat_gateway_eip, var.aws_target_env)}"
    vpc_secondary_nat_gateway_eip = "${lookup(var.secondary_nat_gateway_eip, var.aws_target_env)}"
    vpc_name_tag = "${var.stack_name}"
    vpc_description_tag = "${var.stack_description}"
    vpc_project_tag = "${var.stack_name}"
    vpc_environment_tag = "${var.aws_target_env}"
}

module "bastion_log_group" {
    source = "modules/log_group"
    log_group_name = "${var.stack_name}-bastion"
    log_group_region = "${lookup(var.region, var.aws_target_env)}"
}

module "bastion_instance_profile" {
    source = "modules/instance_profile"
    instance_profile_name = "${var.stack_name}-bastion"
    instance_profile_roles = "${module.bastion_log_group.role}"
}

module "bastion_security_group" {
    source = "modules/bastion_security_group"
    bastion_security_group_vpc_id = "${module.vpc.id}"
    bastion_security_group_ssh_source_range = "${var.dc_egress_range}"
    bastion_security_group_tropics_security_group = "${module.tropics_security_group.id}"
    bastion_security_group_das_security_group = "${module.das_security_group.id}"
    #bastion_security_group_ldaps_security_group = "${module.ldaps_security_group.id}"
    bastion_security_group_tour_api_security_group = "${module.tour_api_security_group.id}"
    bastion_security_group_name = "${var.stack_name}-bastion"
    bastion_security_group_description = "${var.stack_description}"
    bastion_security_group_tag_project = "${var.stack_name}"
    bastion_security_group_tag_environment = "${var.aws_target_env}"
}

module "bastion_user_data" {
    source = "modules/bastion_user_data"
    bastion_log_group_name = "${module.bastion_log_group.name}"
    bastion_log_stream_name = "bastion-instance"
}

module "bastion_instance" {
    source = "modules/instance"
    instance_ami = "${lookup(var.bastion_ami, lookup(var.region, var.aws_target_env))}"
    instance_type = "t2.nano"
    instance_key_pair = "${lookup(var.bastion_key_pair, var.aws_target_env)}"
    instance_subnet = "${module.vpc.primary_public_subnet}"
    instance_associate_public_ip_address = "true"
    instance_security_group = "${module.bastion_security_group.id}"
    instance_profile = "${module.bastion_instance_profile.name}"
    instance_monitoring = "false"
    instance_disable_api_termination = "false"
    instance_user_data = "${module.bastion_user_data.user_data}"
    instance_tag_name = "${var.stack_name}-bastion"
    instance_tag_description = "${var.stack_description}"
    instance_tag_project = "${var.stack_name}"
    instance_tag_environment = "${var.aws_target_env}"
}

module "tropics_log_group" {
    source = "modules/log_group"
    log_group_name = "${var.stack_name}-tropics"
    log_group_region = "${lookup(var.region, var.aws_target_env)}"
}

module "tropics_instance_profile" {
    source = "modules/instance_profile"
    instance_profile_name = "${var.stack_name}-tropics"
    instance_profile_roles = "${module.tropics_log_group.role}"
}

module "tropics_security_group" {
    source = "modules/tropics_security_group"
    tropics_security_group_vpc_id = "${module.vpc.id}"
    tropics_security_group_bastion_security_group = "${module.bastion_security_group.id}"
    tropics_security_group_name = "${var.stack_name}-tropics"
    tropics_security_group_description = "${var.stack_description}"
    tropics_security_group_tag_project = "${var.stack_name}"
    tropics_security_group_tag_environment = "${var.aws_target_env}"
}

module "primary_tropics_instance_user_data" {
    source = "modules/tropics_user_data"
    tropics_dc_dns = "${module.dns.tropics_dc_dns}"
    tropics_log_group_name = "${module.tropics_log_group.name}"
    tropics_log_stream_name = "primary-instance"
    tropics_log_region = "${lookup(var.region, var.aws_target_env)}"
}

module "primary_tropics_instance" {
    source = "modules/instance"
    instance_ami = "${lookup(var.tropics_ami, lookup(var.region, var.aws_target_env))}"
    instance_type = "${lookup(var.tropics_instance_type, var.aws_target_env)}"
    instance_key_pair = "${lookup(var.tropics_key_pair, var.aws_target_env)}"
    instance_subnet = "${module.vpc.primary_private_subnet}"
    instance_associate_public_ip_address = "false"
    instance_security_group = "${module.tropics_security_group.id}"
    instance_profile = "${module.tropics_instance_profile.name}"
    instance_monitoring = "true"
    instance_disable_api_termination = "false"
    instance_user_data = "${module.primary_tropics_instance_user_data.user_data}"
    instance_tag_name = "${var.stack_name}-primary-tropics"
    instance_tag_description = "${var.stack_description}"
    instance_tag_project = "${var.stack_name}"
    instance_tag_environment = "${var.aws_target_env}"
}

module "secondary_tropics_instance_user_data" {
    source = "modules/tropics_user_data"
    tropics_dc_dns = "${module.dns.tropics_dc_dns}"
    tropics_log_group_name = "${module.tropics_log_group.name}"
    tropics_log_stream_name = "secondary-instance"
    tropics_log_region = "${lookup(var.region, var.aws_target_env)}"
}

module "secondary_tropics_instance" {
    source = "modules/instance"
    instance_ami = "${lookup(var.tropics_ami, lookup(var.region, var.aws_target_env))}"
    instance_type = "${lookup(var.tropics_instance_type, var.aws_target_env)}"
    instance_key_pair = "${lookup(var.tropics_key_pair, var.aws_target_env)}"
    instance_subnet = "${module.vpc.secondary_private_subnet}"
    instance_associate_public_ip_address = "false"
    instance_security_group = "${module.tropics_security_group.id}"
    instance_profile = "${module.tropics_instance_profile.name}"
    instance_monitoring = "true"
    instance_disable_api_termination = "false"
    instance_user_data = "${module.secondary_tropics_instance_user_data.user_data}"
    instance_tag_name = "${var.stack_name}-secondary-tropics"
    instance_tag_description = "${var.stack_description}"
    instance_tag_project = "${var.stack_name}"
    instance_tag_environment = "${var.aws_target_env}"
}

module "das_log_group" {
    source = "modules/log_group"
    log_group_name = "${var.stack_name}-das"
    log_group_region = "${lookup(var.region, var.aws_target_env)}"
}

module "das_instance_profile" {
    source = "modules/instance_profile"
    instance_profile_name = "${var.stack_name}-das"
    instance_profile_roles = "${module.das_log_group.role}"
}

module "das_security_group" {
    source = "modules/das_security_group"
    das_security_group_vpc_id = "${module.vpc.id}"
    das_security_group_bastion_security_group = "${module.bastion_security_group.id}"
    das_security_group_name = "${var.stack_name}-das"
    das_security_group_description = "${var.stack_description}"
    das_security_group_tag_project = "${var.stack_name}"
    das_security_group_tag_environment = "${var.aws_target_env}"
}

module "primary_das_instance_user_data" {
    source = "modules/das_user_data"
    das_dc_dns = "${module.dns.das_dc_dns}"
    das_log_group_name = "${module.das_log_group.name}"
    das_log_stream_name = "primary-instance"
    das_log_region = "${lookup(var.region, var.aws_target_env)}"
}

module "primary_das_instance" {
    source = "modules/instance"
    instance_ami = "${lookup(var.das_ami, lookup(var.region, var.aws_target_env))}"
    instance_type = "${lookup(var.das_instance_type, var.aws_target_env)}"
    instance_key_pair = "${lookup(var.das_key_pair, var.aws_target_env)}"
    instance_subnet = "${module.vpc.primary_private_subnet}"
    instance_associate_public_ip_address = "false"
    instance_security_group = "${module.das_security_group.id}"
    instance_profile = "${module.das_instance_profile.name}"
    instance_monitoring = "true"
    instance_disable_api_termination = "false"
    instance_user_data = "${module.primary_das_instance_user_data.user_data}"
    instance_tag_name = "${var.stack_name}-primary-das"
    instance_tag_description = "${var.stack_description}"
    instance_tag_project = "${var.stack_name}"
    instance_tag_environment = "${var.aws_target_env}"
}

module "secondary_das_instance_user_data" {
    source = "modules/das_user_data"
    das_dc_dns = "${module.dns.das_dc_dns}"
    das_log_group_name = "${module.das_log_group.name}"
    das_log_stream_name = "secondary-instance"
    das_log_region = "${lookup(var.region, var.aws_target_env)}"
}

module "secondary_das_instance" {
    source = "modules/instance"
    instance_ami = "${lookup(var.das_ami, lookup(var.region, var.aws_target_env))}"
    instance_type = "${lookup(var.das_instance_type, var.aws_target_env)}"
    instance_key_pair = "${lookup(var.das_key_pair, var.aws_target_env)}"
    instance_subnet = "${module.vpc.secondary_private_subnet}"
    instance_associate_public_ip_address = "false"
    instance_security_group = "${module.das_security_group.id}"
    instance_profile = "${module.das_instance_profile.name}"
    instance_monitoring = "true"
    instance_disable_api_termination = "false"
    instance_user_data = "${module.secondary_das_instance_user_data.user_data}"
    instance_tag_name = "${var.stack_name}-secondary-das"
    instance_tag_description = "${var.stack_description}"
    instance_tag_project = "${var.stack_name}"
    instance_tag_environment = "${var.aws_target_env}"
}

/*
module "ldaps_log_group" {
    source = "modules/log_group"
    log_group_name = "${var.stack_name}-ldaps"
    log_group_region = "${lookup(var.region, var.aws_target_env)}"
}

module "ldaps_instance_profile" {
    source = "modules/instance_profile"
    instance_profile_name = "${var.stack_name}-ldaps"
    instance_profile_roles = "${module.ldaps_log_group.role}"
}

module "ldaps_security_group" {
    source = "modules/ldaps_security_group"
    ldaps_security_group_vpc_id = "${module.vpc.id}"
    ldaps_security_group_bastion_security_group = "${module.bastion_security_group.id}"
    ldaps_security_group_name = "${var.stack_name}-ldaps"
    ldaps_security_group_description = "${var.stack_description}"
    ldaps_security_group_tag_project = "${var.stack_name}"
    ldaps_security_group_tag_environment = "${var.aws_target_env}"
}

module "primary_ldaps_instance_user_data" {
    source = "modules/ldaps_user_data"
    ldaps_dc_dns = "${module.dns.ldaps_dc_dns}"
    ldaps_log_group_name = "${module.ldaps_log_group.name}"
    ldaps_log_stream_name = "primary-instance"
}

module "primary_ldaps_instance" {
    source = "modules/instance"
    instance_ami = "${lookup(var.ldaps_ami, lookup(var.region, var.aws_target_env))}"
    instance_type = "${lookup(var.ldaps_instance_type, var.aws_target_env)}"
    instance_key_pair = "${lookup(var.ldaps_key_pair, var.aws_target_env)}"
    instance_subnet = "${module.vpc.primary_private_subnet}"
    instance_associate_public_ip_address = "false"
    instance_security_group = "${module.ldaps_security_group.id}"
    instance_profile = "${module.ldaps_instance_profile.name}"
    instance_monitoring = "true"
    instance_disable_api_termination = "false"
    instance_user_data = "${module.primary_ldaps_instance_user_data.user_data}"
    instance_tag_name = "${var.stack_name}-primary-ldaps"
    instance_tag_description = "${var.stack_description}"
    instance_tag_project = "${var.stack_name}"
    instance_tag_environment = "${var.aws_target_env}"
}

module "secondary_ldaps_instance_user_data" {
    source = "modules/ldaps_user_data"
    ldaps_dc_dns = "${module.dns.ldaps_dc_dns}"
    ldaps_log_group_name = "${module.ldaps_log_group.name}"
    ldaps_log_stream_name = "secondary-instance"
}

module "secondary_ldaps_instance" {
    source = "modules/instance"
    instance_ami = "${lookup(var.ldaps_ami, lookup(var.region, var.aws_target_env))}"
    instance_type = "${lookup(var.ldaps_instance_type, var.aws_target_env)}"
    instance_key_pair = "${lookup(var.ldaps_key_pair, var.aws_target_env)}"
    instance_subnet = "${module.vpc.secondary_private_subnet}"
    instance_associate_public_ip_address = "false"
    instance_security_group = "${module.ldaps_security_group.id}"
    instance_profile = "${module.ldaps_instance_profile.name}"
    instance_monitoring = "true"
    instance_disable_api_termination = "false"
    instance_user_data = "${module.secondary_ldaps_instance_user_data.user_data}"
    instance_tag_name = "${var.stack_name}-secondary-ldaps"
    instance_tag_description = "${var.stack_description}"
    instance_tag_project = "${var.stack_name}"
    instance_tag_environment = "${var.aws_target_env}"
}
*/

module "tour_api_log_group" {
    source = "modules/log_group"
    log_group_name = "${var.stack_name}-tour-api"
    log_group_region = "${lookup(var.region, var.aws_target_env)}"
}

module "tour_api_instance_profile" {
    source = "modules/instance_profile"
    instance_profile_name = "${var.stack_name}-tour-api"
    instance_profile_roles = "${module.tour_api_log_group.role}"
}

module "tour_api_security_group" {
    source = "modules/tour_api_security_group"
    tour_api_security_group_vpc_id = "${module.vpc.id}"
    tour_api_security_group_bastion_security_group = "${module.bastion_security_group.id}"
    tour_api_security_group_elb_security_group = "${module.tour_api_elb_security_group.id}"
    tour_api_security_group_name = "${var.stack_name}-tour-api"
    tour_api_security_group_description = "${var.stack_description}"
    tour_api_security_group_tag_project = "${var.stack_name}"
    tour_api_security_group_tag_environment = "${var.aws_target_env}"
}

module "primary_tour_api_instance_user_data" {
    source = "modules/tour_api_user_data"
    tour_api_dc_dns = "${module.dns.tour_api_dc_dns}"
    tour_api_log_group_name = "${module.tour_api_log_group.name}"
    tour_api_log_stream_name = "primary-instance"
    tour_api_log_region = "${lookup(var.region, var.aws_target_env)}"
}

module "primary_tour_api_instance" {
    source = "modules/instance"
    instance_ami = "${lookup(var.tour_api_ami, lookup(var.region, var.aws_target_env))}"
    instance_type = "${lookup(var.tour_api_instance_type, var.aws_target_env)}"
    instance_key_pair = "${lookup(var.tour_api_key_pair, var.aws_target_env)}"
    instance_subnet = "${module.vpc.primary_private_subnet}"
    instance_associate_public_ip_address = "false"
    instance_security_group = "${module.tour_api_security_group.id}"
    instance_profile = "${module.tour_api_instance_profile.name}"
    instance_monitoring = "true"
    instance_disable_api_termination = "false"
    instance_user_data = "${module.primary_tour_api_instance_user_data.user_data}"
    instance_tag_name = "${var.stack_name}-primary-tour-api"
    instance_tag_description = "${var.stack_description}"
    instance_tag_project = "${var.stack_name}"
    instance_tag_environment = "${var.aws_target_env}"
}

module "secondary_tour_api_instance_user_data" {
    source = "modules/tour_api_user_data"
    tour_api_dc_dns = "${module.dns.tour_api_dc_dns}"
    tour_api_log_group_name = "${module.tour_api_log_group.name}"
    tour_api_log_stream_name = "secondary-instance"
    tour_api_log_region = "${lookup(var.region, var.aws_target_env)}"
}

module "secondary_tour_api_instance" {
    source = "modules/instance"
    instance_ami = "${lookup(var.tour_api_ami, lookup(var.region, var.aws_target_env))}"
    instance_type = "${lookup(var.tour_api_instance_type, var.aws_target_env)}"
    instance_key_pair = "${lookup(var.tour_api_key_pair, var.aws_target_env)}"
    instance_subnet = "${module.vpc.secondary_private_subnet}"
    instance_associate_public_ip_address = "false"
    instance_security_group = "${module.tour_api_security_group.id}"
    instance_profile = "${module.tour_api_instance_profile.name}"
    instance_monitoring = "true"
    instance_disable_api_termination = "false"
    instance_user_data = "${module.secondary_tour_api_instance_user_data.user_data}"
    instance_tag_name = "${var.stack_name}-secondary-tour-api"
    instance_tag_description = "${var.stack_description}"
    instance_tag_project = "${var.stack_name}"
    instance_tag_environment = "${var.aws_target_env}"
}

module "tour_api_elb_security_group" {
    source = "modules/tour_api_elb_security_group"
    tour_api_elb_security_group_vpc_id = "${module.vpc.id}"
    tour_api_elb_security_group_tour_api_security_group = "${module.tour_api_security_group.id}"
    tour_api_elb_security_group_name = "${var.stack_name}-tour-api-elb"
    tour_api_elb_security_group_description = "${var.stack_description}"
    tour_api_elb_security_group_tag_project = "${var.stack_name}"
    tour_api_elb_security_group_tag_environment = "${var.aws_target_env}"
}

module "tour_api_elb" {
    source = "modules/https_elb"
    https_elb_subnets = "${module.vpc.primary_public_subnet},${module.vpc.secondary_public_subnet}"
    https_elb_cross_zone = "true"
    https_elb_idle_timeout = "30"
    https_elb_connection_draining = "true"
    https_elb_connection_draining_timeout = "30"
    https_elb_security_groups = "${module.tour_api_elb_security_group.id}"
    https_elb_ssl_cert_arn = "${lookup(var.ssl_cert, var.aws_target_env)}"
    https_elb_instances = "${module.primary_tour_api_instance.id},${module.secondary_tour_api_instance.id}"
    https_elb_instance_port = "80"
    https_elb_instance_protocol = "HTTP"
    https_elb_healthy_threshold = "3"
    https_elb_unhealthy_threshold = "3"
    https_elb_health_check_timeout = "30"
    https_elb_health_check_target_path = "health-check"
    https_elb_health_check_interval = "60"
    https_elb_tag_name = "${var.stack_name}-tour-api"
    https_elb_tag_description = "${var.stack_description}"
    https_elb_tag_project = "${var.stack_name}"
    https_elb_tag_environment = "${var.aws_target_env}"
}

module "dns" {
    source = "modules/dns"
    dns_hosted_zone_id = "${lookup(var.hosted_zone_id, var.aws_target_env)}"
    dns_dc_ingress_ip = "${lookup(var.dc_ingress_ip, var.aws_target_env)}"
    dns_bastion_instance_public_ip = "${module.bastion_instance.public_ip}"
    dns_tropics_dns = "tropics.${var.aws_target_env}.travcorpservices.com"
    dns_primary_tropics_instance_private_ip = "${module.primary_tropics_instance.private_ip}"
    dns_tropics_dc_dns = "dc-tropics.${var.aws_target_env}.travcorpservices.com"
    dns_das_dns = "das.${var.aws_target_env}.travcorpservices.com"
    dns_primary_das_instance_private_ip = "${module.primary_das_instance.private_ip}"
    dns_das_dc_dns = "dc-das.${var.aws_target_env}.travcorpservices.com"
    #dns_ldaps_dns = "ldaps.${var.aws_target_env}.travcorpservices.com"
    #dns_ldaps_dc_dns = "dc-ldaps.${var.aws_target_env}.travcorpservices.com"
    #dns_primary_ldaps_instance_private_ip = "${module.primary_ldaps_instance.private_ip}"
    dns_tour_api_dns = "tours.${var.aws_target_env}.travcorpservices.com"
    dns_tour_api_elb_dns_name = "${module.tour_api_elb.dns_name}"
    dns_tour_api_dc_dns = "dc-tours.${var.aws_target_env}.travcorpservices.com"
}
