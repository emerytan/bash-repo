#!/bin/bash

for data in $(find . -type f -name "*.md5" | grep backup2); do 
	orig=$(basename $data | sed 's/.md5//')
	pre=$(dirname $data)
	echo -e "orig: $data\t\tnew: ${pre}/${orig}_2.md5"
	mv -v $data ${pre}/${orig}_2.md
done


exit

