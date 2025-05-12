#!/bin/bash


function check_error {
    echo -e "\nChecking "$2" for errors..."
    if [ $1 -ne 0 ]; then
        echo -e "\t"$2" failed with error code $1." >&2
    else
        echo -e "\tNo errors found in "$2"."
    fi
}