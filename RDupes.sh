#!/bin/bash

#globals
srcDir="$1"
srcBase=$(basename "$srcDir")
tempDir="/Users/$USER/duplicateFinder"
tempHashes="/Users/$USER/duplicateFinder/${srcBase}_sums.md5"
dupes="/Users/$USER/duplicateFinder/${srcBase}_hitHashes.txt"
report="/Users/$USER/duplicateFinder/${srcBase}_duplicates"
clear

function locateDupes() {
	if [ ! -d "$1" ]; then
		echo "argument error: source entered is not a directory."
		echo
		exit 1
	fi

	echo -e "\n\nfind duplicates..."
	echo -e "this script will simply identify duplicate files within the directory argument.\n"

	echo -e "cleaning out old md5's.\nremoving:"
	rm -rfv $tempDir/*
	mkdir -p $tempDir
	sleep 1

	tput setaf 3
	echo -e "\ngenerating md5's..."
	find "$1" -type f | grep -v ".DS_St" | while read i; do
		md5 -r "$i" >>"$tempHashes"
	done

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

	echo -e "\ndone."
	# echo -e "\ndone.\ncreated file:$(tput setaf 2) ${report} $(tput sgr 0)which contains duplicate list for$(tput setaf 2) $1$(tput sgr 0)."
	echo
}

locateDupes "$srcDir"


function removeDupes() {
	cd $tempDir
	DIR=$(find . -maxdepth 1 -type d | cut -c 3-)
	echo -e "remove files from duplicate lists...\n"
	echo -e "Choose a working directory from the list: "
	select sourceDIR in $DIR; do
		if [[ -d $sourceDIR ]]; then
			echo -e "you selected $sourceDIR"
			break
		else
			echo -e "bad entry, please re-enter your selection."
		fi
	done
	cd $tempDir/$sourceDIR

	arr=($(ls -1))
	dupeCount=$(echo ${#arr[@]})
	counter=0
	echo -e "\nthere are $dupeCount hits.\n"

	while [[ $counter -lt $dupeCount ]]; do
		IFS=$'\n'
		srcFile=$(echo ${arr[$counter]})
		select kitty in $(awk '{ print }' $srcFile); do
			echo "you chose: $kitty"
			break
		done
		unset IFS
		if [[ -e "$kitty" ]]; then
			echo "$kitty exists"
			rm "$kitty"
		elif [[ "$kitty" == "Keep All" ]]; then
			echo -e "moving to next matched duplicate.\n"
		else
			echo "$kitty fail."
		fi
		((counter++))
	done
}

removeDupes

exit
