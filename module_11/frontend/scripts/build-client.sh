#!/usr/bin/env bash

RED='\033[0;31m'
NC='\033[0m'

export ENV_CONFIGURATION=$1
path_to_zip_file="./dist/client-app.zip"

if [[ $ENV_CONFIGURATION != production && -n $1 ]]
then
  echo -e "\n${RED}Incorrect build mode${NC}"
  exit 1
fi

npm ci

if [[ -f $path_to_zip_file ]]
then
  rm $path_to_zip_file
fi
 
npm run  build -- --configuration $ENV_CONFIGURATION

./scripts/files-amount.sh ./dist
echo

for file in $( ls ./dist )
do
  zip $path_to_zip_file ./dist/$file
done