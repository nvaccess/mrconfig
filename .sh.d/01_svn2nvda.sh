gitDir=../mainNVDACode

_cp() {
    if [ -e "$1" ]; then
        mkdir -p $(dirname "${gitDir}/${2}")
        cp "$1" "${gitDir}/${2}"
        git -C $gitDir add "$2"
    fi
}

checkMd() {
    if [ ! -f $1 ]; then
        echo Warning: $1 does not exist
        return 1
    fi
    encoding=`file $1 | grep -vP ': +(HTML document, |Unicode text, )?(ASCII text|UTF-8|empty)'`
    if [ "$encoding" != "" ]; then
        echo Encoding problem: $encoding
        return 1
    fi
    if ! output=$(python3 /home/nvdal10n/mr/scripts/md2html.py check $1 $2 2>&1); then
        echo Error in $1:
        echo "$output"
        return 1
    fi
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
        if ! lastSubmittedSvnRev=$(python3 ../scripts/db.py -f $file -g nvda.lastSubmittedSvnRev); then
            logMsg "Error in settings file. Skipping language"
            continue
        fi
        logMsg "Got lastSubmittedSvnRev: $lastSubmittedSvnRev"
        if test "0" = "${lastSubmittedSvnRev}"; then
            logMsg "LastSubmittedSvnRev == 0 setting to 1"
            lastSubmittedSvnRev=1
        fi
        _cp $lang/symbols.dic source/locale/$lang/symbols.dic
        _cp $lang/characterDescriptions.dic source/locale/$lang/characterDescriptions.dic
        _cp $lang/gestures.ini source/locale/$lang/gestures.ini

        checkMd $lang/changes.md $lang/changes.html && _cp $lang/changes.md  user_docs/$lang/changes.md
        checkMd $lang/userGuide.md $lang/keyCommands.html && _cp $lang/userGuide.md  user_docs/$lang/userGuide.md
        commit=$(git -C "$gitDir" diff --cached | wc -l)
        if [ "$commit" -gt "0" ]; then
            logMsg "Doing commit and updating lastSubmittedSvnRev to $svnRev"
            authors=$(python3 ../scripts/addresses.py $lang)
            stats=$(git -C "$gitDir" diff --cached --numstat --shortstat)
            echo "L10n updates for: $lang\nFrom translation svn revision: $svnRev\n\nAuthors:\n$authors\n\nStats:\n$stats" |
            git -C "$gitDir" commit -F -
            python3 ../scripts/db.py -f $file -s nvda.lastSubmittedSvnRev "$svnRev"
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
