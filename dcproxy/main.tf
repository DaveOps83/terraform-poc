provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags {
        Name = "${var.stack_name}"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_subnet" "private_az_1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.az_1}"
    tags {
        Name = "${var.stack_name}-private-az-1"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_subnet" "private_az_2" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.az_2}"
    tags {
        Name = "${var.stack_name}-private-az-2"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_subnet" "public_az_1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.3.0/24"
    availability_zone = "${var.az_1}"
    tags {
        Name = "${var.stack_name}-public-az-1"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_subnet" "public_az_2" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.4.0/24"
    availability_zone = "${var.az_2}"
    tags {
        Name = "${var.stack_name}-public-az-2"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.stack_name}"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_route_table" "private_subnet_az_1" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gateway_1.id}"
    }
    tags {
        Name = "${var.stack_name}-private-az-1"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_route_table" "private_subnet_az_2" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat_gateway_2.id}"
    }
    tags {
        Name = "${var.stack_name}-private-az-2"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_route_table_association" "private_az_1_private_subnet" {
    subnet_id = "${aws_subnet.private_az_1.id}"
    route_table_id = "${aws_route_table.private_subnet_az_1.id}"
}

resource "aws_route_table_association" "private_az_2_private_subnet" {
    subnet_id = "${aws_subnet.private_az_2.id}"
    route_table_id = "${aws_route_table.private_subnet_az_2.id}"
}

resource "aws_route_table" "public_subnets" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
    }
    tags {
        Name = "${var.stack_name}-public"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_route_table_association" "public_az_1_public_subnet" {
    subnet_id = "${aws_subnet.public_az_1.id}"
    route_table_id = "${aws_route_table.public_subnets.id}"
}

resource "aws_route_table_association" "public_az_2_public_subnet" {
    subnet_id = "${aws_subnet.public_az_2.id}"
    route_table_id = "${aws_route_table.public_subnets.id}"
}

resource "aws_security_group" "dcproxy_nodes" {
    name = "${var.stack_name}-nodes"
    description = "${var.stack_description}"
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.stack_name}-nodes"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_security_group_rule" "dcproxy_nodes_ssh_from_bastion" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.bastion_node.id}"
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

resource "aws_security_group" "bastion_node" {
    name = "${var.stack_name}-bastion-node"
    description = "${var.stack_description}"
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.stack_name}-bastion-node"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_security_group_rule" "bastion_node_ssh_from_london" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["***REMOVED***"]
    security_group_id = "${aws_security_group.bastion_node.id}"
}

resource "aws_security_group_rule" "bastion_node_ssh_to_dcproxy_nodes" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.dcproxy_nodes.id}"
    security_group_id = "${aws_security_group.bastion_node.id}"
}

resource "aws_security_group_rule" "bastion_node_http_to_all" {
    type = "egress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.bastion_node.id}"
}

resource "aws_security_group_rule" "bastion_node_https_to_all" {
    type = "egress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.bastion_node.id}"
}

resource "template_file" "dcproxy_node_user_data" {
  template = "${var.dcproxy_user_data}"
  vars {
    dc_dns = "dc.qa.travcorpservices.com"
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

resource "template_file" "bastion_node_user_data" {
  template = "${var.bastion_user_data}"
  vars {
    dcproxy_private_key = "${var.bastion_dcproxy_private_key_destination}/${var.dcproxy_key_pair}.pem"
  }
}

resource "template_cloudinit_config" "bastion_node_config" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content      = "${template_file.bastion_node_user_data.rendered}"
  }
}

