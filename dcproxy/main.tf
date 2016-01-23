provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${lookup(var.region, var.aws_target_env)}"
}

module "vpc" {
    source = "modules/vpc"
    vpc_cidr_block = "10.0.0.0/26"
    vpc_primary_private_cidr_block = "10.0.0.0/28"
    vpc_primary_public_cidr_block = "10.0.0.16/28"
    vpc_secondary_private_cidr_block = "10.0.0.32/28"
    vpc_secondary_public_cidr_block = "10.0.0.48/28"
    vpc_primary_az = "${lookup(var.primary_az, var.aws_target_env)}"
    vpc_secondary_az = "${lookup(var.secondary_az, var.aws_target_env)}"
    vpc_primary_nat_gateway_eip = "${lookup(var.primary_nat_gateway_eip, var.aws_target_env)}"
    vpc_secondary_nat_gateway_eip = "${lookup(var.secondary_nat_gateway_eip, var.aws_target_env)}"
    vpc_name_tag = "${var.stack_name}"
    vpc_description_tag = "${var.stack_description}"
    vpc_project_tag = "${var.stack_name}"
    vpc_environment_tag = "${var.aws_target_env}"
}

module "bastion_security_group" {
    source = "modules/bastion_security_group"
    bastion_security_group_vpc_id = "${module.vpc.id}"
    bastion_security_group_ssh_source_range = "${var.dc_egress_range}"
    bastion_security_group_primary_private_cidr_block = "${module.vpc.primary_private_cidr_block}"
    bastion_security_group_secondary_private_cidr_block = "${module.vpc.secondary_private_cidr_block}"
    bastion_security_group_name = "${var.stack_name}-bastion"
    bastion_security_group_description = "${var.stack_description}"
    bastion_security_group_tag_project = "${var.stack_name}"
    bastion_security_group_tag_environment = "${var.aws_target_env}"
}

module "bastion_instance" {
    source = "modules/bastion_instance"
    bastion_ami = "${lookup(var.bastion_ami, lookup(var.region, var.aws_target_env))}"
    bastion_instance_type = "t2.nano"
    bastion_key_pair = "${lookup(var.bastion_key_pair, var.aws_target_env)}"
    bastion_subnet = "${module.vpc.primary_public_subnet}"
    bastion_security_group = "${module.bastion_security_group.id}"
    bastion_tag_name = "${var.stack_name}-bastion"
    bastion_tag_description = "${var.stack_description}"
    bastion_tag_project = "${var.stack_name}"
    bastion_tag_environment = "${var.aws_target_env}"
}

module "tropics_security_group" {
    source = "modules/http_security_group"
    http_security_group_vpc_id = "${module.vpc.id}"
    http_security_group_bastion_private_ip = "${module.bastion_instance.private_ip}"
    http_security_group_primary_nat_gateway_ip = "${module.vpc.primary_nat_gateway_ip}"
    http_security_group_secondary_nat_gateway_ip = "${module.vpc.secondary_nat_gateway_ip}"
    http_security_group_name = "${var.stack_name}-tropics"
    http_security_group_description = "${var.stack_description}"
    http_security_group_tag_project = "${var.stack_name}"
    http_security_group_tag_environment = "${var.aws_target_env}"
}

module "primary_tropics_instance" {
    source = "modules/tropics_instance"
    tropics_ami = "${lookup(var.tropics_ami, lookup(var.region, var.aws_target_env))}"
    tropics_instance_type = "${lookup(var.tropics_instance_type, var.aws_target_env)}"
    tropics_key_pair = "${lookup(var.tropics_key_pair, var.aws_target_env)}"
    tropics_subnet = "${module.vpc.primary_private_subnet}"
    tropics_security_group = "${module.tropics_security_group.id}"
    tropics_tag_name = "${var.stack_name}-primary-tropics"
    tropics_tag_description = "${var.stack_description}"
    tropics_tag_project = "${var.stack_name}"
    tropics_tag_environment = "${var.aws_target_env}"
    tropics_dc_dns = "${module.dns.dc_ingress_dns}"
}

