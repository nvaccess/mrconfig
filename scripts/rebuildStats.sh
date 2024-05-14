#!/usr/bin/env bash

# Called by convertOne.sh, with current directory set to SRT_PATH/<lang>

nextRev=`ls -1 userGuide-newRevisions/ | head -n 1`
if [ "$nextRev" == "" ]; then
    echo "No revision found, unable to calculate structure difference." >${outFile}
    exit
fi

scriptsDir="../../scripts"
lang=$(basename `pwd`)

python3 ${scriptsDir}/structDiffMd.py $lang userGuide.md userGuide-newRevisions/$nextRev/userGuide.md userGuide-structureDifferences.txt
