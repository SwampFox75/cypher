#! /usr/bin/bash

# create variables to store directory paths
pcap_direcotry="/home/cypher-user/Desktop/cypher/pcaps"
grbs_directory="/home/cypher-user/Desktop/cypher/grbs"
tmp_directory="/home/cypher-user/Desktop/cypher/tmp"

# uncomment the lines below to clear the tmp directory of all previous runs each time to save space
# rm $tmp_directory/*
# $(date '+%b %d %Y %H:%M:%S') $(hostname) clearing tmp folder

# script to take all but the latest pcap and convert it to grbs
# get an array of all pcaps in the pcap folder sorted from newest to oldest
pcap_list=($(find $pcap_direcotry -type f -name "*.pcap" | sort -nr))

# get a count of the pcap files in the pcap folder
pcap_count=${#pcap_list[@]}

# if there is more than one pcap then process them to grbs
# if there is only one pcap it is probably being written to by tcpdump
if [[ $pcap_count > 1 ]]; then
	for pcap in ${pcap_list[@]:1}; do
		echo "$(date '+%b %d %Y %H:%M:%S') $(hostname) running pcap2grb on $pcap"
		pcap2grb -i $pcap -o $grbs_directory 2>&1
		echo "$(date '+%b %d %Y %H:%M:%S') $(hostname) moving $pcap to cypher/tmp"
		mv $pcap $tmp_directory
	done
elif [[ $pcap_count == 1 ]]; then
	echo "$(date '+%b %d %Y %H:%M:%S') $(hostname) only one pcap - leaving alone"
else
	echo "$(date '+%b %d %Y %H:%M:%S') $(hostname) no pcaps to process"
fi
