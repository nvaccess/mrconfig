# Structure difference
# Copyright (C) 2024 Cyrille Bougot, NV Access Limited
# This file is covered by the GNU General Public License.

"""A script to check the structure of NVDA's documentation files in markdown format.
This script checks line by line if the locale version matches the English one and prints the errors found.
If no error is found, nothing is printed on the output.
"""


import sys
import os
import re

# Set to True to check blank at end of line. It is currently disabled due to the high number of diffs in 
# the change log (French)
CHECK_TAILING_SPACES = False

CHECK_CODE_FORMATTING = True


def structDiff(enFile, localeFile):
	output = []
	with open(enFile, encoding="utf8") as f1, open(localeFile, encoding="utf8") as f2:
		for (nLine, (enLine, locLine)) in enumerate(zip(f1, f2)):
			err = compareLines(enLine, locLine)
			if err is not None:
				output.append(f'Line {nLine+1}: {err}')
				output.append(f'English = {repr(enLine)}')
				output.append(f'Locale = {repr(locLine)}')
			err = compareLineContents(enLine, locLine)
			if err is not None:
				output.append(f'Line {nLine+1}: {err}')
				output.append(f'English = {repr(enLine)}')
				output.append(f'Locale = {repr(locLine)}')
	return "\n".join(output)


# A regexp matching any line of the file
RE_LINE = """
	^
	(  # Tags
		<!--\ 
		KC:(
			(title:\ NVDA\ NVDA_VERSION\ ([^-](?!->))+)
			|(beginInclude)
			|(endInclude)
			|(settingsSection:\ ([^-](?!->))+)
			|(setting)
		)\ -->
	)
	|(
		# Blank at the beginning of the line
		(?P<headingSpaces>[ \t]*(?![ \t]))
		(
			# Headings
			((?P<preHeading>[#]+)\ [^{]+(?P<anchor>\ \{[^}]+\})?)
			# Bullet items in list: begins with "* " or "1. "
			|(
				(?P<bullet>(\*|(1\.))\ )
				(.+)
			)
			# Table row
			|(\|(?P<tableCells>([^|]*\|)+))
			# Other text: do not begin with "#", "|", "*", "<" or "1. ".
			|(?P<normalText>([^#|*<1]|(1(?!\.\ ))).*)
		)
		# Blank at the end of the line
		(?P<tailingSpaces>(?<![ \t])[ \t]*)
	)
	$
"""
RE_LINE = re.compile(RE_LINE, re.VERBOSE)

# A regexp matching an link to an anchor in the document.
RE_ANCHOR_LINK = re.compile(r'\[[^]]+\]\(#(?P<anchor>[^)]+)\)')
RE_CODE_FORMATTING_DELIMITER = re.compile(r'(?<!`)`(?!`)')

def compareLines(l1, l2):
	"""Compare the structure of two lines and returns an appropriate error message if a difference is found.
	If no structural difference is found, returns None.
	"""
	if l1 == l2:
		return None
	if l1.endswith('\n'): l1 = l1[:-1]	
	if l2.endswith('\n'): l2 = l2[:-1]	
	m1 = RE_LINE.match(l1)
	m2 = RE_LINE.match(l2)
	if not m1 or not m2:
		return 'No match'
	if m1['headingSpaces'] != m2['headingSpaces']:
		return 'No same heading spaces'
	if m1['preHeading'] != m2['preHeading']:
		return 'No same heading level'
	if m1['anchor'] != m2['anchor']:
		return 'No same anchor'
	if m1['bullet'] != m2['bullet']:
		return f'''No same bullet ("{m1['bullet']}" / "{m2['bullet']}")'''
	nPipe1 = m1['tableCells'].count('|') if m1['tableCells'] else 0
	nPipe2 = m2['tableCells'].count('|') if m2['tableCells'] else 0
	if nPipe1 != nPipe2:
		return f'No same table celll number ({nPipe1} / {nPipe2})'
	if CHECK_TAILING_SPACES and m1['tailingSpaces'] != m2['tailingSpaces']:
		return 'No same blank characters at the end of the line'
	
	return None


def compareLineContents(l1, l2):
	"""Compare the content of two lines and returns an appropriate error message if a difference is found.
	The content being compared is:
	- the anchor links
	- the presence of code formatting
	"""
	if l1.endswith('\n'): l1 = l1[:-1]	
	if l2.endswith('\n'): l2 = l2[:-1]	
	f1 = RE_ANCHOR_LINK.findall(l1)
	f2 = RE_ANCHOR_LINK.findall(l2)
	if set(f1) != set(f2):
		return 'No same anchor(s)'
	if CHECK_CODE_FORMATTING:
		n1 = len(RE_CODE_FORMATTING_DELIMITER.findall(l1))
		n2 = len(RE_CODE_FORMATTING_DELIMITER.findall(l2))
		if n1 != n2:
			return f'No same number of code formatting delimiters (`): {n1} / {n2}'
	return None

if __name__ == '__main__':
	locale = sys.argv[1]
	enFile = sys.argv[2]
	transFile = sys.argv[3]
	baseName = os.path.basename(transFile)
	outFile = sys.argv[4]
	print(f"Comparing {locale} {baseName} against English:")
	output = structDiff(enFile, transFile)
	if output:
		print(f"Differences found. Written to {outFile}")
		open(outFile, 'w').write(output)
	else:
		print("No differences found")
		open(outFile, 'w').write("No differences found")
