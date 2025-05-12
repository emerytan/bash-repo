#!/bin/bash
# 20131125

clear
echo -e "|-->    LTFS Mounter    <--|\n\n"
CHKM=`df -h | grep ltfs`
if [ "${CHKM}" == "ltfs" ]; then
	TAPEID=`df -h | cut -f1`
	echo -e "ltfs tape already mounted; $TAPEID is currently in use.\n"
fi


## Choose Tape Device ##
drv

## Mount Tape ##
mountpoint="/media/ltfs"
mkdir $mountpoint
sudo chmod -R a+rw $mountpoint
clear
echo -e -n "enter system password when prompted, press any key to continue: "
read -n 1
mkdir $mountpoint/$tapeCode
## Mount ##
sudo ltfs -o devname=$drv -o sync_type=time@30 $mountpoint/$tapeCode
## Wait for tape to mount in background ##
wait

## finish up ##
FCHKM=`sudo df -h | awk '/ltfs/ { print $1 }'`
if [ "${FCHKM}" == "ltfs" ]; then
	echo -e -n "\n\nSuccess!! Hit any key to exit: "
	read -n 1
	echo -e "\nbye...\n"
	sleep 3
	exit
	else
		echo -e "\nLTFS mount failed, check for errors."
		echo -e -n "press any key to exit... "
		read -n 1
		echo -e "\nbye...\n"
		sleep 3
		exit
fi
