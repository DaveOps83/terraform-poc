#!/bin/bash
#Wrapper script to build and destroy Terraform controlled VPCs.
script_usage="Usage:  ./wrapper.sh [apply|destroy|plan|taint|output] [project folder] [dev|qa|uat|prod] [resource to taint \ module state to parse for output (optional)] \n
Examples: \n
 ./wrapper.sh plan dcproxy dev \n
 ./wrapper.sh apply dcproxy dev \n
 ./wrapper.sh destroy dcproxy dev \n
 ./wrapper.sh taint dcproxy dev template_cloudinit_config.dcproxy_node_config \n \
 ./wrapper.sh output dcproxy dev vpc"
aws_env_regex='^(dev|qa|uat|prod)$'
terraform_cmd_regex='^(apply|destroy|plan|taint|output)$'
terraform_state_dir=states
terraform_state_backup_dir=state_backups
terraform_log_dir=logs
terraform_log_level=DEBUG
terraform_parallelism=2

apply () {
  terraform get -no-color -update=true ./$1
  terraform apply -var aws_target_env=$2 -no-color -refresh=true -parallelism=$3 -state=./$1/$terraform_state_dir/$2.tfstate -backup=./$1/$terraform_state_backup_dir/$2.tfstate.backup ./$1
}
destroy () {
  terraform get -no-color -update=true ./$1
  terraform destroy -force -var aws_target_env=$2 -no-color -refresh=true -parallelism=$3 -state=./$1/$terraform_state_dir/$2.tfstate -backup=./$1/$terraform_state_backup_dir/$2.tfstate.backup ./$1
}
plan () {
  terraform get -no-color -update=true ./$1
  terraform plan -var aws_target_env=$2 -no-color -refresh=true -state=./$1/$terraform_state_dir/$2.tfstate -backup=./$1/$terraform_state_backup_dir/$2.tfstate.backup ./$1
}
taint () {
  terraform taint -no-color -state=./$1/$terraform_state_dir/$2.tfstate -backup=./$1/$terraform_state_backup_dir/$2.tfstate.backup $3
}
output () {
  if [[ $# -eq 3 ]] ;
  then
    terraform output -no-color -state=./$1/$terraform_state_dir/$2.tfstate -module=$3
  else
    terraform output -no-color -state=./$1/$terraform_state_dir/$2.tfstate
  fi
}

if [[ ($# -eq 3 || ($# -eq 4)) && $1 =~ $terraform_cmd_regex && -d $(pwd)/$2 && $3 =~ $aws_env_regex ]] ;
then
  for i in $terraform_state_dir $terraform_state_backup_dir $terraform_log_dir ;
  do
    if [ ! -d "$2/$i" ] ;
    then
      mkdir $2/$i
    fi
  done
  export TF_LOG=$terraform_log_level
  export TF_LOG_PATH=./$2/$terraform_log_dir/$3.log
  source ./credentials.sh $3
  case $1 in
    apply)
        apply $2 $3 $terraform_parallelism ;;
    destroy)
        destroy $2 $3 $terraform_parallelism ;;
    plan)
        plan $2 $3 ;;
    taint)
        taint $2 $3 $4 ;;
    output)
        output $2 $3 $4 ;;
    esac
else
  echo -e $script_usage
  exit 1
fi
exit $?
