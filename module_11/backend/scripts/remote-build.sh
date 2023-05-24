# !/usr/bin/env bash

HOST_NAME=$1
SSH_USER_NAME=$2
USER_PASSWORD=

CONFIGS_HOST_DIR=$(pwd)/configs
SERVER_HOST_DIR=$(pwd)/backend

SERVER_REMOTE_DIR=/var/app/server
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

check_remote_dir_exists $SERVER_REMOTE_DIR

echo "---> Building and copying server files - START <---"
echo $SERVER_HOST_DIR
cd $SERVER_HOST_DIR && npm ci && npm run build && cd ../
scp -Cr $SERVER_HOST_DIR/dist/ $SERVER_HOST_DIR/package.json $HOST_NAME:$SERVER_REMOTE_DIR
echo "---> Building and transfering server - COMPLETE <---"

echo "---> Transfering configs - START <---"
echo $CONFIGS_HOST_DIR
ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S bash -c 'chmod -R 777 $CONFIG_REMOTE_DIR'"
scp -Cr $CONFIGS_HOST_DIR/* $HOST_NAME:$CONFIG_REMOTE_DIR
echo "---> Transfering - COMPLETE <---"

echo "---> Starting server<---"
ssh -t $HOST_NAME "cd $SERVER_REMOTE_DIR && npm i && npm run start:pm2 -f"

echo "---> Buiding and Starting frontend<---"
ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S systemctl restart nginx"
