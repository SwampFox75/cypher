## Creating a CyPhER Server VM
*These same instructions can be used to create a CyPhER server on bare metal.*
The steps below will walk you through how to set up an Ubuntu Server running CyPhER and the associated JupyterUI for it.
Please see the last section, **Custom Tooling** for installation and automation scripts.

### Base OS And Sensor Setup
Generally, any Linux based OS you want to use will work. We will use an Ubuntu server for this walkthrough.
1. Create the VM with the Ubuntu server iso in the virtual drive bay.
2. Install the OS with your preferred settings, the defaults should be fine.
	1. Make sure you note down the creds for the admin user you create.
	2. Enable SSH if you plan to work remotely.
3. After the install you need to reboot, login, and update the server.
	1. `sudo apt update && sudo apt upgrade`
4. If you plan to do analysis on the server locally (i.e, not from a different machine), install a GUI.
	1. `sudo apt install xubuntu-core`
	2. `sudo reboot now`
	3. After the reboot, login to the GUI to make sure it works.
	4. `sudo apt install firefox` *You will view the CyPhER GUI in a web browser*
5. Clone the ILANDS-sensor repo.
	1. `mkdir ~/CyPhER`
	2. `cd ~/CyPhER`
	3. `git clone https://github.com/CAIDA/ILANDS-sensor.git --depth 1`
6. Clone the GraphBLAS repo. *Until an issue is fixed, use branch 9 (Step 2) instead of the current branch (Step 1)*
	1. `# git clone https://github.com/DrTimothyAldenDavis/GraphBLAS.git --depth 1`
	2. `git clone https://github.com/DrTimothyAldenDavis/GraphBLAS.git --branch v9.4.branch --depth 1`
7. Install the necessary build tools
	1. `sudo apt install make cmake pkg-config openssl libssl-dev libpcap-dev zlib1g-dev`
8. Build and install GraphBLAS. This will take a bit of time to complete, so go get a coffee.
	1. `cd ~/CyPhER/GraphBLAS`
	2. `make`
	3. `sudo make install`
9. Build CyPhER from source.
	1. `cd ~/CyPhER/ILANDS-sensor`
	2. `make`
10. Optional additional steps
	1. `sudo apt install wireshark` *Useful to verify pcaps*
	2. `sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv` *Do the remaining steps if Ubuntu didnt use your full disk space*
	3. `sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv`
	4. `df -h` *Make sure your disks are the right size*

**You should now have have the primary tool we will be using installed in `~/CyPhER/ILANDS-sensor/build/src/pcap/pcap2grb`**

### Setting Up The Python GUI
*Make sure that you have completed all steps under "Base OS and Sensor Setup" before doing the steps below*
1. Set up the UI directory and python venv.
	1. `cd ~/CyPhER`
	2. `mkdir ui`
	3. `cp -r ILANDS-sensor/python-ui/\* ui/` *Replace this with the JupyterUI location when it gets added to repo*
	4. `sudo apt install python3.12-venv python3-pip` *If not already installed*
	5. `python3 -m venv cypher_python_env`
	6. `source ~/CyPhER/cypher_python_env/bin/activate`
2. Install required python packages. **DO NOT pip install d4m. The pip package is a mod manager for Project Diva, not the one we will use**
	1. `pip install dash dash_bootstrap_components plotly python-graphblas scipy py4j matplotlib pandas notebook ipywidgets numpy` 
	2. `git clone https://github.com/Accla/D4M.py.git --depth 1`
	3. `cd ~/CyPhER/D4M.py`
	4. `python setup.py install`


### Basics for Capturing Packet Headers
We are only interested in capturing the source and destination IP addresses of the packets being sent to this sensor. 
In order to avoid large PCAP files full of data we don't need, we can pick off only the first few bytes of all packets
sent to us with the following tcpdump command.
```
tcpdump -n -i enp0s3 -s 34 -w ipv4_headers.pcap
```
Explanation of the arguments: 
```` 
	-n: Don't do name resolution  
	-i: Interface to sniff. Put your interface here  
	-s: Snarf only *n* bytes, in this case 34 which stops right after the dst IP  
	-w: Output file
````
	
### Basics for Processing PCAPS
```
./pcap2grb -i [PCAP] -o [out_dir] # Output directory MUST exist or you will get an error
cd [out_dir]
ls -d “$PWD”/* > matrix_tar_filelist.txt
echo "$PWD"/matrix_tar_filelist.txt > process_filelist.txt
python GraphChallenge_analyses_hpec_benchmarking.py # ./logs must exist or you will get an error, edit out all the Supercloud info
cp stats.tsv ~/CyPhER/JupyterUI/code/
```

### Basics for using the JupyterUI
1. Place the stats.tsv file into the JupyterUI/code directory.
2. Place the grb tar files generated into the JupyterUI/data directory.
3. Run `jupyter notebook` in the JupyterUI/code directory.
4. Inside the Jupyter webpage, open the JupyterUI.ipynb notebook and follow the instructions inside it.

---

## Tools
Here are a few tool scripts that may be helpful. They can also be pulled from *[insert url here whenever I upload them somewhere]*

