#! /usr/bin/bash

# FUNCTIONS
# recursive function to trap user in interface selection until good
ask_interface(){
	# show a list of interfaces to the user
	echo "List of interfaces found by TCPDump:"
	tcpdump --list-interfaces
	echo ""
	echo "Please type in the interface to monitor:"
	read pcap_interface
	echo ""
	echo "You have chosen" $pcap_interface
	echo "Is this correct? (y/n) "
	read double_check
	
	# recursive trap for confirmation, only advances if good
	if [[ $double_check == "y" || $double_check == "Y" ]]; then
		# if the user enters y or Y
		echo ""
		echo "proceeding..."
		echo ""
	else
		# if the user does not enter y or Y
		echo ""
		echo "please try again..."
		echo ""
		ask_interface
	fi
}

# MAIN
# intro shown to the user for this script
echo "Cypher NetCap Service Starting Script"
echo "This script will help you choose which interface to monitor"
echo "Then it will create a service to run in the background"
echo "To make the service run on boot it must be enabled"
echo ""

# prompt the user to enter the interface and double check
# this is a recursive 
ask_interface

# create the pcap service with the chosen interface
svc_temp_path="/home/cypher-user/Desktop/cypher/scripts/cypher-netcap-template.service"
svc_dest_path="/etc/systemd/system/cypher-netcap.service"
tcp_temp_path="/home/cypher-user/Desktop/cypher/scripts/cypher-netcap-template.sh"
tcp_dest_path="/home/cypher-user/Desktop/cypher/scripts/cypher-netcap.sh"

# replace the interface name in the script the service calls
# the template file has interface spelled with three repeating letters to avoid accidental overwrites with sed
echo "Attempting to overwrite previous configuration"
# make a copy of the service template to /etc/systemd/system/
sudo cp -f $svc_temp_path $svc_dest_path
# make a copy of the tcpdump script to run from the template in the scripts directory
sudo cp -f $tcp_temp_path $tcp_dest_path
# make the fresh copy of the script executable
sudo chmod +x $tcp_dest_path
# replace the anchor word (interFFFace) in the template with the chosen interface name
sudo sed -i "s/interFFFace/$pcap_interface/" $tcp_dest_path
echo "Complete"

# start or restart the service with the new configuration
echo "Reloading systemctl daemon"
sudo systemctl daemon-reload
echo "starting cypher-netcap service"
sudo systemctl start cypher-netcap
