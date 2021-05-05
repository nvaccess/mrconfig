#!/usr/bin/python3

import os.path
import sys
from io import StringIO
from datetime import datetime
from translate.storage import statsdb

# Called by cron, with current directory set to mr/scripts

SRT_ROOT = "../srt"

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
	date = datetime.now().strftime("%Y-%b-%d %H:%M")
	out = StringIO()
	out.write(f"""<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
	<META NAME="generator" CONTENT="postatus.py">
	<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
	<TITLE>po file status - {date}</TITLE>
</HEAD><BODY>
	<H1>po file status - {date}</H1>
""")
	stats = statsdb.StatsCache()
	webPoFiles = listWebPoFiles()
	for lang in listLangs():
		out.write(
			f'<br/><H2>{lang}</H2><br/>\n'
			'<table>\n'
			'<tr><th>Filename</th>'
			'<th>Percentage translated</th>'
			'<th>Total number of messages</th>'
			'</tr>\n'
		)
		for po in listPoFiles(lang, webPoFiles):
			path = os.path.join(SRT_ROOT, po)
			try:
				totals = stats.filetotals(path)
			except Exception as e:
				sys.stderr.write(f"Unable to load {path}: {e}")
				raise e
			total = totals["total"]
			if total:
				transPercent = totals["translated"] / float(totals["total"]) * 100
			else:
				transPercent = 0.0
			out.write(
				f"<tr><td>{po.replace('/', '&#47;')}</td>"
				f"<td>{transPercent:.2f}%</td>"
				f"<td>{totals['total']}</td>"
				f"</tr>\n"
			)
		out.write('</table>\n')
	out.write('</BODY></HTML>\n')
	return out.getvalue()

if __name__ == "__main__":
	print(makeReport())
