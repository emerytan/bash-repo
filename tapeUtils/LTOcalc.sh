#!/bin/bash

clear 
sleep 1
tput setaf 4
echo -e "\nGet Direcrtory Sizes...\n"
tput sgr 0

basePath="$1"
jobName="$2"
outPath="/home/$USER/billables"


cd $basePath

projectBase=$(basename $PWD)
mkdir -p  "$outPath/$projectBase"

logFile="$outPath/$projectBase/${jobName}.txt"
if [[ -e "$logFile" ]]; then
	rm -fv "$logFile"
	touch "$logFile"
else
	touch "$logFile"
fi


tput setaf 7
echo -e "\nproject Base:\t\t"$projectBase""
echo -e "results file:\t\t"$logFile""
echo -e "starting...\n"
sleep 2
tput sgr 0

du -sb * | while read sze dir
do 
	echo -e "directory: $dir\tbillable: $(expr ${sze} / 1000000000)" | tee -a "$logFile"
done

exit

