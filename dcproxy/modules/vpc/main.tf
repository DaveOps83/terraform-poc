resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr_block}"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags {
        Name = "${var.vpc_name_tag}"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_project_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.vpc_name_tag}"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_name_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_subnet" "primary_private" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.vpc_primary_private_cidr_block}"
    availability_zone = "${var.vpc_primary_az}"
    tags {
        Name = "${var.vpc_name_tag}-primary-private"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_project_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_route_table" "primary_private" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.primary_nat_gateway.id}"
    }
    #Ignore changes to this route table made to support PCX connections.
    lifecycle {
        ignore_changes = ["route"]
    }
    tags {
        Name = "${var.vpc_name_tag}-primary-private"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_project_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_route_table_association" "primary_private" {
    subnet_id = "${aws_subnet.primary_private.id}"
    route_table_id = "${aws_route_table.primary_private.id}"
}

resource "aws_subnet" "primary_public" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.vpc_primary_public_cidr_block}"
    availability_zone = "${var.vpc_primary_az}"
    tags {
        Name = "${var.vpc_name_tag}-primary-public"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_name_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_route_table" "primary_public" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
    }
    tags {
        Name = "${var.vpc_name_tag}-primary-public"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_name_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_route_table_association" "primary_public" {
    subnet_id = "${aws_subnet.primary_public.id}"
    route_table_id = "${aws_route_table.primary_public.id}"
}

resource "aws_nat_gateway" "primary_nat_gateway" {
    allocation_id = "${var.vpc_primary_nat_gateway_eip}"
    subnet_id = "${aws_subnet.primary_public.id}"
    depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_subnet" "secondary_private" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.vpc_secondary_private_cidr_block}"
    availability_zone = "${var.vpc_secondary_az}"
    tags {
        Name = "${var.vpc_name_tag}-secondary-private"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_name_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_route_table" "secondary_private" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.secondary_nat_gateway.id}"
    }
    #Ignore changes to this route table made to support PCX connections.
    lifecycle {
        ignore_changes = ["route"]
    }
    tags {
        Name = "${var.vpc_name_tag}-secondary-private"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_name_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_route_table_association" "secondary_private" {
    subnet_id = "${aws_subnet.secondary_private.id}"
    route_table_id = "${aws_route_table.secondary_private.id}"
}

resource "aws_subnet" "secondary_public" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.vpc_secondary_public_cidr_block}"
    availability_zone = "${var.vpc_secondary_az}"
    tags {
        Name = "${var.vpc_name_tag}-secondary-public"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_name_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_route_table" "secondary_public" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
    }
    tags {
        Name = "${var.vpc_name_tag}-secondary-public"
        Description = "${var.vpc_description_tag}"
        Project = "${var.vpc_name_tag}"
        Environment = "${var.vpc_environment_tag}"
    }
}

resource "aws_route_table_association" "secondary_public" {
    subnet_id = "${aws_subnet.secondary_public.id}"
    route_table_id = "${aws_route_table.secondary_public.id}"
}

resource "aws_nat_gateway" "secondary_nat_gateway" {
    allocation_id = "${var.vpc_secondary_nat_gateway_eip}"
    subnet_id = "${aws_subnet.secondary_public.id}"
    depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "template_file" "vpc_flow_logs_trust_policy_document" {
  template = "${file("${path.module}/trust_policy.json")}"
}

resource "aws_iam_role" "vpc_flow_logs" {
    name = "${var.vpc_name_tag}-vpc-flow-logs"
    assume_role_policy = "${template_file.vpc_flow_logs_trust_policy_document.rendered}"
}

resource "template_file" "vpc_flow_logs_role_policy_document" {
  template = "${file("${path.module}/role_policy.json")}"
  vars {
    arn_log_group_name = "${aws_cloudwatch_log_group.vpc_flow_logs_cloudwatch_log_group.name}"
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs_role_policy" {
    name = "${var.vpc_name_tag}-vpc-flow-logs"
    role = "${aws_iam_role.vpc_flow_logs.id}"
    policy = "${template_file.vpc_flow_logs_role_policy_document.rendered}"
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs_cloudwatch_log_group" {
  name = "${var.vpc_name_tag}-vpc-flow"
  retention_in_days = "30"
}

resource "aws_flow_log" "vpc_flow_log" {
  log_group_name = "${aws_cloudwatch_log_group.vpc_flow_logs_cloudwatch_log_group.name}"
  iam_role_arn = "${aws_iam_role.vpc_flow_logs.arn}"
  vpc_id = "${aws_vpc.vpc.id}"
  traffic_type = "REJECT"
}
