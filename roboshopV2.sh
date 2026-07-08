#!/bin/bash
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z01307831C5314SVI2OCC"
DOMAIN_NAME="manikumar.online"

RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
NC='\e[0m' # No Color (Reset)


######## validate ###########
if [ $# -lt 2 ]; then
  echo -e "$RED ERROR :: At least 2 arguments required $NC"
  echo -e "Usage: $0 [create/destroy] [instance1] [instance2.....]"
  exit 1
fi

ACTION=$1
shift

if [ "$ACTION" != "create" ] && [ "$ACTION" != "delete" ]; then
  echo -e "$RED ERROR :: first argument must be either create or delete $NC"
  echo -e "Usage: $0 [create/delete] [instance1] [instance2.........]"
  exit 1
fi
get_instance(){
  name=$1
  aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=roboshop-$name" \
            "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text


}

for instance in "$@"
do 
INSTANCE_ID=$(get_instance "$instance")
  if [ "$ACTION" == "create" ]; then
    if [ "$INSTANCE_ID" == "None" ]; then
      echo "Launching instance: roboshop-instance"
        INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-groups "roboshop-commongroup" "roboshop-$instance" \
	      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
	      --query 'Instances[0].InstanceId' \
        --output text)
        echo "launching instance :$INSTANCE_ID"
      else
      echo "roboshop-$instance already running: $INSTANCE_ID"
  fi
fi


done 


   
