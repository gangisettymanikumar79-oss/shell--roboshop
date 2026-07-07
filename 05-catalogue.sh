#!/bin/bash
LoGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LoGS_FOLDER
sudo chown -R ec2-user:ec2-user $LoGS_FOLDER
sudo chmod -R 755 $LoGS_FOLDER
LoGS_FILE="$LoGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD

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
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
validate $? "install nodejs:20"
id roboshop
if [ $? -ne 0 ];then
 
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
       validate $? "createing roboshop system user"
else
    echo "system user roboshop alredy create......$B Skipping $N"
fi
rm -rf /app
validate $? "Removing existing code"
rm -rf /tmp/catalogue.zip
validate $? "Removed catalogue zip"
mkdir -p  /app 
validate $? "createing app directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 
unzip /tmp/catalogue.zip

npm install 
validate $? "Installing dependencies " 

cp $SCRIPT_DIR/catalogue-service /etc/systemd/system/catalogue-service
validate $? "Created systemctl service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo.repo"

dnf install mongodb-mongosh -y
validate $? "Installed MongoDB client "




