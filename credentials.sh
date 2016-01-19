#!/bin/bash -eux
#Export Terraform environment variables for AWS credentials, called by wrapper.sh
#Fill in your credential for the appropriate environment you are working on.
#This file is in .gitignore to prevent keys being pushed to Github.
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
