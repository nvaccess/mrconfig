#!/usr/bin/python

import os.path
from cStringIO import StringIO
from translate.storage import statsdb

SRT_ROOT = ".."

def listLangs():
	langs = []
	for lang in os.listdir(SRT_ROOT):
		if os.path.isfile(os.path.join(SRT_ROOT, lang, "nvda.po")):
			langs.append(lang)
	langs.sort()
	return langs

def listWebPoFiles():
	poFiles = []
	for path, dirNames, fileNames in os.walk(os.path.join(SRT_ROOT, "website")):
		for fileName in fileNames:
			if fileName.endswith(".po"):
					poFiles.append(os.path.relpath(os.path.join(path, fileName), SRT_ROOT))
	# Case insensitive sort.
	poFiles.sort(key=lambda item: item.lower())
	return poFiles

def listPoFiles(lang, webPoFiles):
	poFiles = []
	for path, dirNames, fileNames in os.walk(os.path.join(SRT_ROOT, lang)):
		for fileName in fileNames:
			if fileName.endswith(".po"):
				poFiles.append(os.path.relpath(os.path.join(path, fileName), SRT_ROOT))
	# Case insensitive sort.
	poFiles.sort(key=lambda item: item.lower())
	for po in poFiles:
		yield po
	# We want website files to appear after other files, even if the language name sorts after website.
	# For example, zh_TW/nvda.po should appear before zh_TW's website files.
	for po in webPoFiles:
		if po.endswith(".%s.po" % lang):
			yield po

def makeReport():
	out = StringIO()
	out.write('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">\n'
		'<HTML><HEAD>\n'
		'<META NAME="generator" CONTENT="postatus.py">\n'
		'<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">\n'
		'<TITLE>po file status - {date}</TITLE>\n'
		'</HEAD><BODY>\n'
		'<H1>po file status - {date}</H1>\n'
	)
	stats = statsdb.StatsCache()
	webPoFiles = listWebPoFiles()
	for lang in listLangs():
		out.write('<br/><H2>{lang}</H2><br/>\n'
			'<table><tr><th>Filename</th><th>Percentage translated</th><th>Total number of messages</th></tr>\n'
			.format(lang=lang))
		for po in listPoFiles(lang, webPoFiles):
			path = os.path.join(SRT_ROOT, po)
			totals = stats.filetotals(path)
			total = totals["total"]
			if total:
				transPercent = totals["translated"] / float(totals["total"]) * 100
			else:
				transPercent = 0.0
			out.write("<tr><td>{po}</td><td>{transPercent:.2f}%</td><td>{total}</td></tr>\n"
				.format(po=po.replace("/", "&#47;"), transPercent=transPercent,
					total=totals["total"]))
		out.write('</table>\n')
	out.write('</BODY></HTML>\n')
	return out.getvalue()

if __name__ == "__main__":
	print(makeReport())
