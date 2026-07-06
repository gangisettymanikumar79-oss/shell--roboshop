#!/bin/bash
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z01307831C5314SVI2OCC"
DOMAIN_NAME="manikumar.online"

for instance in "$@"
do
    echo "launching instance: $instance"

    instance_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-groups "roboshop-commongroup" "roboshop-$instance" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    echo "instance ID: $instance_ID"

    if [ "$instance" == "frontend" ]; then
        ip=$(aws ec2 describe-instances \
            --instance-ids "$instance_ID" \
            --query 'Reservations[*].Instances[*].PublicIpAddress' \
            --output text)
        R53_RECORD="$DOMAIN_NAME"
    else
        ip=$(aws ec2 describe-instances \
            --instance-ids "$instance_ID" \
            --query 'Reservations[*].Instances[*].PrivateIpAddress' \
            --output text)
        R53_RECORD="$instance.$DOMAIN_NAME"
    fi

    aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch '
        {
            "Comment": "Update A record to new IP",
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'"$R53_RECORD"'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'"$ip"'"
                            }
                        ]
                    }
                }
            ]
        }
    '
done


