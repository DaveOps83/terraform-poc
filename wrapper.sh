#!/bin/bash -eux
#Wrapper script for to build and destroy Terraform controlled VPCs.
script_usage="wrapper.sh [apply|destroy|plan|taint] [project folder] [dev|qa|uat|prod] [resource to taint (optional)]"
aws_env_regex='^(dev|qa|uat|prod)$'
terraform_cmd_regex='^(apply|destroy|plan|taint)$'
terraform_state_dir=states
terraform_state_backup_dir=state_backups
terraform_log_dir=logs
terraform_log_level=ERROR
terraform_parallelism=4

apply () {
  terraform apply -var aws_target_env=$2 -no-color -refresh=true -parallelism=$3 -state=./$1/$terraform_state_dir/$2.tfstate -backup=./$1/$terraform_state_backup_dir/$2.tfstate.backup ./$1
}
destroy () {
  terraform destroy -force -var aws_target_env=$2 -no-color -refresh=true -parallelism=$3 -state=./$1/$terraform_state_dir/$2.tfstate -backup=./$1/$terraform_state_backup_dir/$2.tfstate.backup ./$1
}
plan () {
  terraform plan -var aws_target_env=$2 -no-color -refresh=true -state=./$1/$terraform_state_dir/$2.tfstate -backup=./$1/$terraform_state_backup_dir/$2.tfstate.backup ./$1
}
taint () {
  terraform taint -state=./$1/$terraform_state_dir/$2.tfstate -backup=./$1/$terraform_state_backup_dir/$2.tfstate.backup $3
}

if [[ $# -eq 3 || $# -eq 4 && $1 =~ $terraform_cmd_regex && -d $(pwd)/$2 && $3 =~ $aws_env_regex ]] ;
then
  for i in $terraform_state_dir $terraform_state_backup_dir $terraform_log_dir ;
  do
    if [[ ! -d $2/$i ]] ;
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
    esac
else
  echo -e $script_usage
fi
exit $?
