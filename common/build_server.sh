#!/bin/bash

echo "Setting up server environment..."
set -e  # Exit immediately if a command exits with a non-zero status

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <GitHub Username> <GitHub Token> <Client IP>"
    exit 1
fi

# Get the GitHub username, token, and client IP from arguments
GITHUB_USERNAME="$1"
GITHUB_TOKEN="$2"
CLIENT_IP="$3"

# Source the common script
THIS_CODE_DIR=$(dirname "$0")
source "$THIS_CODE_DIR/build_common.sh"

# Run common functions
install_tools
install_miniconda
setup_dds
setup_vap_concierge

# Run server-specific tasks
pushd "$HOME/VAP-Concierge/src/app/dds-adaptive/" > /dev/null
cp -r "$COMMON_DIR/frozen_inference_graph.pb" .

# Download awstream model
pushd ../awstream-adaptive/
if [[ ! -f "$COMMON_DIR/ssd_mobilenet_v2_coco_2018_03_29.tar.gz" ]]; then
    echo "Downloading ssd_mobilenet_v2_coco_2018_03_29..."
    wget -q http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_coco_2018_03_29.tar.gz
fi

run_with_spinner "tar xvzf ssd_mobilenet_v2_coco_2018_03_29.tar.gz"
cp ssd_mobilenet_v2_coco_2018_03_29/frozen_inference_graph.pb .
popd > /dev/null

# Additional server-specific tasks
setup_ramdisk
update_firewall_rules

# Additional code corrections
source "$THIS_CODE_DIR/edit_code_server.sh" "$CLIENT_IP"

# Update paths
setup_path_and_conda && echo "success" > /home/cc/Concierge-VAP/common/build_server_success.txt
