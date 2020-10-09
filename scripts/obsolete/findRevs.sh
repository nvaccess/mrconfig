#!/bin/bash

# make sure that the programs that we need are available
source checkProgs.sh
source lock.sh

reset() {
    echo "Resetting to a clean state."
    git reset --hard HEAD
}

grabLock

# variables which will be used later
# to construct a complete commit message for the svn.
msg=""
helperMsg=""

# function that takes 1 arg, and converts relative to absolute path
# store in global var $absPath
function getAbsPath() {
  absPath=`readlink -f -n $1`
}

# function that finds new revisions given:
# lang: the languageCode (directory name)
# fpath: the bzr file path of the file to be checked.
# fname: the bzr filename of the file to be checked, such as changes.t2t userGuide.t2t symbols.dic
# diffsDir: name of directory where diffs should be stored (svn) ch-diffs, sy-diffs, ug-diffs.
function findRevs() {
  lang=$1
  fpath=$2
  diffsDir=$3
  fname=$4

  echo "processing $lang: $fname"
  startRev=`ls -1 ${lang}/$diffsDir/ | tail -n 1`
  if [ "$startRev" == "disabled" ] || [ "$startRev" == "" ]; then
    echo "skipped."
    return
  fi
  #echo "my startRev is: $startRev"
  newRevs=`bzr log -r${startRev}.. $BZRDIR/$fpath/$fname | grep -P "^revno: [0-9]+" | sort | sed '1 d' | awk '{printf("%d ", $2)}'`
  echo "revs to be processed: $newRevs"
  prevRev=$startRev
  revCounter=0
  newRevs=($newRevs)
  for rev in ${newRevs[*]}; do
    #echo "processing $rev"
    mkdir -p $lang/$diffsDir/$rev
    bzr log -r$rev $BZRDIR/$fpath/$fname > $lang/$diffsDir/$rev/log.txt
    bzr cat -r$rev $BZRDIR/$fpath/$fname > $lang/$diffsDir/$rev/$fname
    bzr diff -r$prevRev..$rev $BZRDIR/$fpath/$fname > $lang/$diffsDir/$rev/diff.txt
    bzr diff -r$prevRev..$rev $BZRDIR/$fpath/$fname |
    $WDIFF -w '-{' -x '}-' -y '+{' -z '}+' -d |
    sed -e 's/-{/\n-{/g' -e 's/}-/}-\n/g' \
      -e 's/+{/\n+{/g' -e 's/}+/}+\n/g' > $lang/$diffsDir/$rev/wdiff.txt
    if [ "$diffsDir" == "ug-diffs" ]; then
      pushd $lang/$diffsDir/$rev/ >/dev/null
      python ../../../scripts/stats.py
      # update ug-stats-diff at the same time
      diff  --unchanged-line-format='' --old-line-format='en %L' --new-line-format="$lang %L" \
        ug-stats.txt ../../ug-stats.txt |
      sed -e "s/$lang $//g" -e "s/^en $//g" | sort -V -s -k 2,2 | 
      sed '/^\s*$/d' >../../ug-stats-diff.txt
      git add ../../ug-stats-diff.txt
      popd >/dev/null
    fi
    git add $lang/$diffsDir/$rev
    revCounter=$(($revCounter+1))
    prevRev=$rev
  done
  if [ "$revCounter" != "0" ]; then
    helperMsg="$revCounter in $diffsDir (${newRevs[*]}), "
  else
    helperMsg=''
  fi
}



## config
newRevs=

# make sure we have the latest repo from assembla.
git reset --hard HEAD
git svn rebase

# go to relative dir that has bzr code:
getAbsPath ../
pushd $absPath 2>&1 >/dev/null
BZRDIR=../code/translation
pushd $BZRDIR
bzr pull -q
popd

declare -A twitAddr
twitAddr[ar]="@nvdauser"
twitAddr[de]="@bdorer1"
twitAddr[sk]="@pvagner"

for lang in ${findRevLangs[*]}; do
  echo "processing $lang"
  helperMsg=""
  findRevs $lang user_docs/en/ ch-diffs changes.t2t
  msgP1="$helperMsg"; helperMsg=""
  findRevs $lang user_docs/en/ ug-diffs userGuide.t2t
  msgP2="$helperMsg"; helperMsg=""
  findRevs $lang source/locale/en/ sy-diffs symbols.dic
  msgP3="$helperMsg"; helperMsg=""

  newMsg="${msgP1}${msgP2}${msgP3}"
  if [ "$newMsg" != "" ]; then
    #twidge update "${twitAddr[$lang]} $lang: new revision(s) for translation: $newMsg"
    msg="${msg}${lang}: ${newMsg}\n"
  fi
done

popd >/dev/null
echo -e "New revs to translate\n\n$msg" | git commit -F -

./commit.sh
