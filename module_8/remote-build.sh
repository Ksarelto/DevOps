# !/usr/bin/env bash

HOST_NAME=$1
SSH_USER_NAME=$2
SERVER_HOST_DIR=$(pwd)/backend
CLIENT_HOST_DIR=$(pwd)/frontend
USER_PASSWORD=


SERVER_REMOTE_DIR=/var/app/server
CLIENT_REMOTE_DIR=/var/www/frontend

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
check_remote_dir_exists $CLIENT_REMOTE_DIR

echo "---> Building and copying server files - START <---"
echo $SERVER_HOST_DIR
cd $SERVER_HOST_DIR && npm ci && npm run build
scp -Cr dist/ package.json $HOST_NAME:$SERVER_REMOTE_DIR
echo "---> Building and transfering server - COMPLETE <---"

echo "---> Building and transfering client files, cert and ngingx config - START <---"
echo $CLIENT_HOST_DIR
cd $CLIENT_HOST_DIR && npm ci &&  npm run build && cd ../
scp -Cr $CLIENT_HOST_DIR/dist/* $CLIENT_HOST_DIR/frontend_shop.conf $HOST_NAME:$CLIENT_REMOTE_DIR
echo "---> Building and transfering - COMPLETE <---"

echo "---> Starting server<---"
ssh -t $HOST_NAME "cd $SERVER_REMOTE_DIR && npm i && npm run start:pm2 -f"

echo "---> Starting frontend<---"
ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S bash -c 'cd $CLIENT_REMOTE_DIR && cp ./frontend_shop.conf /etc/nginx/conf.d'"

ssh -t $HOST_NAME "echo $USER_PASSWORD | sudo -S systemctl restart nginx"
