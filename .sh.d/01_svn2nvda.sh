gitDir=../mainNVDACode

_cp() {
    if [ -e "$1" ]; then
        mkdir -p $(dirname "${gitDir}/${2}")
        cp "$1" "${gitDir}/${2}"
        git -C $gitDir add "$2"
    fi
}

checkT2t() {
    if [ ! -f $1 ]; then
        echo Warning: $1 does not exist
        return 1
    fi
    encoding=`file $1 | grep -vP ': +(HTML document, )?(ASCII text|UTF-8|empty)'`
    if [ "$encoding" != "" ]; then
        echo Encoding problem: $encoding
        return 1
    fi
    if ! output=$(txt2tags -q -o /dev/null $1 2>&1); then
        echo Error in $1:
        echo "$output"
        return 1
    fi
}

checkUserGuide() {
    checkT2t $1/userGuide.t2t || return 1
    origDir=`pwd`
    cd $1
    result=0
    if ! output=$(python ../../scripts/keyCommandsDoc.py 2>&1); then
        echo Key commands error in $1/userGuide.t2t: $output
        result=1
    fi
    rm -f keyCommands.t2t
    cd $origDir
    return $result
}

# Run by cron from path ${PathToMrRepo}/srt/
svn2nvda () {
    logMsg "Running svn2nvda"
    git -C "$gitDir" stash
    git -C "$gitDir" checkout beta
    git -C "$gitDir" fetch origin
    git -C "$gitDir" reset --hard origin/beta
    brname=l10n
    git -C "$gitDir" branch -D "$brname" || true
    git -C "$gitDir" branch "$brname"
    git -C "$gitDir" checkout "$brname"
    svnRev=$(svn info | grep -i "Revision" | awk '{print $2}')

    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        logMsg "Processing $lang"
        if ! lastSubmittedSvnRev=$(python ../scripts/db.py -f $file -g nvda.lastSubmittedSvnRev); then
            logMsg "Error in settings file. Skipping language"
            continue
        fi
        logMsg "Got lastSubmittedSvnRev: $lastSubmittedSvnRev"
        if test "0" = "${lastSubmittedSvnRev}"; then
            logMsg "LastSubmittedSvnRev == 0 setting to 1"
            lastSubmittedSvnRev=1
        fi
        if test "60382" -gt "${lastSubmittedSvnRev}"; then
          logMsg "Force needsCommitting"
          needsCommitting=1
        else
          needsCommitting=$(svn log -r${lastSubmittedSvnRev}:head ${lang}/nvda.po | grep -iP "r[0-9]+ \|" | grep -viP "commitbot" | wc -l)
        fi
        logMsg "Needs committing: ${needsCommitting}"
        if test "$needsCommitting" != "0" && python ../scripts/poChecker $lang/nvda.po ; then
            logMsg "copying po file"
            _cp $lang/nvda.po source/locale/$lang/LC_MESSAGES/nvda.po
        fi
        _cp $lang/symbols.dic source/locale/$lang/symbols.dic
        _cp $lang/characterDescriptions.dic source/locale/$lang/characterDescriptions.dic
        _cp $lang/gestures.ini source/locale/$lang/gestures.ini

        checkT2t $lang/changes.t2t && _cp $lang/changes.t2t  user_docs/$lang/changes.t2t
        checkUserGuide $lang && _cp $lang/userGuide.t2t  user_docs/$lang/userGuide.t2t
        commit=$(git -C "$gitDir" diff --cached | wc -l)
        if [ "$commit" -gt "0" ]; then
            logMsg "Doing commit and updating lastSubmittedSvnRev to $svnRev"
            authors=$(python ../scripts/addresses.py $lang)
            stats=$(git -C "$gitDir" diff --cached --numstat --shortstat)
            echo "L10n updates for: $lang\nFrom translation svn revision: $svnRev\n\nAuthors:\n$authors\n\nStats:\n$stats" |
            git -C "$gitDir" commit -F -
            python ../scripts/db.py -f $file -s nvda.lastSubmittedSvnRev "$svnRev"
        fi
    done
    git -C "$gitDir" checkout beta
    git -C "$gitDir" merge --no-ff --no-commit l10n
    echo "Update translations.\n\nFrom translation svn revision: $svnRev" |
        git -C "$gitDir" commit -F -
    git  -C "$gitDir" push
    svn commit -m "Update metadata after merge to NVDA." */settings
    git -C "$gitDir" stash pop || true
}