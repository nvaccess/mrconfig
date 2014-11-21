gitDir=../mainNVDACode

_cp() {
    if [ -e "$1" ]; then
        mkdir -p $(dirname "${gitDir}/${2}")
        cp "$1" "${gitDir}/${2}"
        git -C $gitDir add "$2"
    fi
}

svn2nvda () {
    logMsg "Running svn2nvda"
    git -C "$gitDir" stash
    git -C "$gitDir" checkout master
    git -C "$gitDir" fetch origin
    brname="staging_l10n_$(date '+%Y-%m-%d_-_%H-%M-%S')"
    git -C "$gitDir" branch -D "$brname" || true
    git -C "$gitDir" branch "$brname" origin/master
    git -C "$gitDir" checkout "$brname"
    svnRev=$(svn info | grep -i "Revision")

    ls -1 */settings | while read file; do
        lang=$(dirname $file)
        logMsg "Processing $lang" 
        interface_last_date=$(python scripts/db.py -f $file -g nvda.interface.lastSubmittedDate)
        if test "0" = "${interface_last_date}" ; then
            # at the moment that key is never there, should we introduce this key
            # or is it ok to always just check for commits in the last month.
            # This should be safe, since we commit to nvda git 2 times a month, so
            # there shouldn't be overlooked commits.
            interface_last_date=$(date -u --date='now - 1 month' +'%F %T %z')
            #date -u +'%F %T %z'
        fi
        needsCommitting=$(svn log -r"{$interface_last_date}":head ${lang}/nvda.po | grep -iP "r[0-9]+ \|" | grep -viP "commitbot|mhameed" | wc -l)
        if test "$needsCommitting" != "0" && python -m poChecker $lang/nvda.po ; then
            _cp $lang/nvda.po source/locale/$lang/LC_MESSAGES/nvda.po
        fi
        _cp $lang/symbols.dic source/locale/$lang/symbols.dic
        _cp $lang/characterDescriptions.dic source/locale/$lang/characterDescriptions.dic
        _cp $lang/gestures.ini source/locale/$lang/gestures.ini

        _cp $lang/changes.t2t  user_docs/$lang/changes.t2t
        _cp $lang/userGuide.t2t  user_docs/$lang/userGuide.t2t
        commit=$(git -C "$gitDir" diff --cached | wc -l)
        if [ "$commit" -gt "0" ]; then
            authors=$(python scripts/addresses.py $lang)
            stats=$(git -C "$gitDir" diff --cached --numstat --shortstat)
            echo "L10n updates for: $lang\nFrom translation svn $svnRev\n\nAuthors:\n$authors\n\nStats:\n$stats" | 
            git -C "$gitDir" commit -F -
        fi
    done
    git -C "$gitDir" push origin HEAD:"$brname"
    git -C "$gitDir" checkout master
    git -C "$gitDir" stash pop
    echo "All languages processed, use stg to edit authors/provide additional information., also don't forget to push to try repo to make sure a snapshot can be built."
}
