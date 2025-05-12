#!/bin/bash

timeStamp=$(date +%H%M)
tempPath="/tmp/edlConvert/$timeStamp"
mkdir -p $tempPath

function parseEDL () {
	EDL=$(basename $1)
	edlName=$(echo $EDL | sed 's/.*//g')
	awk -F"~" '{ if ( $15 ~ /^[0-9]/ ) print $19, $15, $16 }' $1 > $tempPath/$EDL
	echo -e "wrote converted EDL to temp direcory: "
	echo -e "result: \n$(cat $tempPath/$EDL)"
	echo -e "starting SMPTE to frames conversion in 5 seconds..."
	sleep 5
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
		printf "%-26s %07d %07d\n", $1, start, end }' $tempPath/$EDL > $tempPath/frames${EDL}
		madeFrames="$tempPath/frames${EDL}"
}

parseEDL $1


echo -e "out of function"
echo -e "results:\n$(cat $madeFrames)"
exit