module "secondary_tropics_instance" {
    source = "modules/tropics_instance"
    tropics_ami = "${lookup(var.tropics_ami, lookup(var.region, var.aws_target_env))}"
    tropics_instance_type = "${lookup(var.tropics_instance_type, var.aws_target_env)}"
    tropics_key_pair = "${lookup(var.tropics_key_pair, var.aws_target_env)}"
    tropics_subnet = "${module.vpc.secondary_private_subnet}"
    tropics_security_group = "${module.tropics_security_group.id}"
    tropics_tag_name = "${var.stack_name}-secondary-tropics"
    tropics_tag_description = "${var.stack_description}"
    tropics_tag_project = "${var.stack_name}"
    tropics_tag_environment = "${var.aws_target_env}"
    tropics_dc_dns = "${module.dns.dc_ingress_dns}"
}

module "das_security_group" {
    source = "modules/http_security_group"
    http_security_group_vpc_id = "${module.vpc.id}"
    http_security_group_bastion_private_ip = "${module.bastion_instance.private_ip}"
    http_security_group_primary_nat_gateway_ip = "${module.vpc.primary_nat_gateway_ip}"
    http_security_group_secondary_nat_gateway_ip = "${module.vpc.secondary_nat_gateway_ip}"
    http_security_group_name = "${var.stack_name}-das"
    http_security_group_description = "${var.stack_description}"
    http_security_group_tag_project = "${var.stack_name}"
    http_security_group_tag_environment = "${var.aws_target_env}"
}

module "primary_das_instance" {
    source = "modules/das_instance"
    das_ami = "${lookup(var.das_ami, lookup(var.region, var.aws_target_env))}"
    das_instance_type = "${lookup(var.das_instance_type, var.aws_target_env)}"
    das_key_pair = "${lookup(var.das_key_pair, var.aws_target_env)}"
    das_subnet = "${module.vpc.primary_private_subnet}"
    das_security_group = "${module.das_security_group.id}"
    das_tag_name = "${var.stack_name}-primary-das"
    das_tag_description = "${var.stack_description}"
    das_tag_project = "${var.stack_name}"
    das_tag_environment = "${var.aws_target_env}"
    das_dc_dns = "${module.dns.dc_ingress_dns}"
}

module "secondary_das_instance" {
    source = "modules/das_instance"
    das_ami = "${lookup(var.das_ami, lookup(var.region, var.aws_target_env))}"
    das_instance_type = "${lookup(var.das_instance_type, var.aws_target_env)}"
    das_key_pair = "${lookup(var.das_key_pair, var.aws_target_env)}"
    das_subnet = "${module.vpc.secondary_private_subnet}"
    das_security_group = "${module.das_security_group.id}"
    das_tag_name = "${var.stack_name}-secondary-das"
    das_tag_description = "${var.stack_description}"
    das_tag_project = "${var.stack_name}"
    das_tag_environment = "${var.aws_target_env}"
    das_dc_dns = "${module.dns.dc_ingress_dns}"
}

module "ldaps_security_group" {
    source = "modules/ldaps_security_group"
    ldaps_security_group_vpc_id = "${module.vpc.id}"
    ldaps_security_group_bastion_private_ip = "${module.bastion_instance.private_ip}"
    ldaps_security_group_primary_nat_gateway_ip = "${module.vpc.primary_nat_gateway_ip}"
    ldaps_security_group_secondary_nat_gateway_ip = "${module.vpc.secondary_nat_gateway_ip}"
    ldaps_security_group_name = "${var.stack_name}-ldaps"
    ldaps_security_group_description = "${var.stack_description}"
    ldaps_security_group_tag_project = "${var.stack_name}"
    ldaps_security_group_tag_environment = "${var.aws_target_env}"
}

