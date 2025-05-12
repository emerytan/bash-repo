#!/bin/bash

if [[ -f "${1}" ]]; then
	clear
	echo -e "batchFind source file present"
else
	echo -e "\nno batchFind source file...\n"
	exit
fi

sleep 3

searchBase="${2}"
cd $searchBase


if [[ -e bResults.txt ]]; then
	echo -e "removing old results..."
	rm bResults.txt
fi

echo "making results file..."
touch bResults.txt
sleep 3

currentDir=$(pwd)

if [[ "${currentDir}" != "${searchBase}" ]]; then
	echo -e "\nError: current directory is not search path.\n"
	exit
else
	echo -e "search base path is valid..."
fi

echo -e "starting in 5 seconds..."
sleep 5

while read data
    do echo -e "\nFIND: "${data}"" | tee -a bResults.txt
    find . -iname "${data}"\* | tee -a bResults.txt
    echo -e "----- done searching -----\n" | tee -a bResults.txt
done < "${1}"


exit

