#!/bin/bash
find ./ -mindepth 3 -maxdepth 3 -type d | grep "ch-diffs" |
grep "5197" | while read file; do
cp /tmp/diff.txt $file
done

