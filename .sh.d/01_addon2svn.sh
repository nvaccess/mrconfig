
scriptsDir="../scripts"

addon2settings() {
    isAddonOrDie
    hasStableBranchOrDie
	addonName=$(basename $PWD)
    cd $PATH2TOPDIR/srt
    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        logMsg "Setting default value for ${addonName} in $file"
        python ${scriptsDir}/db.py -f $file --set_default addon.${addonName} 0
    done
}

_addFreshPoFile() {
    addonName=$1
    lang=$2
    addonPath=$lang/add-ons/${addonName}
    addonPoPath=${addonPath}/nvda.po
    cp /tmp/${addonName}.pot ${addonPoPath}
    sed -i -e "s/Language: /Language: $lang/g" ${addonPoPath}
    msgmerge --no-location -U ${addonPoPath} /tmp/${addonName}-merge.pot
    svn add ${addonPoPath}
    svn commit -m "${lang}: ${addonName} ready to be translated."  ${addonPath}
}

# Run by cron with path ${PathToMrRepo}/addons/<addon Name>/
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
    git fetch
    git reset --hard origin/stable

	scons pot mergePot
	cp *.pot /tmp/
    ADDONDIR="$(pwd)"
    cd $PATH2TOPDIR/srt
    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        if ! want=$(python ${scriptsDir}/db.py -f $file -g addon.${addonName}); then
            logMsg "Error in settings file. Skipping $lang"
            continue
        fi
        logMsg "$lang wants ${addonName}: $want"
        if [ "$want" != "1" ]; then
            continue
        fi
        addonPath=$lang/add-ons/${addonName}
        addonPoPath=${addonPath}/nvda.po
        if [ ! -d ${addonPath} ]; then
            logMsg "Wanted, but not already in svn, providing it."
            svn mkdir --parents ${addonPath}
            _addFreshPoFile ${addonName} ${lang}
        elif [ ! -f ${addonPoPath} ]; then
            logMsg "Wanted, but po file is missing, restoring file."
            _addFreshPoFile ${addonName} ${lang}
        else
            logMsg "Already available for translation, merging in new messages."

            # Statistics before merging pot.
            bfuzzy=$(pocount ${addonPoPath} | grep -i fuzzy | awk '{print $2}')
            buntranslated=$(pocount ${addonPoPath} | grep -i untranslated | awk '{print $2}')
            bmsg="$bfuzzy fuzzy and $buntranslated untranslated"

            msgmerge --no-location -U ${addonPoPath} /tmp/${addonName}-merge.pot

            # Statistics after merging pot.
            afuzzy=$(pocount ${addonPoPath} | grep -i fuzzy | awk '{print $2}')
            auntranslated=$(pocount ${addonPoPath} | grep -i untranslated | awk '{print $2}')
            amsg="$afuzzy fuzzy and $auntranslated untranslated"

            if [ "$bmsg" != "$amsg" ]; then
                # need to commit, because before and after are different.
                svn commit -m "${lang}: ${addonName} merged in ${amsg} messages"  ${addonPoPath}
            else
                # nothing has changed, dont need to action.
                # revert because comments/timestamps in po file might have changed.
                svn revert ${addonPoPath}
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
