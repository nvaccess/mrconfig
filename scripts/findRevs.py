#!/usr/bin/env python
import argparse
import os, re, sys
import logging
from pprint import pprint, pformat
from db import DB
from plumbum.cmd import echo, grep, head, ls, msgfmt, pocount, sed, tail, mkdir, cat, wdiff
from plumbum import local
from repo import Repo

logging.basicConfig(filename='findRevs.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s')

parser = argparse.ArgumentParser(description='language processor.')
#parser.add_argument('--type', required=True, choices=('ug', 'ch', 'sy'))
parser.add_argument('--langs', nargs='+', required=True)
args = parser.parse_args()

r = Repo('../../mainNVDACode/.git')
tbpath = local.path('../')
linfo = {
    'changes': {
        'filename': 'changes.t2t',
        'srcpath': 'user_docs/en/changes.t2t',
        'dstprefix': 'changes-newRevisions',
    },
    'userGuide': {
        'filename': 'userGuide.t2t',
        'srcpath': 'user_docs/en/userGuide.t2t',
        'dstprefix': 'userGuide-newRevisions',
    },
    'symbols': {
        'filename': 'symbols.dic',
        'srcpath': 'source/locale/en/symbols.dic',
        'dstprefix': 'symbols-newRevisions',
    }
}
_wdiff = wdiff['-w', '-{', '-x', '}-', '-y', '+{', '-z', '}+', '-d']
for lang in args.langs:
    try:
        mySettings = DB(tbpath.join(lang).join('settings')._path)
    except:
        continue
    logging.debug(pformat(mySettings))
    branch = mySettings['nvda.branch']
    for key in linfo:
        logging.info('Processing {key}'.format(key=key))
        prevhash=mySettings["nvda.{key}.lastFoundHash".format(key=key)]
        if not prevhash:
            logging.info('prevhash not found, skipping')
            continue
        rl = r.getHashChangesSince(prevhash, branch, linfo[key]['srcpath'])
        if not rl:
            logging.info('No new revisions to be processed')
            continue
        allRevs = r.getRevList(branch)
        print "revisions that needs processing: %d" % len(rl)
        for hash in rl:
            index = allRevs.index(hash)
            print("%d" %index)
            mkdirpath = tbpath.join(lang).join(linfo[key]['dstprefix']).join(index)
            mkdir['-p', mkdirpath._path]()
            diffText = r.getDiffBetween(prevhash, hash, linfo[key]['srcpath'])
            ((cat << diffText) > mkdirpath.join('differences.txt')._path)()
            ((_wdiff << diffText) > mkdirpath.join('wordDifferences.txt')._path)(retcode=[0, 1])
            fileText = r.getFileAt(hash, linfo[key]['srcpath'])
            ((cat << fileText) > mkdirpath.join(linfo[key]['filename'])._path)()
            logText = r.getLogAt(hash)
            ((cat << logText) > mkdirpath.join('log.txt')._path)()

            prevhash = hash

        mySettings["nvda.{key}.lastFoundHash".format(key=key)] = prevhash
        mySettings.save()

logging.debug('End of run.')
