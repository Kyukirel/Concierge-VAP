#!/bin/bash

echo "---Running test2---"
echo "Current directory: $(pwd)"
pushd "$HOME/Concierge-VAP/common"
echo "Changed directory: $(pwd)"
echo "Can Access: $DIR_BEFORE"
HELLO="Hello, World!"
echo "---Test2 completed---"