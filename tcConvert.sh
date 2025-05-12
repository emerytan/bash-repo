#!/bin/bash

fps=24



echo "what is the reading of smpte hours:"
read hr
hrmin=$(echo "scale=4; $hr*60.0" | bc)
hrsec=$(echo "scale=4; $hrmin*60.0" | bc)
hrfps=$(echo "scale=4; $hrsec*$fps" | bc)

echo "what is the reading of smpte minutes:"
read min
minsec=$(echo "scale=4; $min*60.0" | bc)
minfps=$(echo "scale=4; $minsec*$fps" | bc)

echo "what is the reading of smpte seconds:"
read sec
secfps=$(echo "scale=4; $sec*$fps" | bc)

echo "what is the reading of smpte frames:"
read fr

toto=$(echo "scale=2; $hrfps+$minfps+$secfps+$fr" | bc)

echo "total frames are" $toto
