#!/bin/bash

# Function to correct code
correct_code() {
    local file_path="$1"
    local search_pattern="$2"
    local message="$3"

    # Perform the substitution
    sed -i "$search_pattern" "$file_path"
    if [ $? -eq 0 ]; then
        echo "Code substitution successful in $file_path."
        if [ -n "$message" ]; then
            echo "$message"
        else
            echo "Edit successful in $file_path with pattern: $search_pattern"
        fi
    else
        echo "Code substitution failed in $file_path."
    fi
}

# Function to replace the entire file with an updated one
replace_code_file() {
    local outdated_file="$1"
    local new_file="$2"
    
    # Check if both files exist
    if [ -f "$new_file" ]; then
        if [ -f "$outdated_file" ]; then
            # Backup the old file
            cp "$outdated_file" "${outdated_file}.bak"
            echo "Backup created for $outdated_file as ${outdated_file}.bak"

            # Replace the outdated file with the new one
            cp "$new_file" "$outdated_file"
            if [ $? -eq 0 ]; then
                echo "Successfully replaced $outdated_file with $new_file."
            else
                echo "Failed to replace $outdated_file."
            fi
        else
            echo "Outdated file $outdated_file not found!"
        fi
    else
        echo "New file $new_file not found!"
    fi
}

# Paths to the configuration files
ENVTEST_PATH=/tmp/ramdisk/VAP-Concierge/src/envTest.sh
RUN_ZHARFANF_PATH=/tmp/ramdisk/VAP-Concierge/src/run_zharfanf.sh
DEFAULT_CLIENT_IP="10.140.83.30"

# Check if an IP is passed as an argument, otherwise prompt for user input
if [ -n "$1" ]; then
    CLIENT_IP="$1"
    echo "Using IP address passed as argument: $CLIENT_IP"
else
    read -p "Enter the IP address to use (or press Enter to use the default [$DEFAULT_CLIENT_IP]): " USER_INPUT_IP
    CLIENT_IP=${USER_INPUT_IP:-$DEFAULT_CLIENT_IP}
    echo "Using IP address: $CLIENT_IP"
fi

# Search for the first eligible IP address in the envTest.sh file and store it in ORIGINAL_IP
ORIGINAL_IP=$(grep -oP '(?<=http://)\d{1,3}(\.\d{1,3}){3}(?=:6000/)' $ENVTEST_PATH | head -n 1)
if [ -z "$ORIGINAL_IP" ]; then
    echo "No IP address found in envTest.sh matching the pattern 'http://<IP>:6000/'. Exiting."
    exit 1
fi
echo "Original IP found: $ORIGINAL_IP"

# Replace the original IP with the new CLIENT_IP in envTest.sh and run_zharfanf.sh
correct_code "$ENVTEST_PATH" "s|$ORIGINAL_IP|$CLIENT_IP|g" "Update the IP address in envTest.sh from $ORIGINAL_IP to $CLIENT_IP"
correct_code "$RUN_ZHARFANF_PATH" "s|$ORIGINAL_IP|$CLIENT_IP|g" "Update the IP address in run_zharfanf.sh from $ORIGINAL_IP to $CLIENT_IP"
