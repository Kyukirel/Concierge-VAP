#!/bin/bash

# Tools Installation
cd $HOME
sudo apt-get update -y
sudo apt-get upgrade -y
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

yq -i '.dependencies[1] = tensorflow=1.14' conda_environment_configuration.yml

conda env create -f conda_environment_configuration.yml

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
fi

if [ ! -f "frozen_inference_graph.pb" ]; then
    wget people.cs.uchicago.edu/~kuntai/frozen_inference_graph.pb
fi

cd $HOME/dds-zharfanf/
unzip -o $COMMON_DIR/data-set-dds.zip -d .
rm -rf data-set
mv data-set-dds data-set

cp -r $COMMON_DIR/frozen_inference_graph.pb .
cp -r frozen_inference_graph.pb ./workspace


# Build Concierge
cd $$COMMON_DIR
if [ ! -f "profile-aws.zip" ]; then
    gdown --id 1vYs4sdrEHrxVMuoUdRjWCbo13ifZ4j-t
fi

cd $HOME
git clone https://github.com/zharfanf/VAP-Concierge.git
cd VAP-Concierge/

git checkout vap-zharfanf
cd src/app/dds-adaptive/
cp -rf $HOME/dds-zharfanf/data-set .

cd ../awstream-adaptive/
rm -rf data-set
unzip -o $COMMON_DIR/profile-aws.zip -d .
mv data-set-cpy data-set
cd data-set
for video in *; do cp -r ../../dds-adaptive/data-set/$video/src/ $video/; done

cd $HOME
sudo mkdir /tmp/ramdisk
sudo chmod 777 /tmp/ramdisk
sudo mount -t tmpfs -o size=80g myramdisk /tmp/ramdisk
mv VAP-Concierge/ /tmp/ramdisk/.
