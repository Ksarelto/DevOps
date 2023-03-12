# !/usr/bin/env bash

threshold=$1
space_measure=$2
available_freespace=$(df --output=avail | sed "s/[a-zA-Z]/ /g")
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

declare -i default_threshold=1000000
declare -i result_threshold=${threshold:=$default_threshold}
declare -i freespace_sum
declare -i converted_freespace_value

if [[ -z $space_measure ]]
then
  read -ep "Please enter the threshold measure: K = kilobytes, M = megobytes, G = gigobytes: " -ei "K" space_measure
fi

if [[ $space_measure != "K" && $space_measure != "M" && $space_measure != "G" ]]
then
   space_measure=K
fi

echo
echo -e "Threshold is: ${BLUE}$threshold $space_measure${NC}"
echo -e "Available free space in ${GREEN}KB${NC}"
echo
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
df --output=source,avail | awk 'NR>1 {print$0}'
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo

while read -a value; do
  freespace_sum+=$value
done <<< $available_freespace

if [[ $space_measure == "M" ]]
then
   converted_freespace_value=$(( $freespace_sum / 1024 ))
elif [[ $space_measure == "G" ]]
then 
   converted_freespace_value=$(( $freespace_sum / 1045000 ))
else
   converted_freespace_value=$freespace_sum
fi

if [[ result_threshold -gt converted_freespace_value ]]
then
  echo -e "${RED}Your free space is below threshold!"
else
  echo -e "${CYAN}It's $(( converted_freespace_value - result_threshold ))$space_measure space available before threshold!"
fi