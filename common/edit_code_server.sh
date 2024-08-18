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

# Update the IP address in envTest.sh and run_zharfanf.sh
ENVTEST_PATH=/tmp/ramdisk/VAP-Concierge/src/envTest.sh
RUN_ZHARFANF_PATH=/tmp/ramdisk/VAP-Concierge/src/run_zharfanf.sh
DEFAULT_CLIENT_IP="10.140.83.30"
read -p "Enter the IP address to use (or press Enter to use the default [$DEFAULT_CLIENT_IP]): " USER_INPUT_IP
CLIENT_IP=${USER_INPUT_IP:-$DEFAULT_CLIENT_IP}
echo "Using IP address: $CLIENT_IP"
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


