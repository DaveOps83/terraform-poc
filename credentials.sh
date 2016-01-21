#!/bin/bash -eux
#Export Terraform environment variables for AWS credentials, called by wrapper.sh
#Fill in your credentials for the appropriate environment you are working on.
#When Terraform can use AWS CLI profiles this script will be removed.
#DO NOT PUSH API KEYS TO GITHUB!!!!
case $1 in
  dev)
    export TF_VAR_aws_access_key=""
    export TF_VAR_aws_secret_key=""
    ;;
  qa)
    export TF_VAR_aws_access_key=""
    export TF_VAR_aws_secret_key=""
    ;;
  uat)
    export TF_VAR_aws_access_key=""
    export TF_VAR_aws_secret_key=""
    ;;
  prod)
    export TF_VAR_aws_access_key=""
    export TF_VAR_aws_secret_key=""
    ;;
esac
