# !/usr/bin/env bash

HOST_NAME=$1
SSH_USER_NAME=$2
USER_PASSWORD=

CONFIGS_HOST_DIR=$(pwd)/frontend/configs
CLIENT_HOST_DIR=$(pwd)/frontend/dist

CLIENT_REMOTE_DIR=/var/www/frontend
CONFIG_REMOTE_DIR=/etc/nginx/conf.d

read -ep "Enter a password to remote user:" -s USER_PASSWORD

check_remote_dir_exists() {
  echo "Check if remote directories exist"

  if ssh $HOST_NAME "[ ! -d $1 ]"; then
    echo "Creating: $1"
	ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S bash -c 'mkdir -p $1 && chmod -R 777 $1'"
  else
    echo "Clearing: $1"
    ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S rm -r $1"
    ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S bash -c 'mkdir -p $1 && chmod -R 777 $1'"
  fi
}

check_remote_dir_exists $CLIENT_REMOTE_DIR

echo "---> Transfering client files, cert and ngingx config - START <---"
echo $CLIENT_HOST_DIR
scp -Cr $CLIENT_HOST_DIR/* $HOST_NAME:$CLIENT_REMOTE_DIR
ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S bash -c 'chmod -R 777 $CONFIG_REMOTE_DIR'"
echo "---> Transfering - COMPLETE <---"

echo "---> Transfering configs - START <---"
echo $CONFIGS_HOST_DIR
ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S bash -c 'chmod -R 777 $CONFIG_REMOTE_DIR'"
scp -Cr $CONFIGS_HOST_DIR/* $HOST_NAME:$CONFIG_REMOTE_DIR
echo "---> Transfering - COMPLETE <---"

echo "---> Buiding and Starting frontend<---"
ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S systemctl restart nginx"
