#! /usr/bin/bash

echo "CyPhER Baseline Install Script 20250206"

sudo DEBIAN_FRONTEND=noninteractive apt -y install git build-essential cmake openssl libssl-dev gcc pkg-config libpcap-dev libz-dev

git clone https://github.com/DrTimothyAldenDavis/GraphBLAS.git 
