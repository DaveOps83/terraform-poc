variable "env_name" {
  default = "uat"
  description = "Lowercase subdomain for environment which is used in DNS records - dev,qa,uat or prod."
}

variable "hosted_zone_id" {
    default = "***REMOVED***"
    description = "Hosted zone ID for DNS record creation."
}

variable "dc_public_ip" {
    default = "***REMOVED***"
    description = "Public IP of the TTC data centre endpoint."
}

variable "stack_name" {
  description = "Name to be used for all resources within stack."
  default = "dcproxy"
}

variable "stack_description" {
  description = "Description to be used for all resources within stack."
  default = "Do not delete or modify"
}

variable "aws_region" {
    description = "AWS region to launch servers."
    default = "us-east-1"
}

variable "az_1" {
    description = "First availability zone."
    default = "us-east-1a"
}

variable "az_2" {
    description = "Second availability zone."
    default = "us-east-1b"
}

variable "aws_ami" {
    default = "ami-60b6c60a"
    description = "AMI for bastion and dcproxy instances."
}

variable "aws_instance_type" {
    default = "t2.nano"
    description = "Bastion and dcproxy nodes instance size."
}

variable "aws_nat_gateway_eip_1" {
    default = "eipalloc-0a0f826e"
    description = "Elastic IP for NAT gateway 1."
}

variable "aws_nat_gateway_eip_2" {
    default = "eipalloc-210c8145"
    description = "Elastic IP for NAT gateway 2."
}

variable "dcproxy_key_pair" {
  default = "dcproxy-nodes-uat"
  description = "Name of the dcproxy nodes SSH key pair."
}

variable "private_keys_path" {
  default = "../../../ssh"
  description = "Path to the directory containing the private portions of the dcproxy and bastion nodes SSH key pairs."
}

variable "dcproxy_user_data" {
    default = "user_data/dcproxy-nodes"
    description = "User_data script for dcproxy nodes."
}

variable "bastion_user_data" {
    default = "user_data/bastion-node"
    description = "User_data script for the bastion node."
}

variable "bastion_key_pair" {
  default = "dcproxy-bastion-uat"
  description = "Name of the bastion node SSH key pair."
}

variable "bastion_dcproxy_private_key_destination" {
  default = "/home/ec2-user"
  description = "The target upload directory for the dcproxy SSH private key on the bastion node."
}
