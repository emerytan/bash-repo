#!/bin/bash

clear

tempBase=$(basename "$1" | sed 's/md5/txt/')
tempFile="/tmp/$tempBase"


if [ -e "$tempFile" ]; then
	echo "tempFile exists"
	rm "$tempFile"
	touch "$tempFile"
	echo -e "writing temp file to: ${tempFile}"
	sleep 5
else
	touch "$tempFile"
	echo -e "writing temp file to: ${tempFile}"
	sleep 5
fi

while read -r HASH FILE; do 
	if (! grep "$HASH" "$2"); then
		if (echo "$FILE" | grep -E 'txt$|md5$|orig$'); then
			echo -e "IGNORED"
		else	
			echo -e "${HASH} ${FILE}\tFAIL" | tee -a "$tempFile"
			sleep 2
		fi
	fi
done < "$1"


if [ -s "$tempFile" ]; then
	echo -e "\n\nFailed hash matches..."
	cat "$tempFile"
else
	echo -e "\n\nall checksums matched"
	echo -e "bye...\n"
fi

exit

