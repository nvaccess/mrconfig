#!/usr/bin/env bash

# Called by convertOne.sh, with current directory set to SRT_PATH/<lang>

scriptsDir="../../scripts"
lang=$(basename `pwd`)

nextRev=`ls -1 changes-newRevisions/ | head -n 1`
if [ "$nextRev" == "" ]; then
    echo "No revision found, unable to calculate changes structure difference."
else
    python3 ${scriptsDir}/structDiffMd.py $lang changes-newRevisions/$nextRev/changes.md changes.md changes-structureDifferences.txt
fi

nextRev=`ls -1 userGuide-newRevisions/ | head -n 1`
if [ "$nextRev" == "" ]; then
    echo "No revision found, unable to calculate userGuide structure difference."
else
    python3 ${scriptsDir}/structDiffMd.py $lang userGuide-newRevisions/$nextRev/userGuide.md userGuide.md userGuide-structureDifferences.txt
fi

