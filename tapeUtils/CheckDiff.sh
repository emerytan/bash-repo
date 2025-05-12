#!/bin/bash
# compare two files md5sum output

clear
echo -e "comparing:"
echo -e "\t${1}"
echo -e "\t${2}"

diff <(cat "$1" | sort -k 2) <(cat "$2" | sort -k 2)

if [[ $? -eq "0" ]]; then
  echo -e "\nfiles are an exact match"
  echo -e "bye...\n"
fi

exit
