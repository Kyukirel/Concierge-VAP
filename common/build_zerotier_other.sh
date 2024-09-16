#!/bin/bash

sudo apt update -y
curl -s https://install.zerotier.com | sudo bash
source ~/.bashrc
sudo zerotier-cli join 3efa5cb78abbc615