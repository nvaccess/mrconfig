mergePot() {
    logMsg "Running mergePot"
    # Download the pot file from the snapshots page and store it in /tmp/
    pageUrl='http://community.nvda-project.org/wiki/Snapshots'
    potUrl=$(wget -qO - $pageUrl | sed -n 'b main;: quit;q;: main;s`^.*\(http://.*master.*\.pot\).*$`\1`p;t quit')
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
    for lang in ${langs}; do
        logMsg "Processing ${lang}"
        cd scripts
        ./findRevs.py --langs $lang
        cd ..
        # previously svn add to already versioned files use to be silent newer
        # svn seem to produce errors and bork, so override this with the
        # --force flag.
        svn add -q --force ${lang}/settings ${lang}/userGuide-newRevisions/*
        ${lang}/changes-newRevisions/* ${lang}/symbols-newRevisions/*
        svn commit -m "${lang}: new revisions for translation." ${lang}/settings ${lang}/userGuide-newRevisions/* ${lang}/changes-newRevisions/* ${lang}/symbols-newRevisions/*
    done
}
