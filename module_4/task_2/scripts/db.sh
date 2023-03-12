# !/usr/bin/env bash

first_argument=$1
second_argument=$2
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

add_user() {
    local username
    local role
    local valid=false

    while [[ $valid == "false" ]]
    do
      read -p 'Enter your name: ' username
      read -p 'Enter your role: ' role

      if [[ $username =~ ^[a-zA-Z]*$ && $role =~ ^[a-zA-Z]*$ ]]
      then
        echo "_${username}_ , _${role}_" >> ../data/users.db
        echo -e "${GREEN}Your credentials are saved in users.db file!${NC}"
        valid=true
      else
        echo -e "${RED}\nUsername or role have invalid chars, please use only latin letters!${NC} \n"
      fi
    done;
}

help() {
    echo -e "List of available commands with its description: \n
    ${BLUE}add:${NC} Adds new user to the database \n
    ${BLUE}backup:${NC} Creates a copy of a current db \n
    ${BLUE}restore:${NC} Update the database with the latest copy \n
    ${BLUE}find:${NC} Find user in db \n
    ${BLUE}list:${NC} Prints list of users \n
    ${BLUE}help:${NC} Prints information about available commands"
}

backup_db() {
    local current_date=$(date +'%T_%y-%m-%d')
    cp ../data/users.db "../data/%$current_date%-users.db.backup"
    echo -e "${GREEN}Backup is created!${NC}"
}