**Basic CyPhER Installation Script** *Save as install_cypher.sh*
```[bash]
#!/bin/bash
####
# Filename:      install_cypher.sh
# Author:        C. D. Milner
# Last Updated:  2023.03.19
# Purpose:       Basic install script for setting up a CyPhER server. Should be run as an admin user, using sudo.
#
# Usage: sudo install_cypher.sh
# 
# Error Handling: There is a little error checking between installation steps. If you want to restart at a specific 
# step, you should run the command as follows: sudo install_cypher.sh --step [section_number]
# Example: sudo install_cypher.sh --step 3
####

INSTALL_STEP="0"

if [[ "$SUDO_USER" == "" ]]; then
	echo "Please run this as an admin using sudo."
	echo "Example: sudo install_cypher.sh"
	exit 1
fi

if [[ $1 == "--step" ]]; then
	INSTALL_STEP=$2
fi

handle_error (){
	echo ""
	echo "!!!"
	echo "Error occured during install step $INSTALL_STEP."
	echo ""
	echo "If you would like to restart the install at this step, run the following:"
	echo "sudo cypher_install.sh --step $INSTALL_STEP"
	echo "!!!"
	echo ""
	echo "---- Install error during step $INSTALL_STEP" >> ./cypher_install.log
	exit 1
}

trap 'handle_error $LINENO' ERR

LOGFILE="$PWD"/cypher_install.log
INSTALL_DIR="$PWD"

echo "-- $(date) :: Starting install on step $INSTALL_STEP" >> $LOGFILE

do_install_step (){
	case $INSTALL_STEP in
		"0")
			echo "Begining install step 0."
			echo "Step 0 : Upgrading the server..." >> $LOGFILE
			chmod 644 ./cypher_install.log
			apt update
			apt upgrade
			echo "Step 0 : Setting up build environment..." >> $LOGFILE
			sudo $SUDO_USER mkdir ./cypher_sensor
			cd ./cypher_sensor #Currently in cypher_sensor
			sudo $SUDO_USER git clone https://github.com/CAIDA/ILANDS-sensor.git --depth 1
			sudo $SUDO_USER git clone https://github.com/DrTimothyAldenDavis/GraphBLAS.git --branch v9.4.branch --depth 1
			sudo $SUDO_USER git clone https://github.com/Accla/D4M.py.git --depth 1
			apt install make cmake pkg-config openssl libssl-dev libpcap-dev zlib1g-dev python3.12-venv python3-pip
			INSTALL_STEP="1"
			echo "Install step 0 completed." >> $LOGFILE
			;;
		"1")
			echo "Begining install step 1."
			echo "Step 1 : Building GraphBLAS..." >> $LOGFILE
			cd GraphBLAS
			sudo $SUDO_USER make
			make install
			echo "Step 1 : Building ILANDS-sensor..." >> $LOGFILE
			cd ../ILANDS-sensor
			sudo $SUDO_USER make
			echo "Step 1 : Building python environment..." >> $LOGFILE
			cd ..
			sudo $SUDO_USER python3 -m venv cypher_python_env
			sudo $SUDO_USER source cypher_python_env/bin/activate
			sudo $SUDO_USER pip install dash dash_bootstrap_components plotly python_graphblas scipy py4j matplotlib pandas notebook ipywidgets numpy
			echo "Step 1 : Installing Python D4M implementation..." >> $LOGFILE
			cd D4M.py
			python setup.py install
			INSTALL_STEP="2"
			echo "Install step 1 completed." >> $LOGFILE
			;;
		"2")
			echo "Begining install step 2."
			echo "Step 2 : Setting up tools folder..." >> $LOGFILE
			cd $INSTALL_DIR
			if [ ! -d ./ILANDS-sensor ]; then
				echo "./ILANDS-sensor directory not found, make sure this was run from the directory step 0 was run in."
				exit 1
			fi
			sudo $SUDO_USER mkdir tools
			cd tools
			sudo $SUDO_USER mkdir IPLists
			sudo $SUDO_USER cp -r ../ILANDS-sensor/python-v2 python
			sudo $SUDO_USER cp ../ILANDS-sensor/build/src/pcap/pcap2grb .
			sudo $SUDO_USER cp ../ILANDS-sensor/build/src/util/iplist2grb .
			sudo $SUDO_USER cp ../ILANDS-sensor/src/util/IPlist/*.txt ./IPLists
			sudo $SUDO_USER iplist2grb -n IPList-LE ./IPLists/rfc1918.txt ./IPLists/bogons.txt
			echo "Install step 2 completed." >> $LOGFILE
			INSTALL_STEP="3"
			;;
		*)
			INSTALL_STEP="DONE"
			;;
	esac
}


while [[ "$INSTALL_STEP" != "DONE" ]]; do
	do_install_step
done

echo "Install complete"
echo "-- $(date) :: Install script complete." >> $LOGFILE
```

