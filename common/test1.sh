#!/bin/bash

echo "---Running test1---"
DIR_BEFORE=$(pwd)
echo "Current directory: $DIR_BEFORE"

DIR_CODE=$(dirname "$0")
echo "Code directory: $DIR_CODE"
echo "---Test1 completed---"


# echo "---Running test1---"
# DIR_BEFORE=$(pwd)
# echo "Current directory: $DIR_BEFORE"
# cd ~/
# source Concierge-VAP/common/test2.sh
# DIR_AFTER=$(pwd)
# echo "Changed directory: $DIR_AFTER"
# if [ "$DIR_BEFORE" == "$DIR_AFTER" ]; then
#     echo "Directory is not changed."
# else
#     echo "Directory is changed."
# fi
# echo "Can Access: $HELLO"
# echo "---Test1 completed---"