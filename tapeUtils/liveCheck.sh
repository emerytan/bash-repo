#!/bin/bash
# usage: ./liveCheck.sh <hashFile> <restored files> <outPath>

origHash="$1"
baseDir="$2"
outPath="$3"
jobRef=$(basename "${1}" | sed 's/.md5//')
outFile="$outPath/${jobRef}_restoreHash.md5"
kern=$(uname)
CHKSUM=""

if [[ $kern = "Darwin" ]]; then 
    CHKSUM="md5 -r"
fi

if [[ $kern = "Linux" ]]; then
    CHKSUM="md5sum"
fi

if [ -e "$outFile" ]; then
    echo -e "removing old temp file..."
    rm -v "$outFile" || exit 1
    touch "$outFile" || exit 1
else
    echo -e "creating temp file...\n"
    touch "$outFile" || exit 1
fi

echo -e "hashFile: $origHash" 1>&2
echo -e "outFile: $outFile" 1>&2

cd "$baseDir" || exit 1

lineCount=$(wc -l "$origHash" | awk '{ print $1 }')
echo -e "lines: $lineCount"
count=0
while read -r FILE; do
    (( count ++ ))
    FL=$(basename "$FILE")
    find . -type f -name "$FL" -print0 | xargs -0 $CHKSUM | tee -a "$outFile"
    echo -e "count: $count"
done < "$origHash"

exit
