#!/bin/bash

echo "Setting up server environment..."
set -e  # Exit immediately if a command exits with a non-zero status
trap 'echo "Error occurred at line $LINENO while setting up server environment." >&2' ERR

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
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GitHub Username> <GitHub Token> <Client IP>"
    exit 1
fi

# Get the GitHub username, token, and client IP from arguments
GITHUB_USERNAME="$1"
GITHUB_TOKEN="$2"
CLIENT_IP="$3"

# Validate arguments
if [[ -z "$GITHUB_USERNAME" || -z "$GITHUB_TOKEN" || -z "$CLIENT_IP" ]]; then
    echo "Error: GitHub Username, Token, and Client IP must be provided."
    exit 1
fi

# Check if CLIENT_IP is in valid IP format
if ! [[ "$CLIENT_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid Client IP format."
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

# Run server-specific tasks
COMMON_DIR="$HOME/common_file"
pushd "$HOME/VAP-Concierge/src/app/dds-adaptive/" > /dev/null
cp -r "$COMMON_DIR/frozen_inference_graph.pb" .
if $test_mode; then
    rm -rf "$COMMON_DIR/frozen_inference_graph.pb"
fi

# Download awstream model
pushd ../awstream-adaptive/
if [[ ! -f "$COMMON_DIR/ssd_mobilenet_v2_coco_2018_03_29.tar.gz" ]]; then
    echo "Downloading ssd_mobilenet_v2_coco_2018_03_29..."
    wget -q http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_coco_2018_03_29.tar.gz
fi

run_with_spinner "tar xvzf ssd_mobilenet_v2_coco_2018_03_29.tar.gz"
cp ssd_mobilenet_v2_coco_2018_03_29/frozen_inference_graph.pb .
if $test_mode; then
    rm -rf ssd_mobilenet_v2_coco_2018_03_29.tar.gz
fi
popd > /dev/null

# Additional server-specific tasks
setup_ramdisk
update_firewall_rules

# Additional code corrections
source "/home/cc/Concierge-VAP/common/edit_code_server.sh" "$CLIENT_IP"

# Update paths and conda environment
if setup_path_and_conda; then
    echo "success" > /home/cc/Concierge-VAP/common/build_server_success.txt
else
    echo "Error: Path and Conda setup failed." >&2
    exit 1
fi

echo "Server environment setup completed successfully."
