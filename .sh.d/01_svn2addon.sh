transformPo() {
    # Reconstructs a language specific markdown file, given the translated po
    # and the original english markdown.
    addonName=$1
    lang=$2
    enSrcFile=srt/website/addons/${addonName}.mdwn
    langPoFile=srt/website/addons/${addonName}.${lang}.po
    tmpLangMdFile=${lang}.tmp.mdown
    po4a-translate  -k 40 -f text -o markdown -M UTF-8 -m \
        $enSrcFile  -L UTF-8 -p $langPoFile -l $tmpLangMdFile
    if [ -e $tmpLangMdFile ]; then
        sed -e '1 s/.*"\(.*\)".*/# \1 #/g' <$tmpLangMdFile >${lang}.mdown
        rm $tmpLangMdFile
    fi
}

svn2addon() {
	if ! $(isAddon); then
		logMsg "Warning: Doesn't seem to be an addon, aborting."
		exit 1
	fi
	addonName=$(basename $PWD)
    logMsg "Running svn2addon for $addonName"
    ADDONDIR="$(pwd)"
    # check that we have a stable branch
    if git branch -r | grep -qv "origin/stable"; then
        logMsg "Warning: this addon has no stable branch, aborting."
        exit 1
    fi

    # If there are any locally modified files, make sure to stash them so they are not accidentally committed.
    needToStash="$(git status --porcelain -uno | wc -l)"
    if [ "$needToStash" -ne 0 ]; then
        datetime="$(date +'%Y-%m-%d at %H:%M:%S')"
        curBranch="$(git branch | grep '*' | awk '{print $2}')"
        git stash save "$datetime on $curBranch before switching to stable branch"
    fi
    git checkout stable

    cd $PATH2TOPDIR
    ls -1 srt/*/add-ons/$addonName/nvda.po | while read srcFile; do
        lang=$(echo $srcFile | sed 's+srt/\(.*\)/add.*/nvda.po+\1+g')
        logMsg "Processing $lang"
        poDir=addons/$addonName/addon/locale/$lang/LC_MESSAGES
        docDir=addons/$addonName/addon/doc/$lang
        msgfmt -c -o /tmp/foo.mo $srcFile
        translatedMessages=$(pocount --csv $srcFile | tail -n 1 | awk -F, '{printf("%d\n", $2)}' )    
        totalMessages=$(pocount --csv $srcFile | tail -n 1 | awk -F, '{printf("%d\n", $9)}' )    
        logMsg "$lang has $translatedMessages/$totalMessages"
        if [ $translatedMessages -ne 0 ]; then
            mkdir -p $poDir
            cp $srcFile $poDir
        fi
        docPo=srt/website/addons/${addonName}.${lang}.po
        if [ -e $docPo ]; then
            translatedMessages=$(pocount  --csv $docPo | tail -n 1 | awk -F, '{printf("%d\n", $2)}' )    
            totalMessages=$(pocount  --csv $docPo | tail -n 1 | awk -F, '{printf("%d\n", $9)}' )    
            logMsg "$lang doc $translatedMessages/$totalMessages"
            if [ $translatedMessages -eq 0 ]; then
                continue
            fi
            logMsg "Will transform doc data."
            mkdir -p $docDir
            transformPo $addonName $lang
            if [ -e ${lang}.mdown ]; then
                mv ${lang}.mdown $docDir/readme.md
            fi
        fi
    done
    cd "$ADDONDIR"

    # Back in the git repo, find all po files in the locale directory
    git status --porcelain addon/locale/ -uall | grep -P ".*\.po$" | awk '{print $2}' | while read file; do
        # Find out percentage translated, and if above 70% add it to the index ready to be committed.
        percentCompleted=$(pocount --csv $file | tail -n 1 | awk '{printf("%.0f\n", $2/$9*100)}')
        if [ $percentCompleted -gt 70 ]; then
            git add $file
        fi
    done
    # deal with the readme's
    rm -rf addon/doc/en/
    git add addon/doc/*/readme.md
    git commit -m "l10n updates" && git push
    # incase there are anything left that we didnt deem suitable to commit,
    # such as po files that are less than 70% translated.
    git reset --hard HEAD
    # revert back to whatever branch that we were on before the processing, and unstash any temporary work.
    git checkout "$curBranch"
    if [ "$needToStash" -ne 0 ]; then
        git stash pop
    fi
}

