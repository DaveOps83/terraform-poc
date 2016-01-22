#!/bin/bash
#Export Terraform environment variables for AWS credentials, called by wrapper.sh
#Fill in your credentials for the appropriate environment you are working on.
#When Terraform can use AWS CLI profiles this script will be removed.
#This repository's index has been updated to ignore changes to this file:
#git update-index --assume-unchanged credentials.sh
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
    export TF_VAR_aws_access_key="***REMOVED***"
    export TF_VAR_aws_secret_key="***REMOVED***"
    ;;
esac
if [[ -z $TF_VAR_aws_access_key || -z $TF_VAR_aws_secret_key ]] ;
then
  echo -e "Please set API credentials for $1 in credentials.sh"
  exit 1
fi
