#!/bin/bash

clear
echo -e "$(tput setaf 2)Post Factory NY - restore check$(tput sgr 0)"
REEL="reel1"
TAPE="/dev/nst0"
mdRestorePath="/home/rgs/restore/tapeHeaders"
dcSrcPath="/home/rgs/restore/parsedData/$REEL"
indexDest="/home/rgs/restore/bash"
destBase="/media/AmUltra_Source_1"
restorePath="/media/AmUltra_Source_1/$REEL"

echo -e -n "enter tape barcode: "
read bCode

echo -e -n "drop daily roll: "
read r1
r1dr=`basename $r1`
drSrc="$dcSrcPath/$r1dr"
DR=`echo $r1dr | sed 's/.txt//'`

mkdir -p $mdRestorePath/$bCode
# mt -f /dev/st0 rewind
# tar -b 128 -xf $TAPE -C $mdRestorePath/$bCode
matchTape="$mdRestorePath/$bCode/archivingFiles"

echo -e "\nDaily Roll: $DR"
echo -e "$(tput setaf 2)header file:$(tput sgr 0)\t\t$(ls $matchTape) "
echo -e "$(tput setaf 2)matching against:$(tput sgr 0) \t$drSrc"
echo -e -n "\nhit any key to continue or press [control + c] to quit: "
read -n 1
echo -e "\n"

clipsPath="$indexDest/$bCode"

# mkdir -p $clipsPath
# rm -rf $clipsPath/*
cat $drSrc  | awk '{ print $3 }' | while read clip
	do
	cat $matchTape/* | grep $clip | awk '{ print $2 }' | sort -g -u >> $indexDest/$bCode/$clip.txt
done

cd $clipsPath
ls -1 | while read srcFile
do empty=`cat $srcFile`
	if [ "$empty" == "" ]
		then rm -f $srcFile
		fi
done

chown -R rgs:rgs $mdRestorePath
chown -R rgs:rgs $indexDest

echo -e "\n\ngot the tarball indexes needed to restore this tape....\n\n"
echo -e -n "hit any key to see list of clips to be restored: "
read -n 1

cd $clipsPath
ls -1 | while read onSAN
do
	checkFiles=`echo $onSAN | sed 's/.txt//g'`
	exists=`find $destBase -name $checkFiles`
	if [ "$checkFiles" != "" ]
		then echo "$checkFiles has already been restored."
		mkdir -p $clipsPath/restored
		mv $onSAN $clipsPath/restored/$onSAN
	fi
done

clear

cd $clipsPath
whereami=`pwd`
echo -e "\nbasis of restore: "
echo -e "$(ls -1 $clipsPath) "
echo -e "\nrestore path: \t$restorePath"
echo -e -n "\nany key to quit: "
read -n 1
exit

# start of tape loop
# ls | while read clips
# 	do startIndex=`head -n 1 $clips`
# 	loopyC=`wc -l $clips | awk '{ print $1 }'`

# 	# show variable
# 	echo -e "\nrestore info..."
# 	tput setaf 3
# 	echo -e "\tclip: $clips"
# 	echo -e "\ttar index: $startIndex"
# 	echo -e "\tnumber of tarballs: $loopyC"
# 	tput sgr 0

# 	echo -e "\n\nshuttling tape to start of: $clips"
# 	mt -f $TAPE asf $startIndex
# 	mt -f $TAPE status

# 	let count=0
# 	while (( count < $loopyC )); do
# 	#statements
# 		tarTrack=`expr $count + 1`
# 		echo -e "loop counter: $tarTrack"
# 		tput setaf $tarTrack
# 		mt -f $TAPE status
# 		tar -b 128 -xvf $TAPE -C $restorePath
# 		mt -f $TAPE fsf 1
# 		echo -e "Next tar file..."
# 		(( count ++ ))
# 	done
# 	echo -e "\n\n\n\nfinished $clips\n\n\n\n\n" | figlet
# 	tput sgr 0
# 	cd $clipsPath
# done
# tput sgr 0
# echo -e "rewinding and ejecting tape..."

# mt -f $TAPE rewind
# mt -f /dev/st0 eject

# logPath="$indexDest/restoreLogs"
# mkdir -p $logPath/$REEL
# echo -e "finished \t$REEL, \t$DR, tape: \t$bCode" >> $logPath/$REEL.txt
# echo "$REEL barcode: $bCode finished!" | figlet
# exit


# ls -1 $clipsPath | sed 's/.txt//g' | while read checkFiles
# do find $destBase -name $checkFiles
# done