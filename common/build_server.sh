#!/bin/bash

echo "Setting up server environment..."
set -e  # Exit immediately if a command exits with a non-zero status

# Function to install required packages
install_packages() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            echo "Installing missing command: $pkg"
            sudo apt-get install -y "$pkg"
        else
            echo "$pkg is already installed."
        fi
    done
}

# Tools Installation
cd $HOME
sudo apt-get update
install_packages iperf3 ffmpeg unzip wget
if ! command -v yq &>/dev/null; then
    echo "Installing yq..."
    sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
    sudo chmod +x /usr/bin/yq
else
    echo "yq is already installed."
fi

# Miniconda Installation
if [[ ! -d "$HOME/miniconda3" ]]; then
    echo "Installing Miniconda..."
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
    bash Miniconda3-py310_23.3.1-0-Linux-x86_64.sh -b -p "$HOME/miniconda3"
    rm Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
fi

# Initialize conda
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
# Build DDS and environment
DDS_DIR="$HOME/dds-zharfanf"
if [[ ! -d "$DDS_DIR" ]]; then
    echo "Cloning DDS repository..."
    git clone https://github.com/zharfanf/dds-zharfanf.git "$DDS_DIR"
else
    echo "DDS repository already cloned."
fi

pushd "$DDS_DIR" > /dev/null
git checkout edge

yq -i '(.dependencies[] | select(. == "tensorflow-gpu=1.14")) = "tensorflow=1.14"' conda_environment_configuration.yml

if conda env list | grep 'dds'; then
    echo "Environment 'dds' already exists. Updating the environment."
    conda env update -f conda_environment_configuration.yml --name dds
else
    echo "Creating new 'dds' environment."
    conda env create -f conda_environment_configuration.yml
fi

conda activate dds

# Install libraries for DDS
python_packages=(gdown pandas matplotlib grpcio grpcio-tools jupyter)
for package in "${python_packages[@]}"; do
    if ! pip show "$package" &>/dev/null; then
        echo "Installing Python package in Conda environment: $package"
        pip install "$package"
    else
        echo "Python package $package is already installed in Conda environment."
    fi
done
popd > /dev/null

# Download dataset
COMMON_DIR="$HOME/common_file"
mkdir -p "$COMMON_DIR"
pushd "$COMMON_DIR" > /dev/null
if [ ! -f "data-set-dds.tar.gz" ]; then
    echo "Downloading data-set-dds.tar.gz..."
    if gdown --id 1khK3tPfdqonzpgT_cF8gaQs_rPdBkdKZ; then
        echo "Downloaded data-set-dds.tar.gz with the first ID."
    else
        # If download fails, try with the second ID
        echo "Failed to download with the first ID. Trying with the new ID..."
        if gdown --id 1TXnkaAstdFjWAZfne-UTcgpoSMcNyGqJ; then
            echo "Downloaded data-set-dds.tar.gz with the new ID."
        else
            echo "Failed to download with both IDs."
            exit 1
        fi
    fi
else
    echo "data-set-dds.tar.gz exists."
fi

tar xvf data-set-dds.tar.gz
new_item=$(tar tf data-set-dds.tar.gz | head -n 1 | cut -d '/' -f 1)
rm -rf "$DDS_DIR/$new_item"
mv "$new_item" "$DDS_DIR"

if [ ! -f "frozen_inference_graph.pb" ]; then
    echo "Downloading frozen_inference_graph.pb..."
    wget -q http://people.cs.uchicago.edu/~kuntai/frozen_inference_graph.pb
else
    echo "frozen_inference_graph.pb exists."
fi

cp ./frozen_inference_graph.pb "$DDS_DIR"
cp ./frozen_inference_graph.pb "$DDS_DIR/workspace"
popd > /dev/null

