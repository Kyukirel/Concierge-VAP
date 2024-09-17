#!/bin/bash

echo "Running common build script..."
git config --global user.email "18120048@std.stei.itb.ac.id"
git config --global user.name "Rafael-SW048"

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

# Function to display a rotating spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to run a command with a spinner
run_with_spinner() {
    local command="$1"
    echo "Running command: $command"
    eval "$command" &>/dev/null &
    local pid=$!
    spinner $pid
    wait $pid

    local exit_status=$?
    if [ $exit_status -ne 0 ]; then
        echo "Command failed with exit status $exit_status."
    else
        echo "Command completed successfully."
    fi
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

run_with_spinner "tar xvf data-set-dds.tar.gz"
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
    # git clone https://github.com/Kyukirel/VAP-Concierge.git
    git clone https://github.com/Rafael-SW048/VAP-Concierge.git
else
    echo "VAP Concierge repository already cloned."
fi
pushd "$VAP_DIR" > /dev/null
# git checkout vap-zharfanf


# Function that will be used at the end of the script
setup_ramdisk() {
    # Migrate Concierge to tmp filesystem with ramdisk installed
    echo "Setting up ramdisk..."
    RAMDISK_DIR="/tmp/ramdisk"
    if mountpoint -q "$RAMDISK_DIR"; then
        echo "Ramdisk is already mounted."
        sudo umount "$RAMDISK_DIR"
    fi
    if [[ ! -d "$RAMDISK_DIR" ]]; then
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
}

update_firewall_rules() {
    # Update the firewall rules
    echo "Updating firewall rules..."
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
}

setup_path_and_conda() {
    # Update the path
    echo "Exporting PATH..."
    echo 'export PATH=$PATH:/home/cc/miniconda3/bin' >> ~/.bashrc
    echo "Applying the changes to the current shell..."
    source ~/.bashrc
    echo "Initializing conda in a new terminal..."
    conda init bash && source ~/.bashrc && conda --version && echo "Client environment setup is completed. Please check the new terminal for conda initialization." && conda activate dds
}
