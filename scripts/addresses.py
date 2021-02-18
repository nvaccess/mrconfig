# -*- coding: utf-8 -*-
import sys
from email.mime.text import MIMEText
from email.utils import COMMASPACE, parseaddr
import smtplib
from addressData import addresses

FROM_ADDR = "noreply+nvdaL10n@nvaccess.org"
FROM_DISPLAY = "NVDA localisation <%s>" % FROM_ADDR


def email(rcpts, subject, body, includeAdmin=False):
    if includeAdmin:
        rcpts.extend(addresses['default']['email'])
    if not rcpts:
        return
    msg = MIMEText(body, _charset="utf8")
    msg["From"] = FROM_DISPLAY
    msg["To"] = COMMASPACE.join(rcpts)
    msg["Subject"] = subject
    smtp = smtplib.SMTP("localhost")
    smtp.sendmail(FROM_ADDR,
        [parseaddr(rcpt)[1] for rcpt in rcpts],
        msg.as_string())

if __name__ == "__main__" and len(sys.argv) >= 2:
    lang = sys.argv[1]
    if lang not in addresses:
        print("unable to find language: %s" %lang)
        sys.exit()
    # we were called from the webhook with lang, subject, body, so send email.
    if len(sys.argv) == 4:
        email(addresses[lang]['email'], sys.argv[2], sys.argv[3])
    # we were called by another script, with a lang code, spit out email addresses suitable for a commit message.
    elif len(sys.argv) == 2:
        print("\n".join(addresses[lang]['email']))
    else:
        print("dont know what to do.")
