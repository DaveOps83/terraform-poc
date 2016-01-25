variable "aws_target_env" {
  description = "Target AWS environment abbreviation in LOWERCASE - [dev/qa/uat/prod]"
}

variable "aws_access_key" {
  description = "AWS API access key for the target environment. Value sourced from the TF_VAR_aws_access_key environment variable."
}

variable "aws_secret_key" {
  description = "AWS API secret key for the target environment. Value sourced from the TF_VAR_aws_secret_key environment variable."
}

variable "region" {
    description = "AWS region in which to launch stack."
    default = {
        dev = "eu-west-1"
        qa = "eu-west-1"
        uat = "us-east-1"
        prod = "us-east-1"
    }
