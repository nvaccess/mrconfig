# Common Issues

Descriptions for, and fixes for common issues with the translation system.

## No stable branch:
Cron email with message:
`Warning: this addon has no stable branch, aborting.`

The addon repo must have a branch called `stable`.

Docs: https://github.com/nvdaaddons/nvdaaddons.github.io/wiki/MakeAddonsTranslatable

Corresponding check for branch: `hasStableBranchOrDie` in `01_common.sh`

