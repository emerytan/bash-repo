#!/bin/bash


inputFile="${1}"
filters="${2}"

if [ ${inputFile: -4} == ".ale" ] || [ ${inputFile: -4} == ".ALE" ]; then
	clear
	tput setaf 2
	echo -e "CO3 ALE parser\n"
	tput sgr0
else
	echo -e "Not and ALE file"
fi


if [ -z $2 ]; then
	echo -e "No filters"
	sleep 3
	awk 'BEGIN { FS="\t"; OFS="\t"; }  /^Name/ { for(i=1;i<NF;i++) { print i, $i } }' "$inputFile"
else
	echo -e "Filter: "$filters""
	sleep 5
	awk 'BEGIN { FS="\t"; OFS="\t"; }  /^Name/ { for(i=1;i<NF;i++) { print i, $i } }' "$inputFile" | \
		grep -Ei "$filters"
fi

exit

