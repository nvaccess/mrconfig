#!/bin/bash
xgettext -c --copyright-holder="NVDA Contributers" \
--package-name="NVDA" --package-version="main:4800" \
--msgid-bugs-address="nvda-translation@freelists.org" \
-o /tmp/out.po {,*/,*/*/}*.py
