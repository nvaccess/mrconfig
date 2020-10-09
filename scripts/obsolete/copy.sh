#!/usr/bin/env bash
find ./ -iname "5606" | grep "ug-diffs" | while read file; do
#n=`echo "$file" | sed 's/5606/5608/g'`
cp /tmp/ug-stats.txt ${file}/
#svn mv "$file" "$n"
done
