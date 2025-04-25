#! /usr/bin/bash

# kill any tcpdump processes to prevent them from stacking by accident
pkill -f tcpdump

# start tcpdump to the pcaps folder on the desktop
/usr/bin/tcpdump -i enp0s3 -nnn ip -s 34 -K -U -B 1048576 -G 3600 -w /home/cypher-user/Desktop/cypher/pcaps/%Y-%m-%d-%H%M-%S.pcap
