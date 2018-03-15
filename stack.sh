#!/bin/bash

#### Stack Script will setup DB + APP + WEB on the server where it runs

### DB
DB_F() {
    echo "DB Installation"
}
### APP
APP_F() {
    echo "APP Installation"
}
### WEB
WEB_F() {
    echo "WEB Installation"
}

### Main program
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

