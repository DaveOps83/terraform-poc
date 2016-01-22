#Variables
variable "vpc_cidr_block" {}
variable "primary_private_cidr_block" {}
variable "primary_public_cidr_block" {}
variable "secondary_private_cidr_block" {}
variable "secondary_public_cidr_block" {}
variable "primary_az" {}
variable "secondary_az" {}
variable "primary_nat_gateway_eip" {}
variable "secondary_nat_gateway_eip" {}
variable "name_tag" {}
variable "description_tag" {}
variable "project_tag" {}
variable "environment_tag" {}

#Outputs
output "id" { value = "${aws_vpc.vpc.id}" }
output "cidr_block" { value = "${aws_vpc.vpc.cidr_block}" }
output "primary_private_subnet" { value = "${aws_subnet.primary_private.id}" }
output "primary_private_cidr_block" { value = "${aws_subnet.primary_private.cidr_block}" }
output "primary_private_route_table" { value = "${aws_route_table.primary_private.id}" }
output "primary_nat_gateway" { value = "${aws_nat_gateway.primary_nat_gateway.id}" }
output "primary_nat_gateway_ip" { value = "${aws_nat_gateway.primary_nat_gateway.private_ip}" }
output "primary_nat_gateway_eip" { value = "${aws_nat_gateway.primary_nat_gateway.public_ip}" }
output "primary_public_subnet" { value = "${aws_subnet.primary_public.id}" }
output "secondary_private_subnet" { value = "${aws_subnet.secondary_private.id}" }
output "secondary_private_cidr_block" { value = "${aws_subnet.secondary_private.cidr_block}" }
output "secondary_private_route_table" { value = "${aws_route_table.secondary_private.id}" }
output "secondary_nat_gateway_ip" { value = "${aws_nat_gateway.secondary_nat_gateway.private_ip}" }
output "secondary_nat_gateway_eip" { value = "${aws_nat_gateway.secondary_nat_gateway.public_ip}" }
output "secondary_nat_gateway" { value = "${aws_nat_gateway.secondary_nat_gateway.id}" }
output "internet_gateway" { value = "${aws_internet_gateway.internet_gateway.id}" }

#VPC
resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr_block}"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags {
        Name = "${var.name_tag}"
        Description = "${var.description_tag}"
        Project = "${var.project_tag}"
        Environment = "${var.environment_tag}"
    }
}

#Primary private subnet
resource "aws_subnet" "primary_private" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.primary_private_cidr_block}"
    availability_zone = "${var.primary_az}"
    tags {
        Name = "${var.name_tag}-primary-private"
        Description = "${var.description_tag}"
        Project = "${var.project_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table" "primary_private" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.primary_nat_gateway.id}"
    }
    #Ignore changes to this route table made to support PCX connections.
    #lifecycle {
    #    ignore_changes = ["route"]
    #}
    tags {
        Name = "${var.name_tag}-primary-private"
        Description = "${var.description_tag}"
        Project = "${var.project_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table_association" "primary_private" {
    subnet_id = "${aws_subnet.primary_private.id}"
    route_table_id = "${aws_route_table.primary_private.id}"
}

#Primary public subnet
resource "aws_subnet" "primary_public" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.primary_public_cidr_block}"
    availability_zone = "${var.primary_az}"
    tags {
        Name = "${var.name_tag}-primary-public"
        Description = "${var.description_tag}"
        Project = "${var.name_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table" "primary_public" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
    }
    tags {
        Name = "${var.name_tag}-primary-public"
        Description = "${var.description_tag}"
        Project = "${var.name_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table_association" "primary_public" {
    subnet_id = "${aws_subnet.primary_public.id}"
    route_table_id = "${aws_route_table.primary_public.id}"
}

resource "aws_nat_gateway" "primary_nat_gateway" {
    allocation_id = "${var.primary_nat_gateway_eip}"
    subnet_id = "${aws_subnet.primary_public.id}"
    depends_on = ["aws_internet_gateway.internet_gateway"]
}

#Secondary private subnet
resource "aws_subnet" "secondary_private" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.secondary_private_cidr_block}"
    availability_zone = "${var.secondary_az}"
    tags {
        Name = "${var.name_tag}-secondary-private"
        Description = "${var.description_tag}"
        Project = "${var.name_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table" "secondary_private" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.secondary_nat_gateway.id}"
    }
    #Ignore changes to this route table made to support PCX connections.
    #lifecycle {
    #    ignore_changes = ["route"]
    #}
    tags {
        Name = "${var.name_tag}-secondary-private"
        Description = "${var.description_tag}"
        Project = "${var.name_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table_association" "secondary_private" {
    subnet_id = "${aws_subnet.secondary_private.id}"
    route_table_id = "${aws_route_table.secondary_private.id}"
}

#Secondary public subnet
resource "aws_subnet" "secondary_public" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.secondary_public_cidr_block}"
    availability_zone = "${var.secondary_az}"
    tags {
        Name = "${var.name_tag}-secondary-public"
        Description = "${var.description_tag}"
        Project = "${var.name_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table" "secondary_public" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
    }
    tags {
        Name = "${var.name_tag}-secondary-public"
        Description = "${var.description_tag}"
        Project = "${var.name_tag}"
        Environment = "${var.environment_tag}"
    }
}

resource "aws_route_table_association" "secondary_public" {
    subnet_id = "${aws_subnet.secondary_public.id}"
    route_table_id = "${aws_route_table.secondary_public.id}"
}

resource "aws_nat_gateway" "secondary_nat_gateway" {
    allocation_id = "${var.secondary_nat_gateway_eip}"
    subnet_id = "${aws_subnet.secondary_public.id}"
    depends_on = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "${var.name_tag}"
        Description = "${var.description_tag}"
        Project = "${var.name_tag}"
        Environment = "${var.environment_tag}"
    }
}
