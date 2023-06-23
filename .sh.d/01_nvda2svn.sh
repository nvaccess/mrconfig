potName=/tmp/nvdaBeta.pot

makePot() {
    origDir=`pwd`
    cd ../mainNVDACode/source
    version="beta-`git rev-parse --short beta`"
    xgettext -o $potName \
        --package-name NVDA --package-version "$version" \
        --foreign-user \
        --add-comments=Translators: \
        --keyword=pgettext:1c,2 \
        --keyword=npgettext:1c,2,3
        --from-code utf-8 \
        --language=python \
        *.py *.pyw */*.py */*/*.py
    cd $origDir
    # Tweak the headers.
    sed -i '
        2c# Copyright (C) 2006-'`date +%Y`'NVDA Contributors
        3d
        16s/CHARSET/UTF-8/
        # Present Windows file paths instead of Unix.
        /^#: /s,/,\\,g
    ' $potName
}

# Run by cron from path ${PathToMrRepo}/srt/
mergePot() {
    logMsg "Running mergePot"
    logMsg "Making pot"
    makePot
    # Now merge the pot into all available languages.
    ls -1 */nvda.po | while read file; do
        logMsg "Merging pot into $file"
        msgmerge --no-location -U $file $potName || logMsg "Error merging pot into $file"
    done
    svn commit -m "Merged nvda interface messages from $potName"  */nvda.po
}

# Run by cron from path cd ${PathToMrRepo}/srt/
findRevs() {
    logMsg "Running findRevs"
    langs=$(ls -1 */settings | sed 's+/settings++' | awk '{printf("%s ", $1)}')
    for lang in ${langs}; do
        logMsg "Processing ${lang}"
        ../scripts/findRevs.py --langs $lang
        svn add -q --parents ${lang}/settings ${lang}/userGuide-newRevisions/* ${lang}/changes-newRevisions/* ${lang}/symbols-newRevisions/* ${lang}/locale-newRevisions/* || 
        svn commit -m "${lang}: new revisions for translation." ${lang}/settings ${lang}/userGuide-newRevisions ${lang}/changes-newRevisions ${lang}/symbols-newRevisions ${lang}/locale-newRevisions ||
        logMsg "Error processing ${lang}"
    done
}
