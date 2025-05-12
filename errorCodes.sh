#!/bin/bash

if [[ $? -eq 0 ]]; then
	echo -e "\n"
else
	echo -e "error at: " >&2
fi