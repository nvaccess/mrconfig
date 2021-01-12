# Common Issues

Descriptions for, and fixes for common issues with the translation system.

## No stable branch:
Cron email with message:
`Warning: this addon has no stable branch, aborting.`

The addon repo must have a branch called `stable`.

Docs: https://github.com/nvdaaddons/nvdaaddons.github.io/wiki/MakeAddonsTranslatable

Corresponding check for branch: `hasStableBranchOrDie` in `01_common.sh`


### Missing po file:

Cron email with message:
```
<lang ID> wants <addon name>: 1
Already available for translation, merging in new messages.
translate.tools.pocount: ERROR: cannot process <lang ID>/add-ons/<addon name>/nvda.po: does not exist
translate.tools.pocount: ERROR: cannot process <lang ID>/add-ons/<addon name>/nvda.po: does not exist
msgmerge: error while opening "<lang ID>/add-ons/<addon name>/nvda.po" for reading: No such file or directory
```

The po file is missing. Perhaps it was deleted accidentally or the translator decided they would not translate for the add-on.

Scripts are being updated to handle this case. The file will be re-added. If the translator no longer wants to work on this add-on, the settings file should be updated to reflect that instead. 


### Addon removed from addonFiles

Cron email with message:
```
/bin/sh: 1: cd: can't cd to /home/nvdal10n/mr/addons/<addon name>
```

Check if the `available.d/10_<addon name>` file has been removed but the entry in `automatic.crontab` was not removed.
To fix, remove the entry from `automatic.crontab`.

Check if the case of the repo `/home/nvdal10n/mr/addons/<addon name>` matches the entry in `automatic.crontab`, if not fix the case.

### Missing 'msgstr' section

Cron email with message:
```
Already available for translation, merging in new messages.
<lang>/add-ons/<addon name>/nvda.po:66: missing 'msgstr' section
msgmerge: found 1 fatal error
```
An entry in the file (at the line specified) is missing the msgstr section.
To fix this add an empty string for the msgstr.
EG:
```
#. Translators: the tooltip text for a menu item.
msgid "Shows a dictionary dialog to customize emoticons"
msgstr ""
```
This needs to be done in the SRT repository.
