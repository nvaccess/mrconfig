## Overview
The `mrconfig` tool attempts to provide an abstraction for working with various version control systems.
This repository has extended it and also uses it to run various scripts related to building translation files, providing diffs and statistics about translations and notifying translators.

Generally, cron jobs trigger when different scripts are run. See `crontab.automatic` which has an entry to cause cron to be updated based on this file.
When a commit is made to the SRT (Screen reader translations) repo, a webhook is run. 

The `.mrconfig` file exposes functions from the scripts:
- isAddon
- addon2svn 
- addon2settings
- svn2addon

The file `available.d/15_srt` (imported by `.mrconfig` via `include = cat $(dirname $MR_CONFIG)/enabled.d
/[0-9]*`) exposes the following commands :
- findRevs (defined in `.sh.d/01_nvda2svn.sh`)
- mergePot (defined in `.sh.d/01_nvda2svn.sh`)
- svn2nvda (defined in `.sh.d/01_svn2nvda.sh`)

## High level process
The following steps are triggered by a cron job every Friday:
- `mr up`: updates all the repositories.
- `mr svn2nvda`: Updates NVDA with the latest translations from SRT
- `mr mergePot`: Merge POT file into each language PO file on SRT
- `mr findRevs`: Create diffs for t2t files.

These are all run in the `/home/nvdal10n/mr/srt` directory.

When a commit is made to SRT, a webhook is run which:
- Calls `scripts/webhook`
- Updates the local copy of the SRT repo
- Checks settings / po / t2t files for errors
- Potentially updates the addon website
- Notifies translators of errors.
- See [assembla webhook docs](https://articles.assembla.com/en/articles/748141-post-information-to-external-systems-using-webhooks)
- See nginx config: `publicServer/conf/nginx/sites-available/nvda`

## Code entry points
The following are the entry points to the translations system ccode:
- via cron
  - mr svn2nvda
  - mr mergePot
  - mr findRevs
  - poStatus.py
  - mr addon2svn
  - mr svn2addon
- via assembla webhook
 - python scripts/webhook

## Notifications
When a crontab command fails an email is sent to the nvdal10n account.
Which is forwarded to the addresses listed in `~/.forward`

## Add-ons
Addon repositories are cloned due to the `available.d/10_<addon name>` file being symlinked (on the nvaccess server) from the `enabled.d` directory. They are cloned to `~/mr/addons`.
- The addon repositories are updated and used to generate a `*.pot` file to merge with translations in the `SRT` repository.

### Translating a new add-on
Although outdated the following gives an overview: https://github.com/nvdaaddons/nvdaaddons.github.io/wiki/MakeAddonsTranslatable

Now:
- The addon must have a public repository on [`nvdaaddons`](https://github.com/nvdaaddons/).
- The addon must have a branch named `stable`.
  - Author merges code here when stable and ready to receive translations. 
  - Translations (po files) are pushed here.
- Admins on NV Access server register the add-on and commit settings for translators.
  - `sudo su nvdal10n` 
  - `cd ~/mr`
  - `mr up`
  - `cd available.d`
  - `mr registerAddon <addon repo name>`
  - `git push`
  - `cd ~/mr`
  - `mr up`
  - `cd addons/<addon repo name>`
  - `mr addon2settings`
  - `cd ~/mr/srt`
  - `svn commit */settings -m "Make <addon name> add-on available for translation."`
- add entry to `automatic.crontab`
