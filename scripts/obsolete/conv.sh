#!/usr/bin/env bash

source checkProgs.sh

function usage() {
    echo "`basename $0` [-h]"
    echo "`basename $0`  <-f|-t>" [-l 'ar de fi']
    echo "    -h, (help) prints this help message."
    echo "    -l, (langs) process only the given languages"
}

langs=(ar)

while getopts hl: OPT; do
    case "$OPT" in
        (h) usage; exit 0;;
        (l) langs=($OPTARG) ;;
        (\?)
            # getopts issues an error message
            echo usage >&2
            exit 1
            ;;
    esac
done

stdout=
for lang in ${langs[*]}; do
    logfile=/tmp/${lang}.$$
    if [ "$stdout" != "" ]; then exec 1<&6; fi 
    exec 6<&1
    stdout=6
    exec > >(tee $logfile) 2>&1
    echo "processing $lang"
    # relative path from scripts directory to language directory.
    langOffset=../$lang

    if [ -e "${langOffset}/settings" ]; then
        source "${langOffset}/settings"
    else
        echo "warning: No settings file found, skipping."
        continue
    fi


    if [ "${t2t2html}" == "0" ]; then
        echo "  skipping, t2t2html=${t2t2html}"
        continue
    fi

    nowUtf8Problems=$(file ${langOffset}/*.t2t | grep -viP "utf-8|empty|ascii" | wc -l)
    nowUtf8ProblemsFiles="$(file ${langOffset}/*.t2t | grep -viP "utf-8|empty|ascii")"

    # check if we have an utf8 problem from previous run.
    if [ "${utf8Problems}" != "0" ] && [ "${utf8Problems}"  == "$nowUtf8Problems" ]; then
        echo "  nothing changed, skipping, utf8Problems=${utf8Problems}"
        continue
    fi

    sed -i -e "s/utf8Problems=\([0-9]*\)/utf8Problems=${nowUtf8Problems}/" "${langOffset}/settings"
    git add "${langOffset}/settings"

    if [ "${utf8Problems}"  != "$nowUtf8Problems" ] && [ "$nowUtf8Problems" != "0" ]; then
        echo "Files with encoding problem: $nowUtf8Problems"
        echo "$nowUtf8ProblemsFiles"
        git commit -F ${logfile}
        continue
    fi

    # change into language directory, to allow conversion tools to work.
    pushd $langOffset 2>&1 >/dev/null
    python ../scripts/stats.py
    $PYTHON27 ../scripts/keyCommandsDoc.py

    # process each t2t file individually to make it easier to spot errors in output.
    ls -1 *.t2t | while read file; do
        echo processing $file
        txt2tags -q $file
    done

    diff  --unchanged-line-format='' --old-line-format='en %L' --new-line-format="$lang %L" \
    ug-diffs/${LastFoundEnglishUGRev}/ug-stats.txt  ug-stats.txt |
    sed -e "s/$lang $//g" -e "s/^en $//g" | sort -V -s -k 2,2 |
    sed '/^\s*$/d' >ug-stats-diff.txt
    mfiles=`git status -s -uno | grep -i ".html$" | awk '{printf(" %s", $2)}'`
    mstats=`git status -s -uno | grep -i "ug\-stats\-diff.txt$" | awk '{printf(" %s", $2)}'`

    if [ "$mfiles" != "" ]; then git add $mfiles; fi
    if [ "$mstats" != "" ]; then git add $mstats ug-stats.txt; fi
    if [ "$mfiles" != "$mstats" ]; then
        msg="${lang}: updated $mfiles $mstats from t2t."
        git commit -q -m "$msg"
        #../scripts/commit.sh
    fi
    popd 2>&1 >/dev/null
done
echo "all done"
