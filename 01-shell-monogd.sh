#!/bin/bash
LoGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LoGS_FOLDER
sudo chown -R ec2-user:ec2-user $LoGS_FOLDER
sudo chmod -R 755 $LoGS_FOLDER
LoGS_FILE="$LoGS_FOLDER/$0.log"

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
cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo.repo"
dnf install mongodb-org -y 
validate $? "Installing MongoDB"
systemctl enable --now mongod
validate $? "Starting and enabling MongoDB"
sed -i s/127.0.0.1/0.0.0.0/g /etc/mongod.conf
validate $? "Allowing remote connections to MongoDB"
systemctl restart --now mongod
validate $? " Restarting MongoDB"














