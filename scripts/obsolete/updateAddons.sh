#!/usr/bin/env bash
export PS4='$LINENO+ '
set -eu

source checkProgs.sh
source lock.sh

function translatedMsgs () {
pocount  --csv $1 | awk -F,   '{printf("%d\n", $2);}' | tail -n 1
}

function msgCount() {
pocount  --csv  "$1" |
awk -F, '{printf("untranslated:%d, fuzzy:%d\n",$7, $5)}' | tail -n 1
}

function usage() {
    echo "`basename $0` [-h]"
    echo "`basename $0`  <-f|-t>" [-l 'ar de fi']
    echo "    -h, (help) prints this help message."
    echo "    -f, (fromTranslators) copies files fromTranslators to vcs"
    echo "    -t, (toVcs) copies/merges files from vcs to translators"
    echo "    -l, (langs) process only the given languages"
    echo "    -a, (addons) process only the given addons"
}

langs=(am an ar bg cs da de el es fa fi fr gl hr hu is it ja ko nb_NO ne nl nn_NO pl pt_BR pt_PT ru sk sl sv ta tr uk zh_CN zh_HK zh_TW)
fromTranslators=""
toTranslators=""

while getopts a:fhtl: OPT; do
    case "$OPT" in
        (h) usage; exit 0;;
        (f) fromTranslators=1 ;;
        (t) toTranslators=1 ;;
        (l) langs=($OPTARG) ;;
        (a) availableAddons=($OPTARG) ;;
        (\?)
            # getopts issues an error message
            echo usage >&2
            exit 1
            ;;
    esac
done


if [ "$fromTranslators" == "$toTranslators" -a "$fromTranslators" == "" ]; then
    echo "error: need either '-f' fromTranslators, or -t, toTranslators"
    usage; exit 1
elif  [ "$fromTranslators" == "$toTranslators" -a "$fromTranslators" == "1" ]; then
    echo "error: '-f' and '-t' are mutually exclusive."
    usage; exit 1
fi

reset() {
    echo "Resetting to a clean state."
    git reset --hard HEAD
}

grabLock

# make sure we have the latest repo from assembla.
git reset --hard HEAD
git svn rebase

addonOffset="../../addons/"
if [ "$toTranslators"  == "1" ]; then
    # go through all addons and generate their pot files, place them in our temp dir.
    for addon in ${availableAddons[*]}; do
        pushd "${addonOffset}/${addon}" >/dev/null 2>&1
        pwd
        git pull -q --ff-only
        scons -Q pot mergePot
        mv *.pot $LOCKDIR
        popd >/dev/null 2>&1
    done
fi

for lang in ${langs[*]}; do
    echo "processing ${lang}:"
    # relative path from scripts directory to language directory.
    langOffset=../$lang
    if [ -e "${langOffset}/settings" ]; then
        source "${langOffset}/settings"
    else
        echo "warning: No settings file found, skipping."
        continue
    fi
    for addon in ${availableAddons[*]}; do
        eval process=\$${addon}
        if [ "$process" == "0" ]; then
            #echo -n " skipping:$addon"
            continue
        fi
        if [ "$fromTranslators" == "1" ]; then
            srcPo="${langOffset}/add-ons/${addon}/nvda.po"
            targetPo="${addonOffset}/${addon}/addon/locale/${lang}/LC_MESSAGES/nvda.po"
            #echo "  checking nvda.po:"
            count=$(translatedMsgs "$srcPo")
            msgfmt  -c -o $LOCKDIR/tmp.mo "$srcPo"
            if [ "$?" == "0" -a "$count" != "0" ]; then
                #echo "  copying across nvda.po"
                mkdir -p "${addonOffset}/${addon}/addon/locale/${lang}/LC_MESSAGES"
                cp "$srcPo" "$targetPo"
            fi
            #echo -n " ${addon}"
        else
            srcPo="${langOffset}/add-ons/${addon}/nvda.po"
            potFile="${LOCKDIR}/${addon}.pot"
            mergePotFile="${LOCKDIR}/${addon}-merge.pot"
            mkdir -p "${langOffset}/add-ons/${addon}/"
            if [ ! -e $srcPo ]; then
                cp "${potFile}" "${srcPo}"
                sed -i -e 's+"Content-Type: text/plain.*"+"Content-Type: text/plain; charset=UTF-8\\n"+g' \
                -e "s/^\"Language:\ /\"Language:${lang}/g" "${srcPo}"
                git add "${langOffset}/add-ons/${addon}/"
            fi
            msgmerge -qU "${srcPo}" "${mergePotFile}"
            git add "${srcPo}"
            #echo -n " ${addon}"
        fi
    done
done
#echo -e "\nall done"
git commit -m "updated addon po files."
./commit.sh
