variable "aws_target_env" {
  description = "Target AWS environment abbreviation in LOWERCASE - [dev/qa/uat/prod]"
}

variable "aws_access_key" {
  description = "AWS API access key for the target environment. Value sourced from the TF_VAR_aws_access_key environment variable."
}

variable "aws_secret_key" {
  description = "AWS API secret key for the target environment. Value sourced from the TF_VAR_aws_secret_key environment variable."
}

variable "aws_stack_name" {
  description = "Name tag value to be used for all resources within the stack."
  default = "dcproxy"
}

variable "aws_stack_description" {
  description = "Description tag value to be used for all resources within the stack."
  default = "Do not delete or modify"
}

variable "aws_region" {
    description = "AWS region in which to launch stack."
    default = {
        dev = "eu-west-1"
        qa = "eu-west-1"
        uat = "us-east-1"
        prod = "us-east-1"
    }
}

variable "aws_az" {
    description = "AWS availability zone in which to launch stack."
    default = {
        dev = "eu-west-1a"
        qa = "eu-west-1a"
        uat = "us-east-1a"
        prod = "us-east-1b"
    }
}

variable "aws_ami" {
    description = "AWS AMI to use when launching instances in our chosen regions."
    default = {
        eu-west-1 = "ami-bff32ccc"
        us-east-1 = "ami-60b6c60a"
    }
}

variable "dcproxy_instance_type" {
    description = "AWS instance type to to use when launching dcproxy instances."
    default = {
        dev = "t2.micro"
        qa = "t2.micro"
        uat = "t2.micro"
        prod = "t2.micro"
    }
}

variable "dcproxy_key_pair" {
    description = "AWS key pair to use when launching dcproxy instances."
    default = {
        dev = "dcproxy-nodes-dev"
        qa = "dcproxy-nodes-qa"
        uat = "dcproxy-nodes-uat"
        prod = "dcproxy-nodes-prod"
    }
}

variable "dcproxy_user_data" {
    default = "user_data/dcproxy-nodes"
    description = "AWS user_data script for bootstrapping dcproxy instances."
}

variable "tropics_dns" {
    description = "Internal DNS record name for TROPICS."
    default = {
        dev = "tropics.dev.travcorpservices.com"
        qa = "tropics.qa.travcorpservices.com"
        uat = "tropics.uat.travcorpservices.com"
        prod = "tropics.prod.travcorpservices.com"
    }
}

variable "ldaps_dns" {
    description = "Internal DNS record name for LDAPS."
    default = {
        dev = "ldaps.dev.travcorpservices.com"
        qa = "ldaps.qa.travcorpservices.com"
        uat = "ldaps.uat.travcorpservices.com"
        prod = "ldaps.prod.travcorpservices.com"
    }
}

variable "das_dns" {
    description = "Internal DNS record name for Data Access Services."
    default = {
        dev = "das.dev.travcorpservices.com"
        qa = "das.qa.travcorpservices.com"
        uat = "das.uat.travcorpservices.com"
        prod = "das.prod.travcorpservices.com"
    }
}

variable "bastion_instance_type" {
    description = "AWS instance type to use when launching the bastion instance."
    default = "t2.nano"
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

variable "bastion_user_data" {
    default = "user_data/bastion"
    description = "AWS user_data script for bootstrapping the bastion node."
}

variable "aws_nat_gateway_eip" {
    description = "AWS elastic IP allocation ID for NAT gateway."
    default = {
        dev = "eipalloc-68c90b0d"
        qa = "eipalloc-496db62c"
        uat = "eipalloc-0a0f826e"
        prod = "eipalloc-6136a605"
    }
}

variable "aws_hosted_zone" {
    description = "AWS hosted zone ID for DNS record creation."
    default = {
        dev = "***REMOVED***"
        qa = "***REMOVED***"
        uat = "***REMOVED***"
        prod = "***REMOVED***"
    }
}

variable "dc_ip" {
    description = "Public IP of the TTC data centre endpoint."
    default = {
        dev = "***REMOVED***"
        qa = "***REMOVED***"
        uat = "***REMOVED***"
        prod = "***REMOVED***"
    }
}

variable "dc_dns" {
    description = "Public IP of the TTC data centre endpoint."
    default = {
        dev = "dc.dev.travcorpservices.com"
        qa = "dc.qa.travcorpservices.com"
        uat = "dc.uat.travcorpservices.com"
        prod = "dc.prod.travcorpservices.com"
    }
}

variable "dc_ldaps_url" {
    description = "Public IP of the TTC data centre endpoint."
    default = "***REMOVED***"
}
