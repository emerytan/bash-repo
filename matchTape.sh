#!/bin/bash
# 
# matchTape.sh
# parse tape TOC then match results to filesystem
# 
# echo -e -n "Drop tape file: "
# read tape

tape=$1
tapeName=$(basename $tape | sed 's/.txt//')
tapesListingFull="path/to/tapes/tableofcontents"
tapeTOCfull="${tapesListingFull}/${tapeName}.txt"

clear

if [[ -e $tapeTOCfull ]]; then
	echo -e -n "\nremoving previus ${tapeName}... "
	rm -f $tapeTOCfull
	echo -e "creating ${tapeName} file."
	touch $tapeTOCfull
else
	echo -e "creating ${tapeName} file."
	touch $tapeTOCfull
fi


if [[ -f $tapeTOCfull ]]; then
	echo -e "\ngood to go."
fi


if [ -f $tape ]; then 
	echo "tape: $tapeName"
	sleep 3
	awk -F, '{ print $1, $2, $3, $4, $5, $6, $7 }' $tape | while read barcode prefix path suffix A B pad; do
			if [ -z $A ] || [ ${A} == 0 ] || [ ${B} == 0 ]; then
				echo "${path}/${prefix}${suffix}" | tee -a $tapeTOCfull 
			else
				for i in $(seq -w $A $B); do 
					echo "${path}/${prefix}0${i}${suffix}" | tee -a $tapeTOCfull
				done
			fi
  done
fi

