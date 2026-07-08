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

Action=$1
shift

if [ "$Action" != "create" ] && [ "$Action" != "delete" ]; then
  echo -e "$RED ERROR :: first argument must be either create or delete $NC"
  echo -e "Usage: $0 [create/delete] [instance1] [instance2.........]"
  exit 1
fi
get_instance(){
  name=$1
  aws ec2 describe-instances --filters "Name=tag:Name,Values=YourInstanceName" "Name=instance-state-name,Values=Shell-manikumar"     --query "Reservations[0].Instances[0].InstanceId" --output table

}

for instance in $@
do 


done 

   
