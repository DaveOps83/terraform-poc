provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${lookup(var.aws_region, var.aws_target_env)}"
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags {
        Name = "${var.aws_stack_name}"
        Description = "${var.aws_stack_description}"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_subnet" "private_az" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "${lookup(var.aws_az, var.aws_target_env)}"
    tags {
        Name = "${var.aws_stack_name}-private-az"
        Description = "${var.aws_stack_description}"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_subnet" "public_az" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.3.0/24"
    availability_zone = "${lookup(var.aws_az, var.aws_target_env)}"
    tags {
        Name = "${var.aws_stack_name}-public-az"
        Description = "${var.aws_stack_description}"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.aws_stack_name}"
        Description = "${var.aws_stack_description}"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_route_table" "private_subnet_az" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gateway.id}"
    }
    tags {
        Name = "${var.aws_stack_name}-private-az"
        Description = "${var.aws_stack_description}"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_route_table_association" "private_az_private_subnet" {
    subnet_id = "${aws_subnet.private_az.id}"
    route_table_id = "${aws_route_table.private_subnet_az.id}"
}

resource "aws_route_table" "public_subnets" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
    }
    tags {
        Name = "${var.aws_stack_name}-public"
        Description = "${var.aws_stack_description}"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_route_table_association" "public_az_public_subnet" {
    subnet_id = "${aws_subnet.public_az.id}"
    route_table_id = "${aws_route_table.public_subnets.id}"
}

resource "aws_security_group" "dcproxy_nodes" {
    name = "${var.aws_stack_name}-nodes"
    description = "${var.aws_stack_description}"
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.aws_stack_name}-nodes"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_security_group_rule" "dcproxy_nodes_ssh_from_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.bastion.id}"
    security_group_id = "${aws_security_group.dcproxy_nodes.id}"
}

resource "aws_security_group_rule" "dcproxy_nodes_http_from_all" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.dcproxy_nodes.id}"
}

resource "aws_security_group_rule" "dcproxy_nodes_http_to_all" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.dcproxy_nodes.id}"
}

resource "aws_security_group_rule" "dcproxy_nodes_https_to_all" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.dcproxy_nodes.id}"
}

resource "aws_security_group" "bastion" {
    name = "${var.aws_stack_name}-bastion-node"
    description = "${var.aws_stack_description}"
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.aws_stack_name}-bastion-node"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
}

resource "aws_security_group_rule" "bastion_ssh_from_london" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["***REMOVED***"]
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_ssh_to_dcproxy_nodes" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.dcproxy_nodes.id}"
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_http_to_all" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_https_to_all" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.bastion.id}"
}

resource "template_file" "dcproxy_node_user_data" {
  template = "${var.dcproxy_user_data}"
  vars {
    dc_dns = "${lookup(var.dc_dns, var.aws_target_env)}"
  }
}

resource "template_cloudinit_config" "dcproxy_node_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.dcproxy_node_user_data.rendered}"
  }
}

resource "template_file" "bastion_user_data" {
  template = "${var.bastion_user_data}"
}

resource "template_cloudinit_config" "bastion_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.bastion_user_data.rendered}"
  }
}

resource "aws_instance" "dcproxy_node" {
    instance_type = "${lookup(var.dcproxy_instance_type, var.aws_target_env)}"
    ami = "${lookup(var.aws_ami, lookup(var.aws_region, var.aws_target_env))}"
    key_name = "${lookup(var.dcproxy_key_pair, var.aws_target_env)}"
    subnet_id = "${aws_subnet.private_az.id}"
    private_ip = "10.0.1.248"
    vpc_security_group_ids = ["${aws_security_group.dcproxy_nodes.id}"]
    disable_api_termination = "false"
    user_data = "${template_cloudinit_config.dcproxy_node_config.rendered}"
    tags {
        Name = "${var.aws_stack_name}-node"
        Description = "${var.aws_stack_description}"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
    depends_on = ["aws_nat_gateway.nat_gateway"]
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = "${lookup(var.aws_nat_gateway_eip, var.aws_target_env)}"
    subnet_id = "${aws_subnet.public_az.id}"
    depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_instance" "bastion" {
    instance_type = "${var.bastion_instance_type}"
    ami = "${lookup(var.aws_ami, lookup(var.aws_region, var.aws_target_env))}"
    key_name = "${lookup(var.bastion_key_pair, var.aws_target_env)}"
    subnet_id = "${aws_subnet.public_az.id}"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
    disable_api_termination = "false"
    user_data = "${template_cloudinit_config.bastion_config.rendered}"
    tags {
        Name = "${var.aws_stack_name}-bastion"
        Description = "${var.aws_stack_description}"
        Project = "${var.aws_stack_name}"
        Environment = "${var.aws_target_env}"
    }
    depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_route53_record" "dc" {
   zone_id = "${lookup(var.aws_hosted_zone, var.aws_target_env)}"
   name = "${lookup(var.dc_dns, var.aws_target_env)}"
   type = "A"
   ttl = "300"
   records = ["${lookup(var.dc_ip, var.aws_target_env)}"]
}

resource "aws_route53_record" "dcproxy" {
   zone_id = "${lookup(var.aws_hosted_zone, var.aws_target_env)}"
   name = "${lookup(var.dcproxy_dns, var.aws_target_env)}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.dcproxy_node.private_ip}"]
}
