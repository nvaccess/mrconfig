#!/bin/bash
export PS4='$LINENO+ '
set -eu

source checkProgs.sh
source lock.sh

reset() {
    echo "Resetting to a clean state."
    git reset --hard HEAD
}

grabLock

force=""
if [ "$#" == "1" ] && [ "$1" == "--force" ]; then
force="--force"
fi

commitMsg=""

#snapUrl='https://nvda.sourceforge.net/snapshots/.index.html'
#url=`$ELINKS --dump $snapUrl | grep -i '.pot' | head -n 1 | awk '{ print \$2 }'`
## if the content of the var end in pot then we have the url.
#exist="${url##*.}"
#if [ "$exist" != "pot" ]; then
#    echo "$0: Could not find po file on website."
#    exit
#fi
#$CURL -s -o $LOCKDIR/nvda.pot $url

BZRDIR=../code/translation/source

# Navigate to the base of the svn repo.
absPath=`readlink -f -n $0`
absPath=`dirname $absPath`
pushd ${absPath}/../ >/dev/null 2>&1

pushd $BZRDIR 2>&1 # >/dev/null 2>&1

bzr pull
rev=`bzr log -l 1 | head -n 2 | tail -n 1 | awk '{print $2}'`
branch=`bzr info | grep "checkout of branch" | awk -F/ '{print $NF}'`
fromdos {,*/,*/*/}*.py
xgettext --no-location -c -s --copyright-holder="NVDA Contributers" \
--package-name="NVDA" --package-version="$branch:$rev" \
--msgid-bugs-address="nvda-translations@freelists.org" \
--keyword=pgettext:1c,2 \
-o $LOCKDIR/nvda.pot {,*/,*/*/}*.py
bzr revert

popd # >/dev/null 2>&1

for lang in ${updatePoLangs[*]}; do
    echo "processing $lang"
    cd $lang

    # restore nvda.po in case of modifications and pull from server.
    #
    git checkout -f nvda.po

    # finding statistics before updating against pot file.
    #
    bfuzzy=`$POCOUNT nvda.po | grep -i fuzzy | awk '{print \$2}'`
    buntranslated=`$POCOUNT nvda.po | grep -i untranslated | awk '{print \$2}'`
    bmsg="$bfuzzy fuzzy and $buntranslated untranslated"

    # update po file from downloaded pot
    #
    #echo "updating po from pot."
    $MSGMERGE -q -U nvda.po $LOCKDIR/nvda.pot
    sed -e "s/\(project-id-version: \)\(.*\)/\1NVDA bzr $branch:$rev\\\n\"/i" -i nvda.po
    # finding statistics after updating against pot file.
    #
    afuzzy=`$POCOUNT nvda.po | grep -i fuzzy | awk '{print \$2}'`
    auntranslated=`$POCOUNT nvda.po | grep -i untranslated | awk '{print \$2}'`
    amsg="$afuzzy fuzzy and $auntranslated untranslated"

    # checking if we need to do anything
    #
    if [ "$bmsg" == "$amsg" ] && [ "$force" == "" ]; then
        # nothing has changed, dont need to action.
        # revert because comments in po file might have changed.
        #
        git checkout -f nvda.po
        #echo "nvda.po file is up to date, nothing to do."
    else
        # need to commit, because before and after are diffrent.
        #
        commitMsg="${commitMsg}${lang}: before: ${bmsg}, now: ${amsg}
"
       git add nvda.po
        #echo "$0 ${lang}: nvda.po has been updated from pot."
    fi
    cd ..
done

popd >/dev/null 2>&1 

#rev=${url##*/}
#rev=`echo "$rev" | grep -o -P "[0-9]+"`
git commit -q -m "Merging in messages from rev${rev} into nvda.po

$commitMsg"
./commit.sh
