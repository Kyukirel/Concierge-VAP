#!/bin/bash

echo "Setting up server environment..."
set -e  # Exit immediately if a command exits with a non-zero status

THIS_CODE_DIR=$(dirname "$0")
source "$THIS_CODE_DIR/build_common.sh"

# DDS Setup
cd src/app/dds-adaptive/
# Download model for dds
cp -r "$COMMON_DIR/frozen_inference_graph.pb" .

# Awstream Setup
cd ../awstream-adaptive/
# Download model for awstream
if [[ ! -d "ssd_mobilenet_v2_coco_2018_03_29" ]]; then
    echo "Downloading ssd_mobilenet_v2_coco_2018_03_29..."
    wget -q http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_coco_2018_03_29.tar.gz
    run_with_spinner "tar xvzf ssd_mobilenet_v2_coco_2018_03_29.tar.gz"
    cp ssd_mobilenet_v2_coco_2018_03_29/frozen_inference_graph.pb .
else
    echo "ssd_mobilenet_v2_coco_2018_03_29 exists."
fi
popd > /dev/null

setup_ramdisk
update_firewall_rules

# Addition(s) to correct some of the code(s)
./edit_code_server.sh

# Update the path
setup_path_and_conda