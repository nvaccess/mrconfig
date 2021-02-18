#!/usr/bin/env bash

getAbsPath() {
absPath=$(readlink -f -n $1)
absPath=$(dirname $absPath)
echo $absPath
}

# Checking for the existance of needed programs (sorted)

CURL=`which curl`
DIFF=`which diff`
#ELINKS=`which elinks`
MSGMERGE=`which msgmerge`
POCOUNT=`which pocount`
PYTHON38=`which python3.8`
SCONS=`which scons`
#TWIDGE=`which twidge`
WDIFF=`which wdiff`
XGETTEXT=`which xgettext`

if [ "$CURL" == "" ]; then
    echo "Can't find curl."
    exit 1
elif [ "$DIFF" == "" ]; then
    echo "diff not installed."
    exit 1
#elif [ "$ELINKS" == "" ]; then
#    echo "Can't find elinks."
#    exit 1
elif [ "$MSGMERGE" == "" ]; then
    echo "Can't find msgmerge."
    exit 1
elif [ "$POCOUNT" == "" ]; then
    echo "Can't find pocount."
    exit 1
elif [ "$PYTHON38" == "" ]; then
    echo "could not locate python 3.8, can not continue."
    exit 1
elif [ "$SCONS" == "" ]; then
    echo "could not locate scons, can not continue."
    exit 1
#elif [ "$TWIDGE" == "" ]; then
#    echo "twidge not installed."
#    exit 1
elif [ "$WDIFF" == "" ]; then
    echo "wdiff not installed."
    exit 1
elif [ "$XGETTEXT" == "" ]; then
    echo "Can't find xgettext."
    exit 1
fi

MYDIR=$(getAbsPath $0)
