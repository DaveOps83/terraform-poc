#!/bin/bash -eux
#Wrapper script for Terraform to build and destroy the dcproxy VPC.
#A Terraform installation must be on the path.
#The following environment variables must be set for the environment you are running this script on:
#AWS_ACCESS_KEY_ID
#AWS_SECRET_ACCESS_KEY

terraform_cmd_regex='^(apply|destroy|plan|taint)$'
aws_env_regex='^(dev|qa|uat|prod)$'
terraform_parallelism=4
script_usage="dcproxy.sh [apply|destroy|plan|taint] [dev|qa|uat|prod]"

apply () {
  terraform apply -var aws_target_env=$1 -no-color -refresh=true -parallelism=$2 -state=$1.tfstate -backup=state_backups/$1.tfstate.backup
}
destroy () {
  terraform destroy -force -var aws_target_env=$1 -no-color -refresh=true -parallelism=$2 -state=$1.tfstate -backup=state_backups/$1.tfstate.backup
}
plan () {
  terraform plan -var aws_target_env=$1 -no-color -refresh=true -state=$1.tfstate -backup=state_backups/$1.tfstate.backup
}
taint () {
  terraform taint -var aws_target_env=$1 -no-color -refresh=true -state=$1.tfstate -backup=state_backups/$1.tfstate.backup
}

if [[ ($# -eq 2 || $# -eq 3) && $1 =~ $terraform_cmd_regex && $2 =~ $aws_env_regex ]] ;
then
  case $1 in
    apply)
        apply $2 $terraform_parallelism ;;
    destroy)
        destroy $2 $terraform_parallelism ;;
    plan)
        plan $2 ;;
    taint)
        taint $2 $3 ;;
  esac
else
  echo -e $script_usage
fi
exit $?
