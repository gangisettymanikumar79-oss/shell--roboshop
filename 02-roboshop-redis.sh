#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.LOG"

USERID=$(id -u)

RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
NC='\e[0m' # No Color (Reset)
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

if [ $USERID -ne 0 ]; then
 echo "$timestamp [ERROR] $G please run this script with root access $N" | tee -a $LOGS_FILE
        exit 1
fi
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$timestamp [ERROR] $2..............$B FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$timestamp [INFO] $2..............$B SUCCESS  $N"  | tee -a $LOGS_FILE
    fi
}
dnf module disable redis -y
dnf module enable redis:7 -y
dnf install redis -y 
validate $? "installing redis :7"
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/c protected-mode no' /etc/redis/redis.conf    
validate $? "Allowing remote connections"
systemctl enable redis 
systemctl start redis 
validate $? "starting redius"






