#Parameter variables
variable "aws_target_env" {
  description = "Target AWS environment abbreviation in LOWERCASE - [dev/qa/uat/prod]"
}

variable "aws_access_key" {
  description = "AWS API access key for the target environment. Value sourced from the TF_VAR_aws_access_key environment variable."
}

variable "aws_secret_key" {
  description = "AWS API secret key for the target environment. Value sourced from the TF_VAR_aws_secret_key environment variable."
}

#Generic variables
variable "stack_name" {
  description = "Name tag value to be used for all resources within the stack."
  default = "dcproxy"
}

variable "stack_description" {
  description = "Description tag value to be used for all resources within the stack."
  default = "Datacentre proxy resource - do not delete or modify"
}

variable "region" {
    description = "AWS region in which to launch stack."
    default = {
        dev = "eu-west-1"
        qa = "eu-west-1"
        uat = "us-east-1"
        prod = "us-east-1"
    }
}

#Networking variables
variable "primary_az" {
    description = "Primary AWS availability zone in which to launch stack."
    default = {
        dev = "eu-west-1a"
        qa = "eu-west-1a"
        uat = "us-east-1a"
        prod = "us-east-1b"
    }
}

variable "secondary_az" {
    description = "Secondary AWS availability zone in which to launch stack."
    default = {
        dev = "eu-west-1b"
        qa = "eu-west-1b"
        uat = "us-east-1b"
        prod = "us-east-1c"
    }
}

#Bastion instance variables
variable "bastion_ami" {
    description = "AWS AMI to use when launching bastion instances in our chosen regions."
    default = {
        eu-west-1 = "ami-bff32ccc"
        us-east-1 = "ami-60b6c60a"
    }
}

variable "bastion_key_pair" {
  description = "AWS key pair to use when launching the bastion instance."
  default = {
      dev = "dcproxy-bastion-dev"
      qa = "dcproxy-bastion-qa"
      uat = "dcproxy-bastion-uat"
      prod = "dcproxy-bastion-prod"
  }
}

#TROPICS instance variables
variable "tropics_ami" {
    description = "AWS AMI to use when launching TROPICS instances in our chosen regions."
    default = {
        eu-west-1 = "ami-bff32ccc"
        us-east-1 = "ami-60b6c60a"
    }
}

variable "tropics_instance_type" {
    description = "AWS instance type to use when launching TROPICS instances."
    default = {
        dev = "t2.nano"
        qa = "t2.nano"
        uat = "t2.nano"
        prod = "t2.nano"
    }
}

variable "tropics_key_pair" {
    description = "AWS key pair to use when launching TROPICS instances."
    default = {
        dev = "dcproxy-nodes-dev"
        qa = "dcproxy-nodes-qa"
        uat = "dcproxy-nodes-uat"
        prod = "dcproxy-nodes-prod"
    }
}

#DAS instance variables
variable "das_ami" {
    description = "AWS AMI to use when launching DAS instances in our chosen regions."
    default = {
        eu-west-1 = "ami-bff32ccc"
        us-east-1 = "ami-60b6c60a"
    }
}

variable "das_instance_type" {
    description = "AWS instance type to use when launching DAS instances."
    default = {
        dev = "t2.nano"
        qa = "t2.nano"
        uat = "t2.nano"
        prod = "t2.nano"
    }
}

variable "das_key_pair" {
    description = "AWS key pair to use when launching DAS instances."
    default = {
        dev = "dcproxy-nodes-dev"
        qa = "dcproxy-nodes-qa"
        uat = "dcproxy-nodes-uat"
        prod = "dcproxy-nodes-prod"
    }
}

#LDAPS instance variables
variable "ldaps_ami" {
    description = "AWS AMI to use when launching LDAPS instances in our chosen regions."
    default = {
        eu-west-1 = "ami-bff32ccc"
        us-east-1 = "ami-60b6c60a"
    }
}

variable "ldaps_instance_type" {
    description = "AWS instance type to use when launching LDAPS instances."
    default = {
        dev = "t2.nano"
        qa = "t2.nano"
        uat = "t2.nano"
        prod = "t2.nano"
    }
}

variable "ldaps_key_pair" {
    description = "AWS key pair to use when launching LDAPS instances."
    default = {
        dev = "dcproxy-nodes-dev"
        qa = "dcproxy-nodes-qa"
        uat = "dcproxy-nodes-uat"
        prod = "dcproxy-nodes-prod"
    }
}

#NAT gateway variables
variable "primary_nat_gateway_eip" {
    description = "AWS elastic IP allocation ID for the primary NAT gateway."
    default = {
        dev = "eipalloc-68c90b0d"
        qa = "eipalloc-496db62c"
        uat = "eipalloc-0a0f826e"
        prod = "eipalloc-6136a605"
    }
}

variable "secondary_nat_gateway_eip" {
    description = "AWS elastic IP allocation ID for the secondary NAT gateway."
    default = {
        dev = ""
        qa = ""
        uat = ""
        prod = "eipalloc-f32cb397"
    }
}

#Common DNS variables
variable "hosted_zone_id" {
    description = "AWS hosted zone ID for DNS record creation."
    default = {
        dev = "***REMOVED***"
        qa = "***REMOVED***"
        uat = "***REMOVED***"
        prod = "***REMOVED***"
    }
}

#TTC datacentre variables
variable "dc_ingress_ip" {
    description = "Public IP of the TTC data centre service integration point."
    default = {
        dev = "***REMOVED***"
        qa = "***REMOVED***"
        uat = "***REMOVED***"
        prod = "***REMOVED***"
    }
}

variable "dc_egress_range" {
    description = "Public outbound IP range of the TTC data centre for bastion connectivity."
    default = "***REMOVED***"
}

variable "dc_ldaps_url" {
    description = "Public inbound IP of the TTC data centre endpoint."
    default = "***REMOVED***"
}
