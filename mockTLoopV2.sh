#!/bin/bash

clear
echo -e "$(tput setaf 2)tape archive restore$(tput sgr 0)"


#global variables
TAPE="/dev/nst0"
mdRestorePath="/home/rgs/restore/tapeHeaders"
indexDest="/home/rgs/restore/bash"
destBase="/media/AmUltra_Source_1"


#get barcode and daily roll
echo -e -n "enter tape barcode: "
read bCode
echo -e -n "drop daily roll: "
read r1


#build REEL and DR variables by parsing /path/to/dailyRole/file.txt
REEL=`echo $r1 | grep -o "reel."`
if [ "$REEL" == "" ]
    then
	echo -e "bad entry.  exiting."
	exit 1
fi
dcSrcPath="/home/rgs/restore/parsedData/$REEL"
restorePath="$destBase/$REEL"
r1dr=`basename $r1`
drSrc="$dcSrcPath/$r1dr"
DR=`echo $r1dr | sed 's/.txt//'`
echo -e "$(tput setaf 2)----------------------------------------------$(tput sgr 0)\n\n"
#show results
echo -e "Reel Number:\t$REEL"
echo -e "Daily Roll:\t$DR"


#restore tape header
mkdir -p $mdRestorePath/$bCode
mt -f /dev/st0 rewind
tar -b 128 -xf $TAPE -C $mdRestorePath/$bCode
#error check
if [[ $? -eq 0 ]]
	then
		echo -e "got header\n"
	else
		echo -e "error at: getting header" >&2
fi
matchTape="$mdRestorePath/$bCode/archivingFiles"
mv $matchTape/ult* $matchTape/$bCode.txt &>/dev/null


#show user tapeHeader restore status # preview next step.
echo -e "$(tput setaf 2)restored header file:$(tput sgr 0)\t$(ls $matchTape) "
echo -e "\n$bCode tape header can be found at: ~/tapeHeaders/$bCode"
echo -e "$(tput setaf 2)----------------------------------------------$(tput sgr 0)\n\n"
echo -e "next step: get tarball indexes by filtering $bCode against $DR. "
echo -e -n "\nhit any key to proceed or press [control + c] to quit: "
read -n 1
echo -e "\n"


