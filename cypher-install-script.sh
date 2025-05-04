#! /usr/bin/bash
# this is starting out as a simple script without any checks of any kind like error or existance checks

# write to console the script is starting
echo "CyPhER Baseline Install Script 20250504"

# install all package dependencies
sudo apt -y install git build-essential cmake openssl libssl-dev gcc pkg-config libpcap-dev libz-dev

# check if /Documents/GitHub exists, create it if it does not
if [[ -d "$HOME/Documents/GitHub" ]]; then
  echo "Default GitHub directory already exists"
else
  echo "Creating GitHub directory in default location"
  mkdir	$HOME/Documents/GitHub
fi

# download and install GraphBLAS
path_graphblas="$HOME/Documents/GitHub/GraphBLAS"
echo "Creating directory GraphBLAS in $HOME/Documents/GitHub/"
mkdir $path_graphblas
git clone https://github.com/DrTimothyAldenDavis/GraphBLAS.git $path_graphblas
make -C $path_graphblas JOBS=4
sudo make -C $path_graphblas install
make -C $path_graphblas clean

# download and install cryptopANT
path_cryptopant="$HOME/Documents/GitHub/cryptopANT"
echo "Creating directory cryptopANT in $HOME/Documents/GitHub/"
mkdir $path_cryptopant
wget -P ${path_cryptopant}/ https://ant.isi.edu/software/cryptopANT/cryptopANT-1.3.1.tar.gz
tar -xzf ${path_cryptopant}/cryptopANT-1.3.1.tar.gz -C $path_cryptopant
(cd $HOME/Documents/GitHub/cryptopANT/cryptopANT-1.3.1 && ./configure --with-scramble_ips)
make -C ${path_cryptopant}/cryptopANT-1.3.1
sudo make -C ${path_cryptopant}/cryptopANT-1.3.1 install
make -C ${path_cryptopant}/cryptopANT-1.3.1 clean

# download and install ILANDS (CyPhER)
path_ilands="$HOME/Documents/GitHub/ILANDS"
echo "Creating directory ILANDS in $HOME/Documents/GitHub/"
mkdir $path_ilands
git clone https://github.com/CAIDA/ILANDS-sensor.git $path_ilands
make -C $path_ilands
sudo make -C $path_ilands install
make -C $path_ilands clean

# download and install D4M.py
path_d4m="$HOME/Documents/GitHub/D4M"
echo "Creating directory D4M in $HOME/Documents/GitHub/"
mkdir $path_d4m
git clone https://github.com/Accla/D4M.py.git $path_d4m

# run ldconfig to update shared libraries
sudo ldconfig
