provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${lookup(var.region, var.aws_target_env)}"
}

module "vpc" {
    source = "modules/vpc"
    vpc_cidr_block = "10.0.0.0/16"
    primary_private_cidr_block = "10.0.1.0/16"
    primary_public_cidr_block = "10.0.2.0/16"
    secondary_private_cidr_block = "10.0.3.0/16"
    secondary_public_cidr_block = "10.0.4.0/16"
    primary_az = "${lookup(var.primary_az, var.aws_target_env)}"
    secondary_az = "${lookup(var.secondary_az, var.aws_target_env)}"
    primary_nat_gateway_eip = "${var.primary_nat_gateway_eip}"
    secondary_nat_gateway_eip = "${var.secondary_nat_gateway_eip}"
    name_tag = "${var.stack_name}"
    description_tag = "${var.stack_description}"
    project_tag = "${var.stack_name}"
    environment_tag = "${var.aws_target_env}"
}

module "bastion_security_group" {
    source = "modules/bastion_security_group"
    vpc_id = "${module.vpc.id}"
    ssh_source_range = "${var.dc_egress_range}"
    primary_private_cidr_block = "${var.primary_private_cidr_block}"
    secondary_private_cidr_block = "${var.secondary_private_cidr_block}"
    name = "${var.stack_name}"
    description = "${var.stack_description}"
    tag_project = "${var.stack_name}"
    tag_environment = "${var.aws_target_env}"
}

module "bastion_instance" {
    source = "modules/bastion_instance"
    bastion_subnet = "${module.vpc.primary_public_subnet}"
    bastion_security_group = "${module.bastion_security_group.id}"
    bastion_tag_name = "${var.stack_name}"
    bastion_tag_description = "${var.stack_description}"
    bastion_tag_project = "${var.stack_name}"
    bastion_tag_environment = "${var.aws_target_env}"
}

module "tropics_security_group" {
    source = "modules/tropics_security_group"
    vpc_id = "${module.vpc.id}"
    bastion_private_ip = "${module.bastion_instance.private_ip}"
    primary_nat_gateway_ip = "${module.vpc.primary_nat_gateway_ip}"
    secondary_nat_gateway_ip = "${module.vpc.secondary_nat_gateway_ip}"
    name = "${var.stack_name}"
    description = "${var.stack_description}"
    tag_project = "${var.stack_name}"
    tag_environment = "${var.aws_target_env}"
}

module "das_security_group" {
    source = "modules/das_security_group"
    vpc_id = "${module.vpc.id}"
    bastion_private_ip = "${module.bastion_instance.private_ip}"
    primary_nat_gateway_ip = "${module.vpc.primary_nat_gateway_ip}"
    secondary_nat_gateway_ip = "${module.vpc.secondary_nat_gateway_ip}"
    name = "${var.stack_name}"
    description = "${var.stack_description}"
    tag_project = "${var.stack_name}"
    tag_environment = "${var.aws_target_env}"
}

module "ldaps_security_group" {
    source = "modules/ldaps_security_group"
    vpc_id = "${module.vpc.id}"
    bastion_private_ip = "${module.bastion_instance.private_ip}"
    primary_nat_gateway_ip = "${module.vpc.primary_nat_gateway_ip}"
    secondary_nat_gateway_ip = "${module.vpc.secondary_nat_gateway_ip}"
    name = "${var.stack_name}"
    description = "${var.stack_description}"
    tag_project = "${var.stack_name}"
    tag_environment = "${var.aws_target_env}"
}

resource "template_file" "tropics_user_data" {
  template = "${file("${path.root}/${var.tropics_user_data}")}"
  vars {
    dns = "${lookup(var.tropics_dns, var.aws_target_env)}"
    dc_dns = "${lookup(var.dc_dns, var.aws_target_env)}"
  }
}

resource "template_cloudinit_config" "tropics_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.tropics_user_data.rendered}"
  }
}

resource "template_file" "das_user_data" {
  template = "${file("${path.root}/${var.das_user_data}")}"
  vars {
    dns = "${lookup(var.tropics_dns, var.aws_target_env)}"
    dc_dns = "${lookup(var.dc_dns, var.aws_target_env)}"
  }
}

resource "template_cloudinit_config" "das_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.das_user_data.rendered}"
  }
}

