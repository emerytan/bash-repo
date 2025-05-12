#!/bin/bash
# tc2frames.sh



function parseEDL () {
	whereAmi=$(pwd)

  awk '{ if ( $1 ~ /^[0-9]/ ) print $2, $5, $6 }' $1 > $whereAmi/shots.txt 
  
  echo -e "$(tput setaf 2)done" 
  echo -e "Starting SMPTE to frames conversion...\n\n"
  tput sgr 0
  awk 'BEGIN { FS = "[\ \:]+" } {  \
  	inHours = $2 * 3600 * 24
  	inMinutes = $3 * 60 * 24
  	inSeconds = $4 * 24
  	inFrames = $5
  	start = inHours + inMinutes + inSeconds + inFrames
  	outHours = $6 * 3600 * 24
  	outMinutes = $7 * 60 * 24
  	outSeconds = $8 * 24
  	outFrames = $9
  	end = outHours + outMinutes + outSeconds + outFrames
  	printf "%-26s %07d %07d\n", $1, start, end }' $whereAmi/shots.txt
}



function edlCheck () {
	isEDL=$(awk 'NR <= 1 { print $1 }' $1)
	if [ "$isEDL" = "TITLE:" ]; then
	  echo -e "is an EDL"
	  parseEDL $1
	else
		echo -e "not an EDL"
	fi
}




if [[ $1 != "" ]]; then
	clear
	echo -e "EDL Parser"
else
	echo -e "no file to work with"
	exit
fi


if [ -e $1 ]; then
	echo -e "\n$1 exists"
	edlCheck $1
else
	echo -e "\n\nerror:\n\t-- file entered doesn't exist.\n\t-- check your path, make sure the file you'd like to use exists.\nexiting.\n"
	exit
fi
