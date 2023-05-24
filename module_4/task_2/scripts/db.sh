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

restore_db() {
  local latest_backup
  local parsed_time
  local time_in_seconds_backup

  for line in $(ls ../data)
  do
    parsed_time=$(echo $line | cut -s -d'%' -f 2 | sed "s/_/ /g")

    if [[ -z $parsed_time ]]
    then
      continue
    fi

    if [[ -z $time_in_seconds_backup || -z $latest_backup ]]
    then
      latest_backup=$line
      time_in_seconds_backup=$(date +%s -d "$parsed_time")
      continue
    fi

    if [[ $(date +%s -d "$parsed_time") -gt $time_in_seconds_backup ]]
    then
      latest_backup=$line
      time_in_seconds_backup=$(date +%s -d "$parsed_time")
    fi
  done

  if [[ ! -z $latest_backup ]]
  then
    mv -f "../data/$latest_backup" ../data/users.db
  else
    echo -e "${RED}No backup file found${NC}"
  fi
}

find_user() {
    local username
    local result

    read -p 'Please enter the username that you want to find: ' username
    
    IFS=$'\n'

    for line in $(cat ../data/users.db)
    do
      if [[ $( echo $line | sed 's/_/  /g') =~ $username ]]
      then 
        result+="Username: $(echo $line | cut -d '_' -f 2) Role: $(echo $line | cut -d '_' -f 4)\n"
      fi
    done

    if [[ -z $result ]]
    then
      echo -en "${RED}\nUser not found\n${NC}"
    else
      echo -en "${BLUE}\n$result${NC}"
    fi
}

get_users_list() {
    local result=$(cat ../data/users.db | sed 's/_//g' | nl)
    if [[ $1 == '--inverse' ]]
    then
     result=$(printf "${BLUE}$result${NC}" | sort -r)
    fi

    printf "${BLUE}$result${NC}"
}

run_command() {
  case $first_argument in
  add) add_user ;;
  restore) restore_db ;;
  backup) backup_db ;;
  find) find_user ;;
  list) get_users_list $second_argument ;;
  *) help ;;
  esac
}

check_database_existance() {
  if [[ ! -e ../data/users.db && ! -z $first_argument && $first_argument != 'help' ]]
  then
    read -p "The users.db file is not exist. If you want to continue you should agree to create it. Do you agree? Y/N: " -ei "Y"
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      touch ../data/users.db
      run_command
    else
      echo -e "\nSorry, can't continue without db file"
    fi
  else
    run_command 
  fi
}

check_database_existance