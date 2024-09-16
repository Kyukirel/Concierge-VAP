#!/bin/bash

# Tools Installation
cd $HOME
sudo apt-get update
sudo apt-get install -y iperf3 ffmpeg unzip wget

# Miniconda Installation
if [[ ! -d "$HOME/miniconda3" ]]; then
    echo "Installing Miniconda..."
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
    bash Miniconda3-py310_23.3.1-0-Linux-x86_64.sh -b -p "$HOME/miniconda3"
    rm Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
fi

# Initialize conda
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"

# Create a temporary environment for downloading files
TEMP_ENV="temp_env"
if conda env list | grep "$TEMP_ENV"; then
    echo "Temporary environment '$TEMP_ENV' already exists. Activating the environment."
    conda activate "$TEMP_ENV"
else
    echo "Creating temporary environment '$TEMP_ENV'."
    conda create -n "$TEMP_ENV" python=3.8 -y
    conda activate "$TEMP_ENV"
    pip install gdown
fi

# Download DDS dataset
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

# Download AWStream dataset
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

# Download frozen_inference_graph.pb (Concierge model)
if [ ! -f "frozen_inference_graph.pb" ]; then
    echo "Downloading frozen_inference_graph.pb..."
    wget -q http://people.cs.uchicago.edu/~kuntai/frozen_inference_graph.pb
else
    echo "frozen_inference_graph.pb exists."
fi

popd > /dev/null