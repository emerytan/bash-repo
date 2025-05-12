#!/bin/bash
# use imagemagick to merge a dirtmap with a film scan
# includes progress bar
# usage: MergeDirt.sh <source-image-path> <source-dirtmap-path> <output-path>

sourceImagePath="$1"
sourceDMPath="$2"
destPath="$3"

echo "$PWD"
cd "$PWD" || exit


userArgs() {
    clear
    echo -e "\n\nargument error on source image path.  directory does not extist\n"
    echo -e "command arguments as follows..."
    echo -e "\tMergeDirt.sh ...source-images-path ...source-dirt-map-path ...output-path"
    echo -e "\npaths must be directories containing the image sequence to be used..."
    echo -e "all three paths must be included when running the command\n"
}

tempFile="/tmp/mergeDirt.txt"

clearTempFile() {
    rm -fv $tempFile
}

if [[ ! -d "$sourceImagePath" ]]; then
    userArgs
    exit
fi


if [[ ! -d "$sourceDMPath" ]]; then
    userArgs
    exit
fi


if [[ ! -d "$destPath" ]]; then 
    userArgs    
    exit
fi

clear

tput setaf 2
echo -e "MergeDirt.sh"
echo -e "simple imagemagick utility to batch merge film scans with their IR dirt maps\n"
tput sgr0
echo -e "\tsource image path: $sourceImagePath"
echo -e "\tsource dirt map path: $sourceDMPath"
echo -e "\toutput path: $destPath"
echo -e "\nchecking image path for dpx files..."
ls "$sourceImagePath" | grep dpx >> $tempFile
if [[ $? = "0" ]]; then
    srcImageCount=$(ls "$sourceImagePath" | grep dpx | wc -l)
    echo -e "\tsource image count: ${srcImageCount}"
else
    echo -e "\n\nno dpx files in the source image container"
    echo -e "exiting..."
    clearTempFile
    exit
fi
 

echo -e "\nchecking dirtmap path for dpx files..."
ls "$sourceDMPath" | grep dpx >> $tempFile
if [[ $? = "0" ]]; then
    srcDMcount=$(ls "$sourceDMPath" | grep dpx | wc -l)
    echo -e "\tsource dirtmap count: ${srcDMcount}"
else
    echo -e "\n\nno dpx files in the source image container"
    echo -e "exiting..."
    clearTempFile 
    exit
fi


if [ "${srcImageCount}" -eq "${srcDMcount}" ]; then
    echo -e "\n\timage and dirtmap file counts match."
else
    echo -e "\timage and dirtmap file counts do not match..."
    echo -e "\tyou can proceed but there will be errors"
fi


echo -e -n "\npress 'y' to proceed.  Any other key to quit.  "
read CONF
if [[ "$CONF" != "y" ]]; then
    echo -e "\nexiting...\n"
    exit
fi


echo -e "\n\nhere we go..."
sleep 2

count=0
total=${srcImageCount}
pstr="[=======================================================================]"
for i in $(ls "$sourceImagePath" | grep dpx | sort); do 
    convert "$sourceImagePath"/"${i}" \( "$sourceDMPath"/"${i}" -negate \) -compose copy_opacity -composite -set colorspace Log \
    "$destPath"/embedded_"${i}"
    count=$(( $count + 1 ))
    pd=$(( $count * 73 / $total ))
    printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total )) $(( ($count * 1000 / $total) % 10 )) "$pstr"
done 

echo -e "\nall done...\n"

exit
