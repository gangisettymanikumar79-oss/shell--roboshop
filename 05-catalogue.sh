#!/bin/bash
LOGS_FILE="/var/log/roboshop"
sudo mkdir -p $LOGS_FILE
sudo chown -R ec2-user:ec2-user $LOGS_FILE
sudo chmod -R 755 $LOGS_FILE
LOGS_FILE="$LOGS_FILE/$0.log"
SCRIPT_DIR=$PWD

USERID=$(id -u)

RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
NC='\e[0m' # No Color (Reset)
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

if [ $USERID -ne 0 ]; then
 echo "$timestamp [ERROR] $GREEN please run this script with root access $NC" | tee -a $LOGS_FILE
        exit 1
fi
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$timestamp [ERROR] $2..............$BLUE FAILURE $NC" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$timestamp [INFO] $2..............$GREEN SUCCESS  $NC"  | tee -a $LOGS_FILE
    fi
}
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
VALIDATE $? "install nodejs:20"
id roboshop
if [ $? -ne 0 ];then
 
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
       VALIDATE $? "createing roboshop system user"
else
    echo -e "system user roboshop alredy create......$BLUE Skipping $NC"
fi
rm -rf /app
VALIDATE $? "Removing existing code"
rm -rf /tmp/catalogue.zip
VALIDATE $? "Removed catalogue zip"
mkdir -p  /app 
VALIDATE $? "createing app directory"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 
unzip /tmp/catalogue.zip

npm install 
VALIDATE $? "Installing dependencies " 

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo.repo"

dnf install mongodb-mongosh -y
VALIDATE $? "Installed MongoDB client "

INDEX=$(mongosh --host mongodb.manikumar.online --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -lt 0 ]; then

   mongosh --host mongodb.manikumar.online </app/db/master-data.js 
    VALIDATE $? "Load Products"
else
   echo -e "Products already loaded ... $YELLOW SKIPPING $NC"

fi
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "Restarting catalogue"








