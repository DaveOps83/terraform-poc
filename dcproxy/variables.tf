variable "env_name" {
  default = "uat"
  description = "Lowercase subdomain for enviroment which is used in DNS records - dev,qa,uat or prod."
}

variable "hosted_zone_id" {
    default = "***REMOVED***"
    description = "Hosted zone ID for DNS record creation."
}

variable "dc_public_ip" {
    default = "185.61.209.16"
    description = "Public IP of the data centre endpoint."
}

variable "stack_name" {
  description = "Name to be used for all resources within stack."
  default = "dcproxy"
}

variable "stack_description" {
  description = "Description to be used for all resources within stack."
  default = "Do not delete or modify"
}

variable "key_name_nodes" {
  default = "dcproxy-nodes-uat"
  description = "Name of the SSH keypair to use in AWS."
}

variable "key_path_nodes" {
  default = "../../ssh/dcproxy-nodes-uat.pem"
  description = "Path to the private portion of the SSH key specified."
}

variable "key_name_bastion" {
  default = "dcproxy-bastion-uat"
  description = "Name of the SSH keypair to use in AWS."
}

variable "key_path_bastion" {
  default = "../../ssh/dcproxy-bastion-uat.pem"
  description = "Path to the private portion of the SSH key specified."
}

variable "aws_region" {
    description = "AWS region to launch servers."
    default = "us-east-1"
}

variable "az_1" {
    description = "First availibilty zone."
    default = "us-east-1a"
}

variable "az_2" {
    description = "Second availibilty zone."
    default = "us-east-1b"
}

variable "aws_linux_ami" {
    default = "ami-303b1458"
    description = "Linux AMI for bastion and NAT servers."
}