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
