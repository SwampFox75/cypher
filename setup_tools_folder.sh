#!/bin/bash
# Run this in the ./tools folder
mkdir IPLists
cp -r ../ILANDS-sensor/python-v2 python
cp ../ILANDS-sensor/build/src/pcap/pcap2grb .
cp ../ILANDS-sensor/build/src/util/iplist2grb .
cp ../ILANDS-sensor/src/util/IPlist/*.txt ./IPLists
iplist2grb -n IPList-LE ./IPLists/rfc1918.txt ./IPLists/bogons.txt