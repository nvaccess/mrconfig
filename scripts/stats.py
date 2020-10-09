#!/usr/bin/python
import re
import sys
import txt2tags

# regexps for matching t2t section headings
nheader = re.compile(r'(\++)(.*?)(\++.*)')
unheader = re.compile(r'(\=+)(.*?)(\=+.*)')

f = open(sys.argv[1])
lines = f.readlines()
f.close()

## line endings, make sure we dont include any configs
# give headings line numbers.
for i in range(len(lines)):
    lines[i] = lines[i].rstrip()
    if lines[i].startswith("%!include"):
        lines[i] = "% " + lines[i]; continue
    m = nheader.match(lines[i])
    if m: bits = m.groups(); lines[i] = bits[0] + " %d" %(i+1) + bits[1] + bits[2]; continue
    n = unheader.match(lines[i])
    if n: bits = n.groups(); lines[i] = bits[0] + " %d" %(i+1) + bits[1] + bits[2]; continue

## convert our lines to html
config = txt2tags.ConfigMaster()._get_defaults()
config['target'] = 'html'
tmplines, toc = txt2tags.convert(lines, config)

# Sometimes lines are returned with \n in them, so make sure each list
# item is one exact line.
rlines = []
for i in tmplines:
    rlines.extend(i.split('\n'))

## get the stats
info = []
newSec = re.compile('\<H[0-9]>(?P<id>([0-9]+\.)+)\s+(?P<ln>([0-9]+))')
pars = 0
tables = 0
lists = 0
id = ''
ln = 0
for i in range(len(rlines)):
    if rlines[i].startswith("<P>"):
        pars +=1; continue
    if rlines[i].startswith("<TABLE "):
        tables +=1; continue
    if rlines[i].startswith("<OL>") or rlines[i].startswith("<UL>"):
        lists +=1; continue
    PnewSec = newSec.match(rlines[i])
    if PnewSec:
        if id:
            info.append((id, ln, pars, tables, lists))
        pars = 0; tables = 0; lists = 0
        id = PnewSec.groupdict()['id']
        ln = PnewSec.groupdict()['ln']

# make sure to add the last section info.
if id:
    info.append((id, ln, pars, tables, lists))
    pars = 0; tables = 0; lists = 0

for i in info:
    print("%s start:%s paragraphs:%d, tables:%d, lists:%d\n\n" %(i[0],i[1], i[2], i[3], i[4] ))