## Build Concierge and environment
VAP_DIR="$HOME/VAP-Concierge"
if [[ ! -d "$VAP_DIR" ]]; then
    echo "Cloning VAP Concierge repository..."
    # git clone https://github.com/zharfanf/VAP-Concierge.git
    git clone https://github.com/Kyukirel/VAP-Concierge.git
else
    echo "VAP Concierge repository already cloned."
fi
pushd "$VAP_DIR" > /dev/null

git checkout vap-zharfanf

# Update the IP address in envTest.sh and run_zharfanf.sh
DEFAULT_CLIENT_IP="10.140.81.162"
read -p "Enter the IP address to use (or press Enter to use the default [$DEFAULT_CLIENT_IP]): " USER_INPUT_IP
CLIENT_IP=${USER_INPUT_IP:-$DEFAULT_CLIENT_IP}
echo "Using IP address: $CLIENT_IP"
# Search for the first eligible IP address in the envTest.sh file and store it in ORIGINAL_IP
ORIGINAL_IP=$(grep -oP '(?<=http://)\d{1,3}(\.\d{1,3}){3}(?=:6000/)' src/envTest.sh | head -n 1)
if [ -z "$ORIGINAL_IP" ]; then
    echo "No IP address found in envTest.sh matching the pattern 'http://<IP>:6000/'. Exiting."
    exit 1
fi
echo "Original IP found: $ORIGINAL_IP"
# Replace the original IP with the new CLIENT_IP in envTest.sh and run_zharfanf.sh
sed -i "s|$ORIGINAL_IP|$CLIENT_IP|g" src/envTest.sh
sed -i "s|$ORIGINAL_IP|$CLIENT_IP|g" src/run_zharfanf.sh

cd src/app/dds-adaptive/
# Download model for dds
cp -r "$COMMON_DIR/frozen_inference_graph.pb" .


# Awstream Setup
cd ../awstream-adaptive/
# Download model for awstream
if [[ ! -d "ssd_mobilenet_v2_coco_2018_03_29" ]]; then
    echo "Downloading ssd_mobilenet_v2_coco_2018_03_29..."
    wget -q http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v2_coco_2018_03_29.tar.gz
    tar xvzf ssd_mobilenet_v2_coco_2018_03_29.tar.gz
    cp ssd_mobilenet_v2_coco_2018_03_29/frozen_inference_graph.pb .
else
    echo "ssd_mobilenet_v2_coco_2018_03_29 exists."
fi
popd > /dev/null


# Migrate Concierge to tmp filesystem with ramdisk installed
# Location: /tmp/ramdisk/VAP-Concierge/
RAMDISK_DIR="/tmp/ramdisk"
if mountpoint -q "$RAMDISK_DIR"; then
    echo "Ramdisk is already mounted."
    sudo umount "$RAMDISK_DIR"
fi
if  [[ ! -d "$RAMDISK_DIR" ]]; then
    echo "Creating $RAMDISK_DIR directory."
    sudo mkdir "$RAMDISK_DIR"
fi

echo "$RAMDISK_DIR exists. Cleaning up the directory."
sudo rm -rf "$RAMDISK_DIR/*"
sudo chmod 777 "$RAMDISK_DIR"
sudo mount -t tmpfs -o size=100g myramdisk "$RAMDISK_DIR"
echo "Ramdisk mounted."

echo "Migrating VAP-Concierge to ramdisk..."
mv VAP-Concierge/ /tmp/ramdisk/.
echo "VAP-Concierge is moved to ramdisk."

# Update the path
echo "Exporting PATH..."
echo 'export PATH=$PATH:/home/cc/miniconda3/bin' >> ~/.bashrc
echo "Restarting the shell..."
source ~/.bashrc
echo "Server environment setup is completed."

# Additions to the script to update the firewall rules
sudo iptables-save > ~/iptables-backup.txt
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo firewall-cmd --complete-reload
sudo firewall-cmd --zone=trusted --add-interface=eno1 --permanent
sudo firewall-cmd --reload
