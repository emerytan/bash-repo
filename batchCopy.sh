#!/bin/bash


pathPrefix="/path/to/your/directory" # Set your path prefix here
cd $pathPrefix
runFrom=$(pwd)

if [[ "$runFrom" != $pathPrefix ]]; then
    echo bad
    exit
else
    echo good
fi

while read data; do
    if [[ -f $pathPrefix/"$data" ]]; then
        echo -e "\n\tcopy "$data""
        cp -v "$data" "${2}"
    else
        echo "bogus "$data""
    fi
done <"${1}"

exit
