
scriptsDir="../scripts"

addon2settings() {
    isAddonOrDie
    hasStableBranchOrDie
    addonName=$(basename $PWD)
    cd $PATH2TOPDIR/srt
    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        logMsg "Setting default value for ${addonName} in $file"
        python3 ${scriptsDir}/db.py -f $file --set_default addon.${addonName} 0
    done
}


renameAddonInSettings() {
  if [ -z "$1" ]; then
    logMsg "Expected old addon name."
    exit 1
  fi
  oldAddonName=$1
    isAddonOrDie
    hasStableBranchOrDie
    addonName=$(basename $PWD)
    cd $PATH2TOPDIR/srt
    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        logMsg "Processing $file"
        logMsg "Getting oldValue from ${oldAddonName}, newValue from ${addonName}"
        oldValue=`python3 ${scriptsDir}/db.py -f $file --get addon.${oldAddonName}`
        logMsg "oldValue: ${oldValue}"
        newValue=`python3 ${scriptsDir}/db.py -f $file --get addon.${addonName}`
        logMsg "newValue: ${newValue}"
        setValue=0
        if ([ $oldValue -eq 1 ] || [ $newValue -eq 1 ]); then
            setValue=1
        fi
        logMsg "Setting ${setValue} for ${addonName} in $file"
        # Note: the following uses --set not --set_default. This will override a key if it already exists.
        # The alternative "--set_default" will silently discard the value if the key already exists.
        python3 ${scriptsDir}/db.py -f $file --set addon.${addonName} ${setValue}
        logMsg "Removing old key: ${oldAddonName} in $file"
        python3 ${scriptsDir}/db.py -f $file --delete addon.${oldAddonName}
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
    svn add --parents ${addonPoPath}
    svn commit -m "${lang}: ${addonName} ready to be translated."  ${addonPath}
}

# Run by cron with path ${PathToMrRepo}/addons/<addon Name>/
addon2svn() {
    isAddonOrDie
    hasStableBranchOrDie
    addonName=$(basename $PWD)
    logMsg "Running addon2svn for $addonName"
    # If there are any locally modified files, make sure to stash them so they are not accidentally committed.
    curBranch="$(git branch | grep '*' | awk '{print $2}')"
    needToStash="$(git status --porcelain -uno | wc -l)"
    if [ "$needToStash" -ne 0 ]; then
        datetime="$(date +'%Y-%m-%d at %H:%M:%S')"
        git stash save "$datetime on $curBranch before switching to stable branch"
    fi
    git checkout stable
    git fetch
    git reset --hard origin/stable

    scons pot mergePot
    logMsg "Pot files: "`ls *.pot`
    cp *.pot /tmp/
    ADDONDIR="$(pwd)"
    cd $PATH2TOPDIR/srt
    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        if ! want=$(python3 ${scriptsDir}/db.py -f $file -g addon.${addonName}); then
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
            logMsg "svn status"
            svn status ${addonPath}

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
                logMsg "committing changes"
                # need to commit, because before and after are different.
                svn commit -m "${lang}: ${addonName} merged in ${amsg} messages"  ${addonPoPath}
            else
                logMsg "reverting changes"
                # nothing has changed, dont need to action.
                # revert because comments/timestamps in po file might have changed.
                svn revert ${addonPoPath}
            fi
        fi
    done
    cd "$ADDONDIR"
    # revert just in-case.
    git reset --hard HEAD
    # revert back to whatever branch that we were on before the processing, and unstash any temporary work.
    git checkout "$curBranch"
    if [ "$needToStash" -ne 0 ]; then
        git stash pop
    fi
}
