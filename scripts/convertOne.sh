#!/bin/bash
set -u

# Called by webhook, with current directory set to SRT_PATH/<lang>

getAbsPath() {
absPath=$(readlink -f -n $1)
absPath=$(dirname $absPath)
echo $absPath
}

MYDIR=$(getAbsPath $0)

source "${MYDIR}/checkProgs.sh"
source "${MYDIR}/lock.sh"
result=0
lang=$(basename $(pwd))

encoding=`file *.md | grep -vP ': .*(ASCII text|UTF-8 text)'`
if [ "$encoding" != "" ]; then
    result=1
    echo $lang: File encoding problem in md file. Please save the following as Unicode UTF-8:
    echo "$encoding"
    echo
else
    if [ -f changes.md ]; then
        if ! output=$(python3 ${MYDIR}/md2html.py convert changes.md changes.html 2>&1); then
            result=3
            echo $lang: Error processing changes.md:
            echo "$output"
            echo
        fi
    else
        echo No changes.md
    fi

    if [ -f userGuide.md ]; then
        if ! output=$(python3 ${MYDIR}/md2html.py convert userGuide.md userGuide.html 2>&1); then
            result=4
            echo $lang: Error processing userGuide.md:
            echo "$output"
            echo
        fi
        if ! output=$(python3 ${MYDIR}/md2html.py convert userGuide.md keyCommands.html 2>&1); then
            result=5
            echo $lang: Error generating keyCommands.html from  userGuide.md:
            echo "$output"
            echo
        fi
    else
        echo No userGuide.md
    fi

    # Disabled for now
    # ${MYDIR}/rebuildStats.sh

    svn add -q *.html *.txt >& /dev/null
    mfiles=`svn status -q | awk '{printf(" %s", $2)}'`
    if [ "$mfiles" != "" ]; then
        svn commit -q -m "${lang}: updated $mfiles" $mfiles
    fi
fi

exit $result
