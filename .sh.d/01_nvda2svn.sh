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
