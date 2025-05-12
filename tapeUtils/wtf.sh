#!/bin/bash
# read md5 file & compare to live checksum output from find.
# testing file... 

diff <(cat $1 | sort -k 2   cut -d" " -f 1) <(find $2 -type f -print0 | xargs -0 md5sum | cut -d" " -f1)


clear
cd "$2" || exit
pwd 
sleep 5

while read -r hash longp; do 
  thisFile=$(basename "$longp")
  echo "$hash ./files/$thisFile" | md5sum -c -
done < $1 

exit
