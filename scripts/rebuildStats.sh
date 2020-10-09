#!/usr/bin/env bash
nextRev=`ls -1 userGuide-newRevisions/ | head -n 1`
outFile=userGuide-structureDifferences.txt
if [ "$nextRev" == "" ]; then
    echo "No revision found, unable to calculate structure difference." >${outFile}
    exit
fi

# Get the structure of the localized document
python ../scripts/stats.py userGuide.t2t >localized.stats
# Get the structure of the next revision to be translated.
python ../scripts/stats.py userGuide-newRevisions/$nextRev/userGuide.t2t >next.stats
lang=$(basename `pwd`)

d_args=(-d --unchanged-line-format='' --old-line-format='en %L' --new-line-format="$lang %L")
sed_args=(
 # insert header line
 -e "1i# Structural comparison of ${lang}/userGuide.t2t against ${lang}/userGuide-newRevisions/$nextRev/userGuide.t2t"
 # delete lines that only have the language tag.
 -e "/\(en\|${lang}\)\s*$/d"
 # insert footer line
 -e '$a# end of comparison'
)

if ! diff -q "${d_args[@]}" next.stats localized.stats; then
    diff "${d_args[@]}" next.stats localized.stats | sort -V -s -k 2,2 | sed "${sed_args[@]}" >${outFile}
else
    echo -e "# Structural comparison of ${lang}/userGuide.t2t against ${lang}/userGuide-newRevisions/$nextRev/userGuide.t2t\n# files have identical structure" >${outFile}
fi

rm localized.stats next.stats
