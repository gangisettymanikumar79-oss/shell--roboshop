
#!/bin/bash
LOGS_FILE="/var/log/roboshop"
sudo mkdir -p $LOGS_FILE
sudo chown -R ec2-user:ec2-user $LOGS_FILE
sudo chmod -R 755 $LOGS_FILE
LOGS_FILE="$LOGS_FILE/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.manikumar.online

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

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y
VALIDATE $? "installing nginx:24"

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Removed Default conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied roboshop nginx conf"


systemctl enable nginx
systemctl restart nginx 
VALIDATE $? "Enable and restarted nginx"

