#! /usr/bin/bash

# this is starting out as a simple script without any checks of any kind like error or existance checks

# write to console the script is starting
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

# download and install cryptopANT
path_cryptopant="$HOME/Downloads/cryptopANT"
echo "Creating directory cryptopANT in Downloads"
mkdir $path_cryptopant
wget -P ${path_cryptopant}/ https://ant.isi.edu/software/cryptopANT/cryptopANT-1.3.1.tar.gz
tar -xzf ${path_cryptopant}/cryptopANT-1.3.1.tar.gz -C $path_cryptopant
(cd $HOME/Downloads/cryptopANT/cryptopANT-1.3.1 && ./configure --with-scramble_ips)
make -C ${path_cryptopant}/cryptopANT-1.3.1
sudo make -C ${path_cryptopant}/cryptopANT-1.3.1 install
make -C ${path_cryptopant}/cryptopANT-1.3.1 clean

# download and install ILANDS (CyPhER)
path_ilands="$HOME/Downloads/ILANDS"
echo "Creating directory ILANDS in Downloads"
mkdir $path_ilands
git clone https://github.com/CAIDA/ILANDS-sensor.git $path_ilands
make -C $path_ilands
sudo make -C $path_ilands install
make -C $path_ilands clean

# run ldconfig to update shared libraries
sudo ldconfig
