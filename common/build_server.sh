#!/bin/bash

# Tools Installation
cd $HOME
sudo apt-get update
sudo apt install -y iperf3
sudo apt install -y ffmpeg
sudo apt install -y unzip
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq

# Miniconda Installation
if [[ ! -d  "./miniconda3" ]]; then
    wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh
    bash Miniconda3-py310_23.3.1-0-Linux-x86_64.sh -b -p $HOME/miniconda3
fi

eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
# Build DDS
git clone https://github.com/zharfanf/dds-zharfanf.git

cd dds-zharfanf/

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

pip install gdown
pip install pandas
pip install matplotlib
pip install grpcio grpcio-tools
pip install jupyter

# Download Common Data
COMMON_DIR="$HOME/Concierge-VAP/common"
cd $COMMON_DIR

if [ ! -f "data-set-dds.zip" ]; then
    gdown --id 1_dReQ4jiPCtAQvHZSN56MKyGr5dV1MfR
else
    echo "data-set-dds.zip exists."
fi

if [ ! -f "frozen_inference_graph.pb" ]; then
    wget people.cs.uchicago.edu/~kuntai/frozen_inference_graph.pb
else
    echo "frozen_inference_graph.pb exists."
fi

cd $HOME/dds-zharfanf/

echo "Unzipping data-set-dds.zip..."
unzip -o $COMMON_DIR/data-set-dds.zip -d . > /dev/null
echo "Unzip process finished."

rm -rf data-set
mv data-set-cpy data-set

cp -r $COMMON_DIR/frozen_inference_graph.pb .
cp -r frozen_inference_graph.pb ./workspace


# Build Concierge
cd $HOME
git clone https://github.com/Kyukirel/VAP-Concierge.git
cd VAP-Concierge/

git checkout vap-zharfanf
cd src/app/dds-adaptive/
cp -r $COMMON_DIR/frozen_inference_graph.pb .
# wget people.cs.uchicago.edu/~kuntai/frozen_inference_graph.pb
# gdown --id 1_dReQ4jiPCtAQvHZSN56MKyGr5dV1MfR
# unzip data-set-dds.zip
# rm -f data-set-dds.zip
# mv data-set-cpy data-set

cd ../awstream-adaptive/
cp -r $COMMON_DIR/frozen_inference_graph.pb .
# wget people.cs.uchicago.edu/~kuntai/frozen_inference_graph.pb
# gdown --id 1vYs4sdrEHrxVMuoUdRjWCbo13ifZ4j-t
# unzip profile-aws.zip
# rm -f profile-aws.zip
# mv data-set-cpy data-set
# cd data-set
# for video in ./*; do cp -r ../dds-adaptive/data-set/$video/src/ $video/; done

cd $HOME

if mountpoint -q /tmp/ramdisk; then
    echo "/tmp/ramdisk is already mounted. Unmounting now."
    sudo umount /tmp/ramdisk
fi

if [ -d "/tmp/ramdisk" ]; then
    echo "/tmp/ramdisk exists. Clearing its contents."
    sudo rm -rf /tmp/ramdisk/*
    sudo chmod 777 /tmp/ramdisk
else
    echo "Creating /tmp/ramdisk directory."
    sudo mkdir /tmp/ramdisk
    sudo chmod 777 /tmp/ramdisk
fi

sudo mount -t tmpfs -o size=80g myramdisk /tmp/ramdisk
echo "Ramdisk mounted."
mv VAP-Concierge/ /tmp/ramdisk/.