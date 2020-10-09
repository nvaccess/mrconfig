#!/bin/bash
set -u

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

encoding=`file *.t2t  | grep -vP ': +(HTML document, )?(ASCII text|UTF-8|empty)'`
if [ "$encoding" != "" ]; then
    result=1
    echo $lang: File encoding problem in t2t file. Please save the following as Unicode UTF-8:
    echo "$encoding"
    echo
else
    if ! output=$($PYTHON27 ${MYDIR}/keyCommandsDoc.py 2>&1); then
        result=2
        echo "$lang: Error generating Key Commands document from User Guide: $output"
        echo
    fi

    # process each t2t file individually to make it easier to spot errors in output.
    for file in *.t2t; do
        if ! output=$(txt2tags -q $file 2>&1); then
            result=3
            echo $lang: Error processing $file:
            echo "$output"
            echo
        fi
    done

    ${MYDIR}/rebuildStats.sh

    rm -f keyCommands.t2t


    svn add -q *.html *.txt >& /dev/null
    mfiles=`svn status -q | awk '{printf(" %s", $2)}'`
    if [ "$mfiles" != "" ]; then
        svn commit -q -m "${lang}: updated $mfiles" $mfiles
    fi
fi

exit $result
