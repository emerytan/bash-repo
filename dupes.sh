#!/bin/bash

#globals
srcBase=$(basename $1)
tempDir="/Users/$USER/duplicateFinder"
tempHashes="/Users/$USER/duplicateFinder/${srcBase}_sums.md5"
dupes="/Users/$USER/duplicateFinder/${srcBase}_hitHashes.txt"
report="/Users/$USER/duplicateFinder/${srcBase}_duplicates"
clear

if [ ! -d "$1" ]; then
	echo "argument error: source entered is not a directory."
	echo
	exit 1
fi

echo -e "\n\n"
echo -e "this script will recursivels create md5's, match duplicates, then create a logfile.\n"

#echo -e "cleaning out old md5's.\nremoving:"
#rm -rfv $tempDir/*
#mkdir -p $tempDir
#sleep 1

if [[ -e $tempHashes ]]; then
	echo -e "older version of md5 exists.  It will be deleted."
	rm -v "$tempHashes"
	sleep 1
fi

cd "$1"

tput setaf 3
echo -e "\ngenerating md5's..."
find . -type f | grep -v ".DS_St" | while read i; do
	md5 -r "$i" >>"$tempHashes"
done

cp -v "$tempHashes" "$1"

tput setaf 2
echo -e "finished hashing source\n"

tput setaf 3
echo -e "finding duplicates..."
awk '{ print $1 }' $tempHashes | sort | uniq -d >>$dupes
tput setaf 2
echo -e "finished duplicate search\n"
tput sgr 0

tput setaf 3
echo -e "generating list of duplicates..."
count=1
mkdir -p $report
cat $dupes | while read matches; do
	grep $matches $tempHashes | cut -c 34- >>$report/hit${count}.txt
	echo -e "Keep All" >>$report/hit${count}.txt
	((count++))
done
tput setaf 2
echo -e "finished building duplicates list.\n"
tput sgr 0

echo -e -n "would you like to see results? Enter 'y' "
read CNF

if [ "$CNF" != "y" ]; then
	echo -e "\nOK.\nbye..."
	echo
	exit
fi

cd $report
echo
ls -1 | while read hitList; do
	reportClean=$(echo $hitList | sed 's/.txt//')
	echo -e "$reportClean\n$(cat $hitList | grep -v "Keep All")\n>----<\n"
done

echo -e "\nremoving temp files..."
rm -v "$dupes"
echo -e "\ndone."
# echo -e "\ndone.\ncreated file:$(tput setaf 2) ${report} $(tput sgr 0)which contains duplicate list for$(tput setaf 2) $1$(tput sgr 0)."
echo
exit
