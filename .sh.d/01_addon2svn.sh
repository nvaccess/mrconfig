addAddon2settings() {
	if ! $(isAddon); then
		echo "Doesn't seem to be an addon, aborting."
		return 1
	fi
	addonName=$(basename $PWD)
    cd $PATH2TOPDIR
    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        logMsg "processing $lang"
        python scripts/db.py -f $file --set_default addon.${addonName} 0
    done
}

addon2svn() {
	if ! $(isAddon); then
		echo "Doesn't seem to be an addon, aborting."
		return 1
	fi
	scons pot mergePot
	cp *.pot /tmp/
	addonName=$(basename $PWD)
	logMsg "processing $addonName"
    cd $PATH2TOPDIR
    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        want=$(python scripts/db.py -f $file -g addon.${addonName})
        logMsg "$lang wants ${addonName}: $want"
        if [ "$want" != "1" ]; then
            continue
        fi
        if [ ! -d $lang/add-ons/${addonName} ]; then
            logMsg "wanted, but not already in svn, providing it."
            svn mkdir $lang/add-ons/${addonName}
            cp /tmp/${addonName}.pot $lang/add-ons/${addonName}/nvda.po
            sed -i -e "s/Language: /Language: $lang/g" $lang/add-ons/${addonName}/nvda.po
            svn add $lang/add-ons/${addonName}/nvda.po
        else
            logMsg "already available for translation, merging in new messages."
            msgmerge -U $lang/add-ons/${addonName}/nvda.po /tmp/${addonName}-merge.pot
        fi
    done
}

addCompletedL10n() {
    # find all po files in the locale directory
    git status --porcelain addon/locale/ -uall | grep -P ".*\.po$" | awk '{print $2}' | while read file; do
        # Find out percentage translated, and if above 70% add it to the index ready to be committed.
        percentCompleted=$(pocount --csv $file | tail -n 1 | awk '{printf("%.0f\n", $2/$9*100)}')
        if [ $percentCompleted -gt 70 ]; then
            git add $file
        fi
    done
    # deal with the readme's
    git status --porcelain -uall addon/doc/ | grep -P ".*\.md$" | awk '{print $2}' | while read file; do
        git add $file
    done
}
