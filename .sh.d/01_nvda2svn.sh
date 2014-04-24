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
