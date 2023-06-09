"""Utilities to check a gettext po file for errors.
@author: James Teh <jamie@nvaccess.org>
@copyright: 2014 NV Access Limited
@license: GNU General Public License version 2.0
"""

import sys
import codecs
import re
import subprocess
from typing import List, Optional

MSGFMT = "msgfmt"

class PoChecker(object):
	"""Checks a po file for errors not detected by msgfmt.
	This first runs msgfmt to check for syntax errors.
	It then checks for mismatched Python percent and brace interpolations.
	Construct an instance and call the L{check} method.
	"""

	FUZZY = "#, fuzzy"
	MSGID = "msgid"
	MSGID_PLURAL = "msgid_plural"
	MSGSTR = "msgstr"

	def __init__(self, po):
		"""Constructor.
		@param po: The path to the po file to check.
		@type po: basestring
		"""
		self._poPath = po
		self._po = codecs.open(po, "r", "UTF-8")
		self._string = None
		#: Error and warning messages.
		self.alerts: List[str] = []
		#: Whether there is a syntax error.
		#: @type: bool
		self.hasSyntaxError = False
		#: The number of warnings.
		#: @type: int
		self.warningCount = 0
		#: The number of errors.
		#: @type: int
		self.errorCount = 0

	def _addToString(self, line, startingCommand=None):
		if startingCommand:
			# Strip the command and the quotes.
			self._string = line[len(startingCommand) + 2:-1]
		else:
			# Strip the quotes.
			self._string += line[1:-1]

	def _finishString(self):
		string = self._string
		self._string = None
		return string

	def _messageAlert(self, alert, isError=True):
		if self._fuzzy:
			# Fuzzy messages don't get used, so this shouldn't be considered an error.
			isError = False
		if isError:
			self.errorCount += 1
		else:
			self.warningCount += 1
		if self._fuzzy:
			msgType = "Fuzzy message"
		else:
			msgType = "Message"
		self.alerts.append(u"{msgType} starting on line {lineNum}\n"
				'Original: "{msgid}"\n'
				'Translated: "{msgstr}"\n'
				"{alertType}: {alert}"
			.format(
				msgType=msgType,
				lineNum=self._messageLineNum,
				msgid=self._msgid,
				msgstr=self._msgstr[-1],
				alertType="Error" if isError else "Warning",
				alert=alert,
			))

	def _checkSyntax(self):
		p = subprocess.Popen((MSGFMT, "-o", "-", self._poPath),
			stdout=open("NUL:" if sys.platform == "win32" else "/dev/null", "w"),
			stderr=subprocess.PIPE,
			errors="UTF-8",
		)
		# https://docs.python.org/3.7/library/subprocess.html#subprocess.Popen.stderr
		#  If the encoding or errors arguments were specified or the universal_newlines argument was True,
		#  the stream is a text stream, otherwise it is a byte stream. If the stderr argument was not PIPE,
		#  this attribute is None.
		output = p.stderr.read()
		if p.wait() != 0:
			output = output.rstrip().replace("\r\n", "\n")
			self.alerts.append(output)
			self.hasSyntaxError = True
			self.errorCount = 1

	def _checkMessages(self):
		command = None
		self._msgid = None
		self._msgid_plural = None
		self._msgstr = None
		nextFuzzy = False
		self._fuzzy = False
		for lineNum, line in enumerate(self._po, 1):
			line = line.strip()
			if line.startswith(self.FUZZY):
				nextFuzzy = True
				continue
			elif line.startswith(self.MSGID) and not line.startswith(self.MSGID_PLURAL):
				# New message.
				if self._msgstr is not None:
					self._msgstr[-1] = self._finishString()
					# Check the message we just handled.
					self._checkMessage()
				command = self.MSGID
				start = command
				self._messageLineNum = lineNum
				self._fuzzy = nextFuzzy
				nextFuzzy = False
			elif line.startswith(self.MSGID_PLURAL):
				self._msgid = self._finishString()
				command = self.MSGID_PLURAL
				start = command				
			elif line.startswith(self.MSGSTR):
				self._handleMsgStrReaching(lastCommand=command)
				command = self.MSGSTR
				start = line[:line.find(' ')]
			elif line.startswith('"'):
				# Continuing a string.
				start = None
			else:
				# This line isn't of interest.
				continue
			self._addToString(line, startingCommand=start)
		if command == self.MSGSTR:
			# Handle the last message.
			self._msgstr[-1] = self._finishString()
			self._checkMessage()

	def _handleMsgStrReaching(self, lastCommand: str) -> None:
		"""Helper function used by _checkMessages to handle the required processing when reaching a line
		starting with "msgstr".
		@param lastCommand: the current command just before the msgstr line is reached.
		"""

		# Finish the string of the last command and check the message if it was an msgstr
		if lastCommand == self.MSGID:
			self._msgid = self._finishString()
		elif lastCommand == self.MSGID_PLURAL:
			self._msgid_plural = self._finishString()
		elif lastCommand == self.MSGSTR:
			self._msgstr[-1] = self._finishString()
			self._checkMessage()
		else:
			raise RuntimeError(f'Unexpected command before line {lineNum}: {lastCommand}')
	
		# For first msgstr create the msgstr list
		if lastCommand != self.MSGSTR:
			self._msgstr = []
	
		# Initiate the string for the current msgstr
		self._msgstr.append("")

	def check(self):
		"""Check the file.
		Once this returns, you can call L{getReport} to obtain a report.
		This method should not be called more than once.
		@return: C{True} if the file is okay, C{False} if there were problems.
		@rtype: bool
		"""
		self._checkSyntax()
		if self.alerts:
			return False
		self._checkMessages()
		if self.alerts:
			return False
		return True

	RE_UNNAMED_PERCENT = re.compile(r"(?<!%)%[.\d]*[a-zA-Z]")
	RE_NAMED_PERCENT = re.compile(r"(?<!%)%\([^(]+\)[.\d]*[a-zA-Z]")
	RE_FORMAT = re.compile(r"(?<!{){([^{}:]+):?[^{}]*}")

	def _getInterpolations(self, text):
		unnamedPercent = self.RE_UNNAMED_PERCENT.findall(text)
		namedPercent = set(self.RE_NAMED_PERCENT.findall(text))
		formats = set()
		for m in self.RE_FORMAT.finditer(text):
			if not m.group(1):
				self._messageAlert("Unspecified positional argument in brace format")
			formats.add(m.group(0))
		return unnamedPercent, namedPercent, formats

	def _formatInterpolations(self, unnamedPercent, namedPercent, formats):
		out = []
		if unnamedPercent:
			out.append("unnamed percent interpolations in this order: %s"
				% ", ".join(unnamedPercent))
		if namedPercent:
			out.append("these named percent interpolations: %s"
				% ", ".join(namedPercent))
		if formats:
			out.append("these brace format interpolations: %s"
				% ", ".join(formats))
		if not out:
			return "no interpolations"
		return "\n\tAnd ".join(out)

	def _checkMessage(self):
		idUnnamedPercent, idNamedPercent, idFormats = self._getInterpolations(self._msgid)
		if not self._msgstr[-1]:
			return
		strUnnamedPercent, strNamedPercent, strFormats = self._getInterpolations(self._msgstr[-1])
		error = False
		alerts = []
		if idUnnamedPercent != strUnnamedPercent:
			if idUnnamedPercent:
				alerts.append("unnamed percent interpolations differ")
				error = True
			else:
				alerts.append("unexpected presence of unnamed percent interpolations")
		if idNamedPercent - strNamedPercent:
			alerts.append("missing named percent interpolation")
		if strNamedPercent - idNamedPercent:
			if idNamedPercent:
				alerts.append("extra named percent interpolation")
				error = True
			else:
				alerts.append("unexpected presence of named percent interpolations")
		if idFormats - strFormats:
			alerts.append("missing brace format interpolation")
		if strFormats - idFormats:
			if idFormats:
				alerts.append("extra brace format interpolation")
				error = True
			else:
				alerts.append("unexpected presence of brace format interpolations")
		if alerts:
			self._messageAlert("%s\n"
					"Expected: %s\nGot: %s"
				% (", ".join(alerts),
					self._formatInterpolations(idUnnamedPercent, idNamedPercent, idFormats),
					self._formatInterpolations(strUnnamedPercent, strNamedPercent, strFormats)),
				isError=error)

	def getReport(self) -> Optional[str]:
		"""Get a text report about any errors or warnings.
		@return: The text or C{None} if there were no problems.
		"""
		if not self.alerts:
			return None
		report = "File %s: " % self._poPath
		if self.hasSyntaxError:
			report += "syntax error"
		else:
			if self.errorCount:
				report += "%d %s" % (self.errorCount,
					"error" if self.errorCount == 1 else "errors")
			if self.warningCount:
				if self.errorCount:
					report += ", "
				report += "%d %s" % (self.warningCount,
					"warning" if self.warningCount == 1 else "warnings")
		report += "\n\n" + "\n\n".join(self.alerts)
		return report


def main():
	if len(sys.argv) <= 1:
		sys.exit("Usage: %s poFile ...")
	exitCode = 0
	for fn in sys.argv[1:]:
		c = PoChecker(fn)
		if not c.check():
			report = c.getReport() + "\n\n"
			print(report.encode("UTF-8"))
		if c.errorCount > 0:
			exitCode = 1
	return exitCode


if __name__ == "__main__":
	sys.exit(main())