module "primary_ldaps_instance" {
    source = "modules/ldaps_instance"
    ldaps_ami = "${lookup(var.ldaps_ami, lookup(var.region, var.aws_target_env))}"
    ldaps_instance_type = "${lookup(var.ldaps_instance_type, var.aws_target_env)}"
    ldaps_key_pair = "${lookup(var.ldaps_key_pair, var.aws_target_env)}"
    ldaps_subnet = "${module.vpc.primary_private_subnet}"
    ldaps_security_group = "${module.ldaps_security_group.id}"
    ldaps_tag_name = "${var.stack_name}-primary-ldaps"
    ldaps_tag_description = "${var.stack_description}"
    ldaps_tag_project = "${var.stack_name}"
    ldaps_tag_environment = "${var.aws_target_env}"
    ldaps_dc_dns = "${module.dns.dc_ingress_dns}"
}

module "secondary_ldaps_instance" {
    source = "modules/ldaps_instance"
    ldaps_ami = "${lookup(var.ldaps_ami, lookup(var.region, var.aws_target_env))}"
    ldaps_instance_type = "${lookup(var.ldaps_instance_type, var.aws_target_env)}"
    ldaps_key_pair = "${lookup(var.ldaps_key_pair, var.aws_target_env)}"
    ldaps_subnet = "${module.vpc.secondary_private_subnet}"
    ldaps_security_group = "${module.ldaps_security_group.id}"
    ldaps_tag_name = "${var.stack_name}-secondary-ldaps"
    ldaps_tag_description = "${var.stack_description}"
    ldaps_tag_project = "${var.stack_name}"
    ldaps_tag_environment = "${var.aws_target_env}"
    ldaps_dc_dns = "${module.dns.dc_ingress_dns}"
}

module "dns" {
    source = "modules/dns"
    dns_hosted_zone_id = "${lookup(var.hosted_zone_id, var.aws_target_env)}"
    dns_dc_ingress_dns = "dc.${var.aws_target_env}.travcorpservices.com"
    dns_dc_ingress_ip = "${lookup(var.dc_ingress_ip, var.aws_target_env)}"
    dns_tropics_dns = "tropics.${var.aws_target_env}.travcorpservices.com"
    dns_primary_tropics_instance_private_ip = "${module.primary_tropics_instance.private_ip}"
    dns_das_dns = "das.${var.aws_target_env}.travcorpservices.com"
    dns_primary_das_instance_private_ip = "${module.primary_das_instance.private_ip}"
    dns_ldaps_dns = "ldaps.${var.aws_target_env}.travcorpservices.com"
    dns_primary_ldaps_instance_private_ip = "${module.primary_ldaps_instance.private_ip}"
}

output "Primary NAT Gateway Public IP" {
    value = "${module.vpc.primary_nat_gateway_eip}"
}

output "Secondary NAT Gateway Public IP" {
    value = "${module.vpc.secondary_nat_gateway_eip}"
}

output "TROPICS Res API" {
    value = "http://${module.dns.tropics_dns}/tropics/TropicsWS"
}

output "TROPICS Build API" {
    value = "http://${module.dns.tropics_dns}/tropics/TropicsBuildWS"
}

output "TROPICS Customer Sync API" {
    value = "http://${module.dns.tropics_dns}/tropics/CustomerSyncWS"
}

output "Data Access Services" {
    value = "http://${module.dns.das_dns}/DataAccessServices/OracleDataService.svc"
}

output "LDAPS" {
    value = "http://${module.dns.ldaps_dns}"
}

output "VPC CIDR block" {
    value = "${module.vpc.cidr_block}"
}

output "VPC ID" {
    value = "${module.vpc.id}"
}

output "Primary Private Subnet Route Table ID" {
    value = "${module.vpc.primary_private_route_table}"
}

output "Primary Private Subnet CIDR block" {
    value = "${module.vpc.primary_private_cidr_block}"
}

output "Secondary Private Subnet Route Table ID" {
    value = "${module.vpc.secondary_private_route_table}"
}

output "Secondary Private Subnet CIDR block" {
    value = "${module.vpc.secondary_private_cidr_block}"
}

output "Bastion SSH command" {
    value = "ssh -i ${module.bastion_instance.key_name}.pem ec2-user@${module.bastion_instance.public_ip}"
}
