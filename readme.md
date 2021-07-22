# mrconfig

(manage repo configuration) mrconfig

Used to manage translation updates for NVDA and NVDA add-ons.

## Addon website
For information on having add-ons added to the nvda-addons website:
https://github.com/nvaccess/addonFiles#readme

## Translating your addon

### Steps for addon authors

1. The add-on repo must contain a branch named `stable`.
   The translation system uses the `stable` branch to sending/receiving translation updates
   to/from [NVDA translation repo](http://subversion.assembla.com/svn/screenReaderTranslations).
2. Ask for the add-on to be included in the translation system via the [NVDA add-ons mailing list](https://nvda-addons.groups.io/g/nvda-addons).
   - A member of the NVDA add-on team creates a repo for the add-on at
	 [NVDA Addons GitHub](https://github.com/nvdaaddons)
   - The member of the NVDA add-on team should confirm there is a branch `stable`
   - `nvaccessAuto` should have permission to push to the `stable` branch.
3. Create an issue on [nvaccess/mrconfig](https://github.com/nvaccess/mrconfig) asking for the addon to be included.
   - NV Access staff will update the server:
	 - `cd mr`
	 - `mr up`
	 - `cd available.d`
	 - `mr registerAddon addonRepoName`
	 - `git push`
	 - `cd ../` (mr dir)
	 - `mr up`
	 - `cd addons/<addonRepoName>`
	 - `git checkout stable` (if there is an error, see `docs/commonIssues.md`)
	 - `mr addon2settings`
	 - `cd ../../srt`
	 - `svn commit */settings -m "Make <addonName> add-on available for translation."`
   - NV Access staff will edit `mr/automatic.crontab`
	 - Copy one of the lines for one of the existing addons, just change the addon name and paste it in the correct section, commit and push.
	 - Note: Run line from crontab manually to confirm.

### Maintaining the add-on

Note: Maintainers may follow other procedures.
This info is provided for convenience, according to discussions like this
[topic about repos management](https://nvda-addons.groups.io/g/nvda-addons/message/9418).

- Clone the maintainer repo:
	- `git clone https://github.com/githubUserName/addonRepoName`
- Add remote for GitHub/nvdaaddons repo:
	- `git remote add nvdaaddons https://github.com/nvdaaddons/addonRepoName`
- Fetch the GitHub/nvdaaddons repo:
	- `git fetch nvdaaddons`
- Track the stable branch:
	- `git checkout -t nvdaadons/stable`
- Periodically:
	- From stable branch:
		- `git pull` # Get translations
		- `git merge master` # Stable code containing translatable messages
		- `git push nvdaaddons stable`
	- From master:
		- `git pull`
		- `git merge stable`
		- `git push origin master` # Update translations

#### References for maintainers

- [Push to multiple repos in one step](https://gist.githubusercontent.com/bjmiller121/f93cd974ff709d2b968f/raw/8f17c4d72ba8bd36aea0ec0cf344a8197fa648e8/multiple-push-urls.md)
- [Book about Git](https://git-scm.com/book)

### Related links

- [Adding a New Language to Ikiwiki](https://github.com/nvaccess/l10n-code/wiki/Adding-a-New-Language-to-Ikiwiki)
- [mr documentation](https://www.systutorials.com/docs/linux/man/1-mr/)
- [Thread about repo management and registration, started by Joseph Lee](https://nvda-addons.groups.io/g/nvda-addons/message/6937)
