#!/bin/bash -x
set -o pipefail
aws_envs="dev|qa|uat|prod"
aws_env_regex="^(${aws_envs})$"
terraform_cmds="apply|destroy|plan|get|taint|show|output"
terraform_cmd_regex="^(${terraform_cmds})$"

function help () {
  echo "Usage:  ./wrapper.sh \
  [$terraform_cmds] \
  [config folder] \
  [$aws_envs] \
  [optional module or resource for output or taint commands] \
  [optional module resource for taint command]"
  exit 1
}

#Check if all the required arguments have been passed and if their values are correct
if [[ ($# -eq 3 || $# -eq 5) && ! $1 =~ $terraform_cmd_regex || -z ${2+x} || ! -d $(pwd)/$2 || ! $3 =~ $aws_env_regex ]] ; then
  help
fi

#Set script arguments variable names to be more meaningful.
terraform_cmd=$1
terraform_config=$2
terraform_env=$3
terraform_module=${4:-""}
terraform_resource=${5:-""}

#Set up the environment
#Create the .terraform directory if it does not exist
if [[ ! -d .terraform ]] ; then mkdir .terraform; fi
terraform_env_file=".terraform/environment"
terraform_previous_env=$([ -f $terraform_env_file ] && echo "$(<$terraform_env_file)" || echo "unknown")
terraform_parallelism=8
terraform_log_dir="$terraform_config/logs"
#Create the logs directory if it does not exist
if [[ ! -d $terraform_log_dir ]] ; then mkdir $terraform_log_dir; fi
terraform_log_level="ERROR"
export TF_LOG=$terraform_log_level
export TF_LOG_PATH=$terraform_log_dir/$terraform_env.log
terraform_credentials="credentials.sh"
source $terraform_credentials $terraform_env

#Check to see if we changed environments so we can update the remote config source.
if [[ $terraform_previous_env != ${terraform_config}_$terraform_env || ! -f ./.terraform/terraform.tfstate ]]; then
  mv -f .terraform/terraform.tfstate .terraform/terraform.tfstate.$terraform_previous_env > /dev/null 2>&1
  mv -f .terraform/terraform.tfstate.backup .terraform/terraform.tfstate.backup.$terraform_previous_env > /dev/null 2>&1
  terraform remote config \
    -backend=artifactory \
    -backend-config=url=$artifactory_url \
    -backend-config=repo=$artifactory_repo \
    -backend-config=subpath=$terraform_config/$terraform_env \
    -backup=-
  echo ${terraform_config}_$terraform_env > $terraform_env_file
fi

case $terraform_cmd in
  apply)
    terraform apply \
    -var aws_target_env=$terraform_env \
    -no-color \
    -refresh=true \
    -parallelism=$terraform_parallelism \
    $terraform_config
    ;;

  destroy)
    if [[ $terraform_env = "prod" ]] ; then
      echo "YOU ARE ABOUT TO DESTROY A PRODUCTION ENVIRONMENT!"
      terraform destroy \
      -var aws_target_env=$terraform_env \
      -no-color \
      -refresh=true \
      -parallelism=$terraform_parallelism \
      $terraform_config
    else
      terraform destroy \
      -var aws_target_env=$terraform_env \
      -no-color \
      -refresh=true \
      -parallelism=$terraform_parallelism \
      -force \
      $terraform_config
    fi
    ;;

  plan)
    terraform plan \
    -var aws_target_env=$terraform_env \
    -no-color \
    -refresh=true \
    -module-depth=1 \
    $terraform_config
    ;;

    get)
      terraform get \
      $terraform_config
      ;;

  taint)
      if [[ $terraform_module && -z $terraform_resource ]] ; then
        terraform taint \
        -no-color \
        $terraform_module
      elif [[ $terraform_module && $terraform_resource ]] ; then
        terraform taint \
        -no-color \
        -module=$terraform_module \
        $terraform_resource
      else
        help
      fi
      ;;

  output)
    if [[ -z $terraform_module ]] ; then
      terraform output \
      -no-color
    elif [[ $terraform_module ]] ; then
      terraform output \
      -no-color \
      -module=$terraform_module
    else
      help
    fi
    ;;

    show)
      terraform show
      ;;
esac

exit $?
