#!/bin/bash

echo "Setting up client environment..."
set -e  # Exit immediately if a command exits with a non-zero status

THIS_CODE_DIR=$(dirname "$0")
source "$THIS_CODE_DIR/build_common.sh"

# DDS Setup
cd src/app/dds-adaptive/
cp -rf $HOME/dds-zharfanf/data-set .
popd > /dev/null

# AWStream Setup
# Download dataset for awstream
pushd "$COMMON_DIR"
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

run_with_spinner "tar xvzf data-set-awstream.tar.gz"
new_item_awstream=$(tar tf data-set-awstream.tar.gz | head -n 1 | cut -d '/' -f 1)
rm -rf "$$HOME/VAP-Concierge/src/app/awstream-adaptive/$new_item_awstream"
mv "$new_item_awstream" "$HOME/VAP-Concierge/src/app/awstream-adaptive/"
popd > /dev/null

setup_ramdisk
update_firewall_rules

# Addition(s) to correct some of the code(s)
source $THIS_CODE_DIR/edit_code_client.sh

# Update the path
setup_path_and_conda && echo "success" > /home/cc/Concierge-VAP/common/build_server_success.txt