variable "bastion_subnet" {}
variable "bastion_security_group" {}
variable "bastion_tag_name" {}-bastion
variable "bastion_tag_description" {}
variable "bastion_tag_project" {}
variable "bastion_tag_environment" {}
variable "bastion_ami" {
    description = "AWS AMI to use when launching bastion instances in our chosen regions."
    default = {
        eu-west-1 = "ami-bff32ccc"
        us-east-1 = "ami-60b6c60a"
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
