#!/bin/bash

echo "Setting up client environment..."
set -e  # Exit immediately if a command exits with a non-zero status
trap 'echo "Error occurred at line $LINENO while setting up client environment." >&2' ERR

test_mode=false

# Parse command-line options
while getopts "t" opt; do
  case $opt in
    t)
      test_mode=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GitHub Username> <GitHub Token>"
    exit 1
fi

# Get the GitHub username and token from arguments
GITHUB_USERNAME="$1"
GITHUB_TOKEN="$2"

# Validate arguments
if [[ -z "$GITHUB_USERNAME" || -z "$GITHUB_TOKEN" ]]; then
    echo "Error: GitHub Username and Token must be provided."
    exit 1
fi

# Source the common script
THIS_CODE_DIR=$(dirname "$0")
if [[ -f "$THIS_CODE_DIR/build_common.sh" ]]; then
    source "$THIS_CODE_DIR/build_common.sh"
else
    echo "Error: build_common.sh not found in $THIS_CODE_DIR" >&2
    exit 1
fi

# Run common functions with a spinner
install_tools
install_miniconda
download_concierge_model
setup_dds
setup_vap_concierge

# Download and extract datasets for the client environment
COMMON_DIR="$HOME/common_file"
mkdir -p "$COMMON_DIR"
pushd "$COMMON_DIR" > /dev/null
if [ ! -f "data-set-awstream.tar.gz" ]; then
    echo "Downloading data-set-awstream.tar.gz..."
    if gdown --id 14wNMgmQhrVzXlhLKbKvocXrJRXEM9SID; then
        echo "Downloaded data-set-awstream.tar.gz with the first ID."
    else
        echo "Failed to download with the first ID. Trying with the new ID..."
        if gdown --id 11KiKKLLuMyJLTu1jsVOfkPIa0EV0QhyN; then
            echo "Downloaded data-set-awstream.tar.gz with the new ID."
        else
            echo "Failed to download with both IDs."
            exit 1
        fi
    fi
else
    echo "data-set-awstream.tar.gz exists."
fi

# Extract and move the dataset
run_with_spinner "tar xvzf data-set-awstream.tar.gz"
new_item_awstream=$(tar tf data-set-awstream.tar.gz | head -n 1 | cut -d '/' -f 1)
rm -rf "$HOME/VAP-Concierge/src/app/awstream-adaptive/$new_item_awstream"
mv "$new_item_awstream" "$HOME/VAP-Concierge/src/app/awstream-adaptive/"
if $test_mode; then
    rm -rf data-set-awstream.tar.gz
fi
popd > /dev/null

# Run additional client-specific tasks
setup_ramdisk
update_firewall_rules

# Update paths and conda environment
if setup_path_and_conda; then
    echo "success" > /home/cc/Concierge-VAP/common/build_client_success.txt
else
    echo "Error: Path and Conda setup failed." >&2
    exit 1
fi

echo "Client environment setup completed successfully."
