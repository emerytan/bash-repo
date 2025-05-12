#!/bin/bash
# load multidrive library tape to drive

clear

if [[ ! $1 ]] || [[ ! $2 ]]; then
  echo "you must enter the slot number, then the drive number"
  echo -e "exiting"
  exit
else
  echo -e "loading element ${1} to drive ${2}"
fi

#mtx -f /dev/sg3 load $1 $2
