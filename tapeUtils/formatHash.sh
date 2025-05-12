#!/bin/bash

clear
outPath="/tmp/eta"
sourceFile="$1"
outFile="${outPath}/$(basename $1 | sed 's/.md5/.txt/')"
echo $outFile
sleep 1



if [ ! -e $outPath ]; then
	echo -e "making temp dir: $outPath"
	mkdir -p $outPath
else
	echo -e "output files are written to $outPath"
fi

if [ -e "$outFile" ]; then
	rm -rfv "$outFile"
fi



count=0
lines=$(wc -l "$sourceFile" | awk '{ print $1 }')
echo -e "lines: $lines"
sleep 1

sort -k 2 "$sourceFile" | while read hash org; do 
	(( count ++ ))
	FILE=$(basename $org)
	echo -e "count: ${count}"
	echo -e "hash: $hash    ${FILE}"
	echo -e "${hash} ${FILE}" >> "$outFile"
done

exit

