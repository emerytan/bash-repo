#!/bin/bash
#
# hashTape.sh
# loop md5 files into checksum then write restults to log files.



clear

# setup
sourcePath="$1"
hashBase=$(basename "$1")
hashPath="/home/$USER/verification"


# change to directory that's root for checksum listings
cd $sourcePath
currentDir=$(pwd)


# special function to fix seye md5 files 
function fixHash() {
	cd "$1"
	
	filePrefix=$(ls | grep md5 |  sed 's/.md5//')
	f2f=$(ls | grep md5)
	
	if (ls | grep orig); then
		echo -e "md5 file already been modified bruh."
		sleep 2
		exit
	else
		echo "first run"
		sleep 2
	fi
	
	echo -e "filePrefix: ${filePrefix}"
	echo -e "file2fix: $f2f"
	cp -v "$f2f" /tmp/eta/
	mv -v "$f2f" "${f2f}.orig"
	nFile=$(ls | grep orig)
	sed 's/\//\.\//' "$nFile" | cut -d"/" -f1,10- > "${filePrefix}.md5"
	head "${filePrefix}.md5"
	echo -e "done editing original md5 file..."
	echo -e "starting md5 hash in 5 seconds..."	
	sleep 5
}


if [[ $2 != "" ]] && [[ $2 == "sey" ]]; then
	echo -e "run special function"
	sleep 2  
	fixHash $sourcePath
else
	echo -e "no special function on this run"
	sleep 2 
fi


# outputs
beenHashed="${hashPath}/beenHashed"
hashLog="${hashPath}/hashLog"
cronLog="${hashPath}/cronLog/cronLog.txt"
#hashList="$sourcePath/hashSource"



# run the loop if we're in the right place.
if [ $sourcePath == $currentDir ]; then
	
	for data in $(ls "$sourcePath" | grep -E 'md5$')
	do
		tape="$data"
		tapeName=$(echo "$tape" | sed 's/.md5//')
		tapeLog="${hashLog}/${tapeName}.txt"

		
		echo -e "\n\nhash check runnin on ${data}....\n\n"
		
		if [[ -f $tapeLog ]]; then
			echo -e "removing previus log for ${tapeName}... " >> "$cronLog"
			rm -f ${tapeLog}
		fi
		
		START=$(date)
		echo -e "begin verification for "$tapeName" at ${START}" >> "$cronLog"
		echo -e "Tape Log:\t${tapeName}" >> ${tapeLog}
		echo -e "${tapeName} hashcheck started at: ${START}" >> "$tapeLog"
		echo -e "<-----------BEGIN----------->\n\n"  >> "$tapeLog"
		sleep 1
		
		md5sum -c --quiet "$tape" &>> "$tapeLog"

		if [ $? -eq 0 ]; then
			FINAL=$(date)
			echo -e "success: finished verification for "$tapeName" at ${FINAL}" >> "$cronLog"
			echo -e "\n<------------END------------>" >> "$tapeLog"			
			echo -e "verification success for "$tapeName" at ${FINAL}" >> "$tapeLog"
			echo -e "0" >> "$tapeLog"
			echo -e "0" > "$beenHashed/${tapeName}.txt"
		else
			FINAL=$(date)
			echo -e "error: verification errors on "$tapeName"" >> "$cronLog"
			echo -e "\n<------------END------------>" >> "$tapeLog"						
			echo -e "verification error on ${tapeName} at ${FINAL}" >> "$tapeLog"
			echo -e "1" >> "$tapeLog"			
			echo -e "1" > "$beenHashed/${tapeName}.txt"
		fi
	
	done

	# signify end of loop
	echo -e "${tapeName} done..." >> "$cronLog"

	exit
else
	echo -e "working directory not equal to sourceBase... aborting.\n\n"
	exit
fi

