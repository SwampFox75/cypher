#! /usr/bin/bash

echo "CyPhER Baseline Install Script 20250206"

# install all package dependencies
sudo DEBIAN_FRONTEND=noninteractive apt -y install git build-essential cmake openssl libssl-dev gcc pkg-config libpcap-dev libz-dev

# download and install GraphBLAS
path_graphblas="$HOME/Downloads/GraphBLAS"
echo "Creating directory GraphBLAS in Downloads"
mkdir $path_graphblas
git clone https://github.com/DrTimothyAldenDavis/GraphBLAS.git $path_graphblas
make -C $path_graphblas
sudo make -C $path_graphblas install
make -C $path_graphblas clean