**Create Rolling PCAPS** *Save as create_rolling_pcap.sh in [INSTALL_DIR]/tools/pcap, make changes to the user defined variables, then have it start on system boot*
```[bash]
#!/bin/bash
####
# Filename:      create_rolling_pcap.sh
# Author:        C. D. Milner
# Last Updated:  2023.03.26
# Purpose:       Script to kick off tcpdump to snarf src and dst packets.
####

# Where you want the rolling pcaps to be saved
LIVE_PCAP_DIR="./live_pcaps"

# The base name of the pcaps that will get made. When they roll they will have additional info added to the filename.
LIVE_PCAP_NAME="ipv4_headers.pcap"

# The interface you want to capture on. This should be where your span port points if monitoring off of a network device.
CAP_INTERFACE="enp0s3"

# PCAP size before rolling over. We capture the first 34 bytes of each packet, meaning we can use this to calculate a
# specific number of packets we want to roll on. The default unit of -C is 1,000,000 bytes. If we set our rotation default
# to 17, we rotate the log after collecting 500,000 packets.
ROT_PACKETS="17"

# Time in seconds before a new pcap will be created. The default is 3600, which is the number of seconds in an hour.
ROT_TIME="3600"

tcpdump -n -i $CAP_INTERFACE -C $ROT_PACKETS -G $ROT_TIME -s 34 -w "${LIVE_PCAP_DIR}/${LIVE_PCAP_NAME}"

```

**Process pcaps** *Save as process_pcap.sh in [INSTALL_DIR]/tools/pcap*
```[bash]
#!/bin/bash
####
# Filename:      process_pcap.sh
# Author:        C. D. Milner
# Last Updated:  2023.03.26
# Purpose:       Simple wrapper for pcap2grb to make the pcap analysis pipeline easier.
####

# The directory your rolling pcaps live. This matches the output of create_rolling_pcap.sh by default.
LIVE_PCAPS="./live_pcaps"

# The parent directory where each pcap subdirectory will be made. Matches the input of porcess_matrices.py by default.
OUT_DIR_PARENT="../matrices"

# Going to cd into this instead of referencing it to make the outfiles look nicer without extra cleaning steps
# Because this is going down one, make sure that the relative path of the out dir parent is right.
cd $LIVE_PCAPS

if [ ! -d $OUT_DIR_PARENT ]; then
	mkdir $OUT_DIR_PARENT
fi

for FILE in *; do
	mkdir "${OUT_DIR_PARENT}/${FILE}"
	../pcap2grb -i "$FILE" -o "${OUT_DIR_PARENT}/${FILE}"
done
```

**Process matrices** *Save as process_matrices.py in [INSTALL_DIR]/tools/python*
```[python]
####
# Filename:      process_matrices.py
# Author:        Hayden J., C. D. Milner
# Last Updated:  2023.03.19
# Purpose:       Process a set of .grb files to produce a stats.tsv file and accompanying matrices for analysis using the JupyterUI
####
import GraphChallenge_analyses_subrange as gb_analysis 
import contextlib
import sys
import os

# Path to the directory that contains .grb matrices to be processed.
# The default is set to the output directory of the [INSTALL_DIR]/tools/process_pcap.sh script.
# This dir should contain subdirs that are each time block associated with the output of pcap2grb.
matrix_dir = "../pcap/matrices"

matrix_list_dir = "../pcap/matrices_lists"

# A tarball with .grb matrices specifying subranges. Generally created with iplist2grb.
# The default is created from rfc1918 non-routable networks and bogons only.
subrange = "../IPList-2.tar"

# The file containing a list of text files that contains paths to tarballs to be processed. If create_tar_list = True 
# this will be generated automatically. Otherwise, you will need to create it yourself.
# Put simply: this is a text file, of text file paths, of tarball paths.
tar_list = "./tar_list_to_process.txt"
create_tar_list = True

if create_tar_list:
    print("Creating matrix list text files in %s ..." % matrix_list_dir)
    for dirpath, dirs, filenames in os.walk(matrix_dir):
        for d in dirs:
            with open(matrix_list_dir + str(d) + ".txt", 'w') as f:
                write_filenames_to_textfile(d, f)


    print("Creating tar_list_to_process.txt ...")
    with open(tar_list, 'w') as f:
        write_filenames_to_textfile(matrix_list_dir, f)


# Function to walk a directory then put the full filepaths into a given file. 
# Expects that out_file is already open and writable.
def write_filenames_to_textfile(walk_dir, out_file):
    for dirpath, dirs, filenames, in os.walk(walk_dir):
        for filename in filenames:
            print(os.path.join(dirpath, filename), file=out_file)


file_list = []
print("Loading file list: %s" % filename)
with open(filename, "r") as f:
    for line in f:
        file_list.append(line.split("\n")[0])

for file in file_list:
    print("Processing %s ..." % file)
    row_label = file.split("/")[-1]
    # Set up logging
    if not os.path.isdir("logs"):
        os.mkdir("logs")
    log_filepath = "./logs/matrix_analysis_log_" + row_label

    # Open logfile to print to
    with open(log_filepath, "a+") as f:
        # Redirect stdout to logfile
        with contextlib.redirect_stdout(f):
            # Run analyses_subrange against all files in user supplied file
            # The supplied file is a text file containing a list of tar files
            gb_analysis.process_filelist(file, subrange_tarfile=subrange, benchmark_name=row_label, save_range=True)
```