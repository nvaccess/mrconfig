#!/bin/bash
langs=(ar de es fi fr gl it ja nl pl pt_BR ta tr)
for lang in ${langs[*]}; do
cd $lang
python ~/srt-svn/scripts/stats.py
cd ug-diffs/4799
python ~/srt-svn/scripts/stats.py
~/srt-svn/remakeStats.sh $lang
cd ../../../
done

