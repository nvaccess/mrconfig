mergePot() {
    logMsg "Running mergePot"
    # Download the pot file from the snapshots page and store it in /tmp/
    pageUrl='http://www.nvda-project.org/wiki/Snapshots/'
    potUrl=$(elinks --dump "$pageUrl" | grep ".pot" | grep master | head -n 1 | awk '{print $2}')
    potName=$(basename "$potUrl")
    logMsg "Downloading $potName from $potUrl"
    wget -q -O /tmp/$potName "$potUrl"
    fromdos /tmp/$potName
    # Now merge the pot into all available languages.
    ls -1 */nvda.po | while read file; do
        logMsg "Merging pot into $file"
        msgmerge --no-location -U $file /tmp/$potName
    done
    svn commit -m "Merged nvda interface messages from $potName"  */nvda.po
}

findRevs() {
    logMsg "Running findRevs"
    langs=$(ls -1 */settings | sed 's+/settings++' | awk '{printf("%s ", $1)}')
    cd scripts
    ./findRevs.py --langs $langs
    cd ..
    # Calculate userGuide-stats.txt for every revision.
    find */userGuide-diffs/ -maxdepth 1 -mindepth 1 -type d | grep -vi ".svn" | while read rev; do
        cd $rev
        python ../../../scripts/stats.py
        cd ../../../
    done
    svn -q add  */settings */userGuide-diffs/* */changes-diffs/* */symbols-diffs/*
    svn commit -m "All langs: new revisions for translation." */settings */userGuide-diffs/* */changes-diffs/* */symbols-diffs/*
}
