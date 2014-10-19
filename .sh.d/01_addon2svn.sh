addon2settings() {
    isAddonOrDie
    hasStableBranchOrDie
	addonName=$(basename $PWD)
    cd $PATH2TOPDIR/srt
    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        logMsg "Setting default value for ${addonName} in $file"
        python scripts/db.py -f $file --set_default addon.${addonName} 0
    done
}

addon2svn() {
    isAddonOrDie
    hasStableBranchOrDie
	addonName=$(basename $PWD)
	logMsg "Running addon2svn for $addonName"
    # If there are any locally modified files, make sure to stash them so they are not accidentally committed.
    needToStash="$(git status --porcelain -uno | wc -l)"
    if [ "$needToStash" -ne 0 ]; then
        datetime="$(date +'%Y-%m-%d at %H:%M:%S')"
        curBranch="$(git branch | grep '*' | awk '{print $2}')"
        git stash save "$datetime on $curBranch before switching to stable branch"
    fi
    git checkout stable

	scons pot mergePot
	cp *.pot /tmp/
    ADDONDIR="$(pwd)"
    cd $PATH2TOPDIR/srt
    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        want=$(python scripts/db.py -f $file -g addon.${addonName})
        logMsg "$lang wants ${addonName}: $want"
        if [ "$want" != "1" ]; then
            continue
        fi
        if [ ! -d $lang/add-ons/${addonName} ]; then
            logMsg "Wanted, but not already in svn, providing it."
            svn mkdir $lang/add-ons/${addonName}
            cp /tmp/${addonName}.pot $lang/add-ons/${addonName}/nvda.po
            sed -i -e "s/Language: /Language: $lang/g" $lang/add-ons/${addonName}/nvda.po
            msgmerge --no-location -U $lang/add-ons/${addonName}/nvda.po /tmp/${addonName}-merge.pot
            svn add $lang/add-ons/${addonName}/nvda.po
            svn commit -m "${lang}: ${addonName} ready to be translated."  $lang/add-ons/${addonName}/
        else
            logMsg "Already available for translation, merging in new messages."

            # Statistics before merging pot.
            bfuzzy=$(pocount $lang/add-ons/${addonName}/nvda.po | grep -i fuzzy | awk '{print \$2}')
            buntranslated=$(pocount $lang/add-ons/${addonName}/nvda.po | grep -i untranslated | awk '{print \$2}')
            bmsg="$bfuzzy fuzzy and $buntranslated untranslated"

            msgmerge --no-location -U $lang/add-ons/${addonName}/nvda.po /tmp/${addonName}-merge.pot

            # Statistics after merging pot.
            afuzzy=$(pocount $lang/add-ons/${addonName}/nvda.po | grep -i fuzzy | awk '{print \$2}')
            auntranslated=$(pocount $lang/add-ons/${addonName}/nvda.po | grep -i untranslated | awk '{print \$2}')
            amsg="$afuzzy fuzzy and $auntranslated untranslated"

            if [ "$bmsg" == "$amsg" ]; then
                # nothing has changed, dont need to action.
                # revert because comments/timestamps in po file might have changed.
                svn revert $lang/add-ons/${addonName}/nvda.po
            else
                # need to commit, because before and after are diffrent.
                svn commit -m "${lang}: ${addonName} merged in ${amsg} messages"  $lang/add-ons/${addonName}/nvda.po
            fi
        fi
    done
    cd "$ADDONDIR"
    # revert just incase.
    git reset --hard HEAD
    # revert back to whatever branch that we were on before the processing, and unstash any temporary work.
    git checkout "$curBranch"
    if [ "$needToStash" -ne 0 ]; then
        git stash pop
    fi
}
