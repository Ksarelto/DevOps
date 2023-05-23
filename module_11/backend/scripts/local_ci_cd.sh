#!/usr/bin/env bash

HOST_NAME=
REMOTE_USER_NAME=

read -ep "Enter remote user name:" -s REMOTE_USER_NAME
read -ep "Enter a remote host name (alias):" -s HOST_NAME

./scripts/quality-check.sh
ls
./remote-build.sh $HOST_NAME $REMOTE_USER_NAME