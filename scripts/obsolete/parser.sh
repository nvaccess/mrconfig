#!/usr/bin/env bash

USAGE="Usage: `basename $0` [-hv] [-o arg] args"

direction=

# Parse command line options.
while getopts hvo:mn OPT; do
    case "$OPT" in
        (h) echo $USAGE; exit 0;;
        (v) echo "`basename $0`  version 0.1" ;;
        (o) OUTPUT_FILE=$OPTARG ;;
        (m) direction=m ;;
        (n) direction=n ;;
        (\?)
            # getopts issues an error message
            echo $USAGE >&2
            exit 1
            ;;
    esac
done

# Remove the switches we parsed above.
shift `expr $OPTIND - 1`
# We want at least one non-option argument. 
# Remove this block if you don't need it.
#if [ $# -eq 0 ]; then
#    echo $USAGE >&2
#    exit 1
#fi

# Access additional arguments as usual through 
# variables $@, $*, $1, $2, etc. or using this loop:
#for PARAM; do
#    echo $PARAM
#done



