#!/bin/bash
#
# hashTape.sh
# parse get first 5 tape listings from ls command, then checksum against contents
# write results, etc...
#
# written: 22-may-2017
#

sourcePath="/path/to/backup"
# sourcePath="/home/$USER/verification"
hashPath="${sourcePath}/md5Check"
hashFile="${hashPath}/noTab_MD5/"
beenHashed="${hashPath}/beenHashed"
hashOutput="${hashPath}/hashOutput"
hashPass="${hashPath}/hashPass"
hashFail="${hashPath}/hashFail"
hashLog="${hashPath}/hashLog"
cronLog="${hashPath}/cronLog/cronLog.txt"

cd $sourcePath
currentDir=$(pwd)

if [ $sourcePath == $currentDir ]; then
	ls ${hashFile} | head -n 8 >> ${cronLog}
	START=$(date)
	echo "Starting... ${START}" >> ${cronLog}
    	relPath="md5Check/noTab_MD5"
	for tape in $(ls ${hashFile} | head -n 8); do
        	tapeName=$(basename $tape | sed 's/.md5//')
        	tapeLog="${hashLog}/${tapeName}.txt"
			tapeOutput="${hashOutput}/${tapeName}.txt"
			tapePass="${hashPass}/${tapeName}.txt"
        	tapeFail="${hashFail}/${tapeName}.txt"

		if [[ ! -e ${tapeLog} ]]; then
			touch ${tapeLog}
		fi

		echo -e "Paths for tape:\t${tape}" >> ${tapeLog}
		echo -e "stdout err:\t${tapeOutput}" >> ${tapeLog}
		echo -e "Tape Log:\t${tapeLog}" >> ${tapeLog}
		echo -e "Tape Fail:\t${tapeFail}" >> ${tapeLog}

		if [[ -e $tapeOutput ]]; then
			echo -e -n "\nremoving previus ${tapeName}... " >> ${tapeLog}
			rm -f ${tapeOutput}
			touch ${tapeOutput}
		else
			touch ${tapeOutput}
		fi

		if [[ -f $tapeOutput ]]; then
			DATE=$(date)
			echo -e "${tape} hashcheck started at: "$DATE"" >> $tapeLog
			echo -e "\n<-----------BEGIN----------->\n\n"  >> ${tapeLog}
		fi

		md5sum -c --quiet "${relPath}/${tape}" &> ${tapeOutput}
        
		OUT=$(cat ${tapeOutput} | wc -l)
		END=$(date)
		if [[ $OUT == "0" ]]; then
        		echo -e "\n\nPASS" >> ${tapeLog}
			echo -e "\n\n${tape} is done at:\t"$END"\n<-----------END----------->\n\n" >> ${tapeLog} 
			mv ${tapeOutput} ${hashPass}
		else
        		cat ${tapeOutput} >> ${tapeLog}
	    		echo -e "\n\nFAIL" >> ${tapeLog}                
            		echo -e "\n\n${tape} is done at:\t"$END"\n<-----------END----------->\n\n" >> ${tapeLog} 
            		mv ${tapeOutput} ${hashFail}
		fi
	
		mv "${relPath}/${tape}" "${beenHashed}/${tape}"	
	
		done
else
	echo -e "working directory not equal to sourceBase... aborting.\n\n"
	exit 1
fi


FINAL=$(date)
echo -e "Finished... ${FINAL}\n\n\n" >> ${cronLog}

exit
