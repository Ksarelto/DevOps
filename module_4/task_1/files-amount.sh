# !/usr/bin/env bash
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

for path in $@
do
  amount=$(find $path -type f | wc -l)
  echo -e "In ${RED}$path${NC} directory there are ${BLUE}$amount${NC} files"
done

