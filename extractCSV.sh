#!/bin/bash
# extractCSV.sh

clear
masterCSV="/path/to/master.csv"
tocPath="/path/to/toc"
cd "$tocPath" && echo -e "good"

for tape in $(ls -1 tapes/ | sed 's/.txt//'); do 
	echo -e "filling tape: $tape"
	grep -e $tape $masterCSV | tee -a tapes/${tape}.txt
	echo -e "finished"
	sleep .5
	clear
done

echo -e "finished"
cd
exit
