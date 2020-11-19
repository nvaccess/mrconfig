#!/usr/bin/env bash

printFileHeader() {
echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
echo '<HTML><HEAD>'
echo '<META NAME="generator" CONTENT="postatus.sh">'
echo '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">'
echo "<TITLE>po file status - $(date) </TITLE>"
echo '</HEAD><BODY>'
echo "<H1>po file status - $(date)</H1>"
}

printLangHeader() {
    lang=$1
    echo "<br/><H2>${lang}</H2><br/>"
    echo "<table><tr><th>Filename</th><th>Percentage translated</th><th>Total number of messages</th></tr>"
}

printLangFooter() {
    echo "</table>"
}

printFileFooter() {
echo '</BODY></HTML>'
}

function printRow() {
file=$1
pocount --csv $file | tail -n 1 | awk -F, '{print $1.$2.$9}' |
sed -e 's+\.\./++g' -e 's+/+\&#47;+g' |
awk '{printf("<tr><td>%s</td><td>%.2f%%</td><td>%d</td></tr>\n", $1, ($3==0)?0:($2/$3*100), $3)}'
}

printFileHeader
for lang in ../*/nvda.po; do
lang=`cut -d / -f 2 <<< $lang`
printLangHeader $lang
find ../${lang}/ -iname "*.po" | sort | while read file; do
printRow $file
done
find ../website/ -iname "*.${lang}.po" | sort | while read file; do
printRow $file
done
printLangFooter
done
printFileFooter