#code to match tape contents agains daily roll contents.
clipsPath="$indexDest/$bCode"
mkdir -p $clipsPath
rm -rf $clipsPath/*
cat $drSrc  | awk '{ print $3 }' | while read clip
	do
	cat $matchTape/* | grep $clip | awk '{ print $2 }' | sort -g -u >> $indexDest/$bCode/$clip.txt
	if [[ $? -eq 0 ]]
		then
		echo -e "tarball indexed without errors\n"
	else
		echo -e "error at: indexDest" >&2
fi
done
#error check
#remove invalid files from results of while loop
cd $clipsPath
ls -1 | while read srcFile
do empty=`cat $srcFile`
if [ "$empty" == "" ]
	then rm -f $srcFile
	fi
done
chown -R rgs:rgs $mdRestorePath
chown -R rgs:rgs $indexDest


#status update + preview next step.
echo -e "got the tarball indexes..."
echo -e "files located at:  ~/bash/$bCode"
echo -e "$(tput setaf 2)----------------------------------------------$(tput sgr 0)\n\n"

echo -e "next step: preview clips to be restored.\nSAN will be searched; this will take a couple minutes\nclips that have already been restored will be excluded."
echo -e -n "\nhit any key to proceed or press [control + c] to quit:  "
read -n 1
echo -e "\n"



#compare clips on restore queue against content of SAN.  Remove clips from que list if true.
searchBase="/media"
mkdir -p $clipsPath/restored
cd $clipsPath
find -maxdepth 1 -type f -name "*.txt" | sed 's/.\///g' | sed 's/.txt//g' | while read onSan
do
	restored=`grep -r $onSan /home/rgs/restore/bash/restoreLogs/`
	check=`echo $restored | grep -o $onSan`
	if [ "$onSan" == "$check" ]
		then
		let x=0
		else
		let x=1
	fi
	if [ "$x" == "0" ]
		then
		echo "$checkFiles has already been restored."
		mv -v $clipsPath/$onSan.txt $clipsPath/restored/$onSan.txt
		else
		echo -e "$checkFiles will be restored."
	fi
done
#error check
if [[ $? -eq 0 ]]
	then
	echo -e "checkFiles sucess\n"
	else
	echo -e "error at: checkFiles" >&2
fi


#show restore que, quit if nothing to be restored.
clear
cd $clipsPath
whereami=`pwd`
echo -e "\nto be restored: "
echo -e "$(find . -maxdepth 1 -name "*.txt" -type f | sort -n | sed 's/\.\///g' | sed 's/.txt//g') "
echo -e "\nto be excluded (already restored) "
echo -e "$(ls restored/ | sed 's/.txt//g') "
SKIP=`find . -maxdepth 1 -name "*.txt" -type f | sed 's/\.\///g' | sed 's/.txt//g'`
if [ "$SKIP" == "" ]
	then
	echo -e "\nnothing to restore.\nGet the next tape bitch."
	echo -e "\n"
	exit
fi
echo -e "\nrestore path: \t$restorePath"
echo -e "\nall set to go.  verification emails will be sent if restore completes without error."
echo -e -n "press any key to continue, press [control + c] to quit: "
read -n 1
echo -e "\n\n\n"
logPath="$indexDest/restoreLogs/$REEL/$DR"
mkdir -p $logPath
log="$logPath/$restoreLog_$bCode.txt"


# restore clips loop
for clips in $(find . -maxdepth 1 -name "*.txt" -type f | sort -n)
	do startIndex=`head -n 1 $clips`
	loopyC=`wc -l $clips | awk '{ print $1 }'`
	clipName=`echo $clips | sed 's/\.\///g' | sed 's/.txt//g'`
	echo -e "\nrestore info..."
	tput setaf 3
	echo -e "\tclip: $clipName"
	echo -e "\ttar index: $startIndex"
	echo -e "\tnumber of tarballs: $loopyC"
	tput sgr 0
	echo -e "\n\nshuttling tape to start of: $clipName"
	mt -f $TAPE asf $startIndex
	let count=1
	# tarball loop
	while (( count < $loopyC )); do
		tarTrack=$count
		echo -e "loop counter: $tarTrack of $loopyC"
		tput setaf $tarTrack
		tar -b 128 -xvf $TAPE -C $restorePath
		mt -f $TAPE fsf 1
		(( count ++ ))
	done
	#error check
	if [[ $? -eq 0 ]]
		then
		echo -e "\n\n\n$clipName restore successful\n\n\n"
		echo -e "$clipName restore successful" >> $log
		else
		echo -e "error tarLoop $clipName" >&2
		echo -e "error tarLoop $clipName" >> $log
		exit 1
		fi
	tput sgr 0
	cd $clipsPath
done
#post loop error check
if [[ $? -eq 0 ]]
	then
	echo -e "clipLoop success\n"
	else
	echo -e "error at: tarLoop" >&2
	echo -e "error at: tarLoop.\nreel:\t\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" jeff@postfactoryny.com
	echo -e "error at: tarLoop.\nreel:\t\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" terry@postfactoryny.com
	echo -e "error at: tarLoop.\nreel:\t\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" keenan@postfactoryny.com
	echo -e "error at: tarLoop.\nreel:\t\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" will@postfactoryny.com
	exit 1
fi


# clean up and exit
tput sgr 0
echo -e "rewinding and ejecting tape..."
mt -f $TAPE rewind
mt -f /dev/st0 eject
echo -e "restore complete.\nreel:\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | tee -a $log
echo -e "restore complete.\nreel:\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" jeff@postfactoryny.com
echo -e "restore complete.\nreel:\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" terry@postfactoryny.com
echo -e "restore complete.\nreel:\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" keenan@postfactoryny.com
echo -e "restore complete.\nreel:\t\t$REEL\nDaily Roll:\t$DR\ntape:\t\t$bCode\n\nHave a nice day." | mail -s "AM Ultra restore report" will@postfactoryny.com
exit
