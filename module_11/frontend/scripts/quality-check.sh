#!/usr/bin/env bash

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

Quality_Tools=("lint" "test" "audit")

for command in ${Quality_Tools[@]}
do
  npm run $command

  if [[ $? -gt 0 ]]
  then
    echo -e "\n${RED}Some erros were founded during running of ${BLUE}$command${RED}  command${NC}"
    exit 0
  fi
done