resource "aws_instance" "dcproxy_node_1" {
    instance_type = "${var.aws_instance_type}"
    ami = "${var.aws_ami}"
    key_name = "${var.dcproxy_key_pair}"
    subnet_id = "${aws_subnet.private_az_1.id}"
    private_ip = "10.0.1.248"
    vpc_security_group_ids = ["${aws_security_group.dcproxy_nodes.id}"]
    #disable_api_termination = "true"
    user_data = "${template_cloudinit_config.dcproxy_node_config.rendered}"
    tags {
        Name = "${var.stack_name}-node-1"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
    depends_on = ["aws_nat_gateway.nat_gateway_1"]
}

resource "aws_nat_gateway" "nat_gateway_1" {
    allocation_id = "${var.aws_nat_gateway_eip_1}"
    subnet_id = "${aws_subnet.public_az_1.id}"
    depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_instance" "dcproxy_node_2" {
    instance_type = "${var.aws_instance_type}"
    ami = "${var.aws_ami}"
    key_name = "${var.dcproxy_key_pair}"
    subnet_id = "${aws_subnet.private_az_2.id}"
    private_ip = "10.0.2.248"
    vpc_security_group_ids = ["${aws_security_group.dcproxy_nodes.id}"]
    #disable_api_termination = "true"
    user_data = "${template_cloudinit_config.dcproxy_node_config.rendered}"
    tags {
        Name = "${var.stack_name}-node-2"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
    depends_on = ["aws_nat_gateway.nat_gateway_2"]
}

resource "aws_nat_gateway" "nat_gateway_2" {
    allocation_id = "${var.aws_nat_gateway_eip_2}"
    subnet_id = "${aws_subnet.public_az_2.id}"
    depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_instance" "bastion_node" {
    instance_type = "${var.aws_instance_type}"
    ami = "${var.aws_ami}"
    key_name = "${var.bastion_key_pair}"
    subnet_id = "${aws_subnet.public_az_1.id}"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["${aws_security_group.bastion_node.id}"]
    user_data = "${template_cloudinit_config.bastion_node_config.rendered}"
    provisioner "file" {
    source = "${var.private_keys_path}/${var.dcproxy_key_pair}.pem"
    destination = "${var.bastion_dcproxy_private_key_destination}/${var.dcproxy_key_pair}.pem"
    connection {
        user = "ec2-user"
        private_key = "${file("${var.private_keys_path}/${var.bastion_key_pair}.pem")}"
        }
    }
    tags {
        Name = "${var.stack_name}-bastion-node"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
    depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_route53_record" "dc" {
   zone_id = "${var.hosted_zone_id}"
   name = "dc.${var.env_name}.travcorpservices.com"
   type = "A"
   ttl = "300"
   records = ["${var.dc_public_ip}"]
}

resource "aws_route53_record" "dcproxy_node_1" {
   zone_id = "${var.hosted_zone_id}"
   name = "dcproxy-node-1.${var.env_name}.travcorpservices.com"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.dcproxy_node_1.private_ip}"]
}

resource "aws_route53_health_check" "dcproxy_node_1" {
  fqdn = "${aws_route53_record.dcproxy_node_1.name}"
  port = 80
  type = "HTTP"
  resource_path = "/health_check.htm"
  failure_threshold = "5"
  request_interval = "30"
  tags {
        Name = "${var.stack_name}_node_1"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_route53_record" "dcproxy_node_1_alias" {
    zone_id = "${var.hosted_zone_id}"
    name = "dcproxy.${var.env_name}.travcorpservices.com"
    type = "A"
    weight = "50"
    set_identifier = "${var.stack_name}-node-1"
    health_check_id = "${aws_route53_health_check.dcproxy_node_1.id}"
    alias {
        name = "${aws_route53_record.dcproxy_node_1.name}"
        zone_id = "${var.hosted_zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "dcproxy_node_2" {
    zone_id = "${var.hosted_zone_id}"
    name = "dcproxy-node-2.${var.env_name}.travcorpservices.com"
    type = "A"
    ttl = "300"
    records = ["${aws_instance.dcproxy_node_2.private_ip}"]
}

resource "aws_route53_health_check" "dcproxy_node_2" {
    fqdn = "${aws_route53_record.dcproxy_node_2.name}"
    port = 80
    type = "HTTP"
    resource_path = "/health_check.htm"
    failure_threshold = "5"
    request_interval = "30"
    tags {
        Name = "${var.stack_name}_node_2"
        Description = "${var.stack_description}"
        Project = "${var.stack_name}"
        Environment = "${var.env_name}"
    }
}

resource "aws_route53_record" "dcproxy_node_2_alias" {
    zone_id = "${var.hosted_zone_id}"
    name = "dcproxy.${var.env_name}.travcorpservices.com"
    type = "A"
    weight = "50"
    set_identifier = "${var.stack_name}-node-2"
    health_check_id = "${aws_route53_health_check.dcproxy_node_2.id}"
    alias {
        name = "${aws_route53_record.dcproxy_node_2.name}"
        zone_id = "${var.hosted_zone_id}"
        evaluate_target_health = true
  }
}
