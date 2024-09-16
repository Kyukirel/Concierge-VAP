#!/bin/bash

# Ensure the SSH key has the correct permissions
if [ ! -f ~/.ssh/rafael.pem ]; then
    echo "Error: SSH key ~/.ssh/rafael.pem not found. Please check the file path."
    exit 1
fi

chmod 400 ~/.ssh/rafael.pem

# Get the arguments passed to the script
REMOTE_IP_1=$1
REMOTE_IP_2=$2

# Check if the first argument is provided
if [ -z "$REMOTE_IP_1" ]; then
    read -p "Please provide the first IP address: " REMOTE_IP_1
    if [ -z "$REMOTE_IP_1" ]; then
        echo "Error: No IP address provided."
        exit 1
    fi
fi

echo "SSH into the 1st remote server $REMOTE_IP_1"

# SSH into the first remote server and execute the commands
ssh -i ~/.ssh/rafael.pem cc@$REMOTE_IP_1 "
    git clone https://github.com/Kyukirel/Concierge-VAP.git &&
    cd Concierge-VAP/common &&
    chmod +x build_zerotier_other.sh &&
    bash build_zerotier_other.sh
"

# Check if the second argument is provided
if [ -z "$REMOTE_IP_2" ]; then
    read -p "Please provide the second IP address: " REMOTE_IP_2
    if [ -z "$REMOTE_IP_2" ]; then
        echo "Error: No IP address provided."
        exit 1
    fi
fi

echo "SSH into the 2nd remote server $REMOTE_IP_2"

# SSH into the second remote server and execute the commands
ssh -i ~/.ssh/rafael.pem cc@$REMOTE_IP_2 "
    git clone https://github.com/Kyukirel/Concierge-VAP.git &&
    cd Concierge-VAP/common &&
    chmod +x build_zerotier_other.sh &&
    bash build_zerotier_other.sh
"