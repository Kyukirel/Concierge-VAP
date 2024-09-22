#!/bin/bash

echo "Setting up client environment..."
set -e  # Exit immediately if a command exits with a non-zero status

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GitHub Username> <GitHub Token>"
    exit 1
fi

# Get the GitHub username and token from arguments
GITHUB_USERNAME="$1"
GITHUB_TOKEN="$2"

# Source the common script
THIS_CODE_DIR=$(dirname "$0")
source "$THIS_CODE_DIR/build_common.sh"

# Run common functions
install_tools
install_miniconda
setup_dds

# Download and extract datasets for the client environment
COMMON_DIR="$HOME/common_file"
mkdir -p "$COMMON_DIR"
pushd "$COMMON_DIR" > /dev/null
if [ ! -f "data-set-awstream.tar.gz" ]; then
    echo "Downloading data-set-awstream.tar.gz..."
    gdown --id 14wNMgmQhrVzXlhLKbKvocXrJRXEM9SID || gdown --id 11KiKKLLuMyJLTu1jsVOfkPIa0EV0QhyN
fi

run_with_spinner "tar xvzf data-set-awstream.tar.gz"
new_item_awstream=$(tar tf data-set-awstream.tar.gz | head -n 1 | cut -d '/' -f 1)
rm -rf "$HOME/VAP-Concierge/src/app/awstream-adaptive/$new_item_awstream"
mv "$new_item_awstream" "$HOME/VAP-Concierge/src/app/awstream-adaptive/"
popd > /dev/null

# Run additional client-specific tasks
setup_ramdisk
update_firewall_rules
setup_path_and_conda && echo "success" > /home/cc/Concierge-VAP/common/build_client_success.txt
