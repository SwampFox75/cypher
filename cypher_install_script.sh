#! /usr/bin/bash

# this is starting out as a simple script without any checks of any kind like error or existance checks

# write to console the script is starting
echo "CyPhER Baseline Install Script 20250206"

# install all package dependencies
sudo DEBIAN_FRONTEND=noninteractive apt -y install git build-essential cmake openssl libssl-dev gcc pkg-config libpcap-dev libz-dev

# download and install GraphBLAS
path_graphblas="/usr/local/src/GraphBLAS"
echo "Creating directory GraphBLAS in /usr/local/src/"
mkdir $path_graphblas
git clone https://github.com/DrTimothyAldenDavis/GraphBLAS.git $path_graphblas
make -C $path_graphblas
sudo make -C $path_graphblas install
make -C $path_graphblas clean

# download and install cryptopANT
path_cryptopant="/usr/local/src/cryptopANT"
echo "Creating directory cryptopANT in /usr/local/src/"
mkdir $path_cryptopant
wget -P ${path_cryptopant}/ https://ant.isi.edu/software/cryptopANT/cryptopANT-1.3.1.tar.gz
tar -xzf ${path_cryptopant}/cryptopANT-1.3.1.tar.gz -C $path_cryptopant
(cd /usr/local/src/cryptopANT/cryptopANT-1.3.1 && ./configure --with-scramble_ips)
make -C ${path_cryptopant}/cryptopANT-1.3.1
sudo make -C ${path_cryptopant}/cryptopANT-1.3.1 install
make -C ${path_cryptopant}/cryptopANT-1.3.1 clean

# download and install ILANDS (CyPhER)
path_ilands="/usr/local/src/ILANDS"
echo "Creating directory ILANDS in /usr/local/src/"
mkdir $path_ilands
git clone https://github.com/CAIDA/ILANDS-sensor.git $path_ilands
make -C $path_ilands
sudo make -C $path_ilands install
make -C $path_ilands clean

# run ldconfig to update shared libraries
sudo ldconfig
