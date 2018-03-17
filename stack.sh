#!/bin/bash

#### Stack Script will setup DB + APP + WEB on the server where it runs

##
LOG=/tmp/log 
rm -f /tmp/log

TOMCAT_URL=https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.29/bin/apache-tomcat-8.5.29.tar.gz
TOMCAT_DIR=/root/$(echo $TOMCAT_URL | awk -F / '{print $NF}' | sed -e 's/.tar.gz//')
JK_URL="http://redrockdigimark.com/apachemirror/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz"
JK_DIR=/root/$(echo $JK_URL | awk -F / '{print $NF}' | sed -e 's/.tar.gz//')

## Color Variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
M="\e[35m"
BC="\e[1;4;36m"
N="\e[0m"

## Color Functions
error() {
    echo -e "${R}${1}${N}"
    echo -e "\n Failed with some issue .. Check the log file $LOG"
    exit 1
}

head() {
    echo -e "\t${BC}${1}${N}"
}

success() {
    echo -e "${G}${1}${N}"
}

skip() {
    echo -e "${M}${1}${N}"
}

Stat() {
    if [ $1 = 0 ]; then 
        success " -> $2"
    elif [ $1 = SKIP ]; then 
        skip " -> $2"
    else 
        error " -> $2"
    fi
}

### DB
DB_F() {
    head "Installing Database - MairaDB"
    yum install mariadb-server -y &>$LOG
    Stat $? "Installing Mariadb"
    systemctl enable mariadb &>$LOG 
    systemctl start mariadb &>$LOG 
    Stat $? "Starting MariaDB"
    echo "create database IF NOT EXISTS studentapp;
use studentapp;
CREATE TABLE IF NOT EXISTS Students(student_id INT NOT NULL AUTO_INCREMENT,
	student_name VARCHAR(100) NOT NULL,
    student_addr VARCHAR(100) NOT NULL,
	student_age VARCHAR(3) NOT NULL,
	student_qual VARCHAR(20) NOT NULL,
	student_percent VARCHAR(10) NOT NULL,
	student_year_passed VARCHAR(10) NOT NULL,
	PRIMARY KEY (student_id)
);
grant all privileges on studentapp.* to 'student'@'%' identified by 'student@1';
flush privileges;" >/tmp/student.sql 
    mysql < /tmp/student.sql &>$LOG 
    Stat $? "Configuring Database"
}

### APP
APP_F() {
    head "Installing Application - Tomcat"
    type java &>/dev/null 
    if [ $? -ne 0 ]; then 
        yum install java -y &>$LOG 
        Stat $? "Installing Java"
    else    
        Stat SKIP "Installing Java -- IGNORE"
    fi 
    cd /root
    if [ -d $TOMCAT_DIR ]; then 
        Stat SKIP "Installing Tomcat -- IGNORE"
    else 
        wget -qO- $TOMCAT_URL | tar -xz &>$LOG 
        Stat $? "Installing Tomcat"
    fi 

    rm -rf $TOMCAT_DIR/webapps/*
    wget https://github.com/cit-ager/APP-STACK/raw/master/student.war -O $TOMCAT_DIR/webapps/student.war &>$LOG 
    Stat $? "Downloading Student APP"
    wget https://github.com/cit-ager/APP-STACK/raw/master/mysql-connector-java-5.1.40.jar -O $TOMCAT_DIR/lib/mysql-connector-java-5.1.40.jar &>$LOG 
    Stat $? "Downloading MariaDB JDBC"
    sed -i -e '/TestDB/ d' -e '$ i <Resource name="jdbc/TestDB" auth="Container" type="javax.sql.DataSource" maxActive="50" maxIdle="30" maxWait="10000" username="student" password="student@1" driverClassName="com.mysql.jdbc.Driver" url="jdbc:mysql://localhost:3306/studentapp"/>'  $TOMCAT_DIR/conf/context.xml

    ps -ef | grep java | grep $TOMCAT_DIR | grep -v grep &>>$LOG
    if [ $? -eq 0 ]; then
        $TOMCAT_DIR/bin/shutdown.sh &>>$LOG
        Stat $? "Stopping Tomcat"
    fi
    sleep 10
    $TOMCAT_DIR/bin/startup.sh &>>$LOG
    Stat $? "Starting Tomcat"
}

### WEB
WEB_F() {
    head "Installing Application - Tomcat"
    yum install httpd httpd-devel gcc &>>$LOG 
    Stat $? "Installing Web Server"
    if [ -d $JK_DIR ]; then 
        Stat SKIP "Installing Mod_JK -- IGNORE"
    else 
        cd /root 
        wget -qO- $JK_URL | tar -xz &>>$LOG 
        Stat $? "Downloading Mod-JK"
        cd $JK_DIR/native 
        ./configure --with-apxs=/usr/bin/apxs &>>$LOG && make &>>$LOG && make install &>>$LOG 
        Stat $? "Installing Mod-JK"
    fi 
    echo 'worker.list=worker1
worker.worker1.type=ajp13
worker.worker1.host=localhost
worker.worker1.port=8009
' > /etc/httpd/conf.d/workers.properties

    echo 'LoadModule    jk_module  modules/mod_jk.so
JkWorkersFile conf.d/workers.properties
JkLogFile     logs/mod_jk.log
JkMount /student* worker1' > /etc/httpd/conf.d/mod_jk.conf 

    systemctl enable httpd &>>$LOG 
    systemctl restart httpd &>>$LOG 
    Stat $? "Starting Web Server"
}

### Main program
# Check ROot User.
if [ $(id -u) -ne 0 ]; then 
    error "You should be a root user to perform this command"
fi

if [ -z "$1" ]; then 
    read -p "Enter the Stack Layer [DB|APP|WEB|`echo -e "\e[1;4;31mALL\e[0m"`] : " option
    if [ -z "$option" ]; then 
        option=ALL 
    fi
else
    option=$1
fi

case $option in 
    DB) DB_F ;;
    APP) APP_F ;;
    WEB) WEB_F ;;
    ALL)
        DB_F
        APP_F 
        WEB_F 
        ;;
    *) echo "You should enter either of one of DB | APP | WEB | ALL"
       exit 1
        ;;
esac