resource "template_file" "ldaps_user_data" {
  template = "${file("${path.root}/${var.ldaps_user_data}")}"
  vars {
    dns = "${lookup(var.ldaps_dns, var.aws_target_env)}"
    dc_dns = "${lookup(var.dc_dns, var.aws_target_env)}"
  }
}

resource "template_cloudinit_config" "ldaps_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.ldaps_user_data.rendered}"
  }
}



resource "aws_instance" "primary_tropics" {
    instance_type = "${lookup(var.tropics_instance_type, var.aws_target_env)}"
    ami = "${lookup(var.tropics_ami, lookup(var.region, var.aws_target_env))}"
    key_name = "${lookup(var.dcproxy_key_pair, var.aws_target_env)}"
    subnet_id = "${module.vpc.primary_private_subnet}"
    private_ip = "10.0.1.248"
    vpc_security_group_ids = ["${module.tropics_security_group.id}"]
    disable_api_termination = "false"
    user_data = "${template_cloudinit_config.tropics_config.rendered}"
    tags {
        Name = "${var.stack_name}-primary-tropics"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_instance" "primary_das" {
    instance_type = "${lookup(var.das_instance_type, var.aws_target_env)}"
    ami = "${lookup(var.das_ami, lookup(var.region, var.aws_target_env))}"
    key_name = "${lookup(var.dcproxy_key_pair, var.aws_target_env)}"
    subnet_id = "${module.vpc.primary_private_subnet}"
    private_ip = "10.0.1.247"
    vpc_security_group_ids = ["${module.tropics_security_group.id}"]
    disable_api_termination = "false"
    user_data = "${template_cloudinit_config.das_config.rendered}"
    tags {
        Name = "${var.stack_name}-primary-das"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_instance" "primary_ldaps" {
    instance_type = "${lookup(var.ldaps_instance_type, var.aws_target_env)}"
    ami = "${lookup(var.ldaps_ami, lookup(var.region, var.aws_target_env))}"
    key_name = "${lookup(var.dcproxy_key_pair, var.aws_target_env)}"
    subnet_id = "${module.vpc.primary_private_subnet}"
    private_ip = "10.0.1.246"
    vpc_security_group_ids = ["${module.tropics_security_group.id}"]
    disable_api_termination = "false"
    user_data = "${template_cloudinit_config.ldaps_config.rendered}"
    tags {
        Name = "${var.stack_name}-primary-ldaps"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_route53_record" "dc" {
   zone_id = "${lookup(var.aws_hosted_zone, var.aws_target_env)}"
   name = "${lookup(var.dc_dns, var.aws_target_env)}"
   type = "A"
   ttl = "300"
   records = ["${lookup(var.dc_ingress_ip, var.aws_target_env)}"]
}

resource "aws_route53_record" "tropics" {
   zone_id = "${lookup(var.aws_hosted_zone, var.aws_target_env)}"
   name = "${lookup(var.tropics_dns, var.aws_target_env)}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.primary_tropics.private_ip}"]
}

resource "aws_route53_record" "das" {
   zone_id = "${lookup(var.aws_hosted_zone, var.aws_target_env)}"
   name = "${lookup(var.das_dns, var.aws_target_env)}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.primary_das.private_ip}"]
}

resource "aws_route53_record" "ldaps" {
   zone_id = "${lookup(var.aws_hosted_zone, var.aws_target_env)}"
   name = "${lookup(var.ldaps_dns, var.aws_target_env)}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.primary_ldaps.private_ip}"]
}

output "Primary NAT Gateway Public IP" {
    value = "${module.vpc.primary_nat_gateway_eip}"
}

output "Secondary NAT Gateway Public IP" {
    value = "${module.vpc.secondary_nat_gateway_eip}"
}

output "TROPICS Res API" {
    value = "http://${aws_route53_record.tropics.name}/tropics/TropicsWS"
}

output "TROPICS Build API" {
    value = "http://${aws_route53_record.tropics.name}/tropics/TropicsBuildWS"
}

output "TROPICS Customer Sync API" {
    value = "http://${aws_route53_record.tropics.name}/tropics/CustomerSyncWS"
}

output "Data Access Services" {
    value = "http://${aws_route53_record.das.name}/DataAccessServices/OracleDataService.svc"
}

output "LDAPS" {
    value = "ldaps://${aws_route53_record.ldaps.name}"
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
