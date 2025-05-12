#!/bin/bash

#globals
srcBase=`basename $1`
tempDir="/home/$USER/etaHashGen"
tempHashes="/home/$USER/etaHashGen/${srcBase}_sums.md5"
dupes="/home/$USER/etaHashGen/${srcBase}_hitHashes.txt"
report="/home/$USER/etaHashGen/${srcBase}_duplicates"
clear

if [ ! -d "$1" ]; then
	echo "argument error: source entered is not a directory."
	echo
	exit 1
fi

echo -e "\n\n"

if [[ ! -e $tempDir ]]; then
	echo -e "first run.  Creating temp dir @ ${tempDir}"
	mkdir -p $tempDir
	sleep 2
else
	echo -e "temp dir location: ${tempDir}"
	sleep 2
fi


if [[ -e $tempHashes ]]; then
  echo -e "older version of md5 exists.  It will be deleted."
  rm -v "$tempHashes"
  sleep 1
fi

cd "$1"

tput setaf 3
echo -e "\ngenerating md5's..."
find . -type f | grep -v "DS_St" | while read i; do
  md5sum "$i" >> "$tempHashes"
done

# cp -v "$tempHashes" "$1"

tput sgr 0

exit
