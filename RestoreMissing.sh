#!/bin/bash

destBase="/media/AmUltra_Source_4"
clear
completedDir="/home/rgs/restore/bash/restoreLogs/restoreMissingFiles"

restoreMiss () {
awk '{ print $3, $1, $2 }' $1 | while read n reel clip; do
	if (( n != previous + 1 )); then
		echo -e "tarball: ${n}"
		echo -e "clip: $clip"
		echo -e "reel: ${reel}"
		echo -e "destination: $destBase/$reel"
		mt -f /dev/nst0 asf ${n}
		tar -b 128 -xvf /dev/nst0 -C $destBase/$reel
	else
		echo -e "tarball: ${n}"
		echo -e "clip: $clip"
		echo -e "reel: ${reel}"
		echo -e "destination: $destBase/$reel"
		mt -f /dev/nst0 fsf 1
		tar -b 128 -xvf /dev/nst0 -C $destBase/$reel
	fi
previous=$n
done
echo -e "rewinding and ejecting tape $1.\n" | mail -s "tape: $1 finished" jeff@postfactoryny.com
mt -f /dev/st0 rewind
mt -f /dev/st0 eject
}

restoreMiss $1

echo -e "moving source file to: $completedDir"
mv -v $1 $completedDir
echo -e "done... "
echo
exit