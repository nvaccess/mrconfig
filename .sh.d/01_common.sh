PATH2TOPDIR=../..
DEBUG=1

logMsg() {
    if [ $DEBUG -ne 0 ]; then
        echo 1>&2 `date '+%Y/%m/%d %H:%M:%S'` "$@"
    fi
}

# A check to see if the current directory looks like an addon.
isAddon() {
	test -d ${MR_REPO}/addon -a -f sconstruct -a -f buildVars.py
}

isAddonOrDie() {
	if ! $(isAddon); then
		logMsg "Warning: Doesn't seem to be an addon, aborting."
		exit 1
	fi
}

hasStableBranchOrDie() {
    if git branch -r | grep -qv "origin/stable"; then
        logMsg "Warning: this addon has no stable branch, aborting."
        exit 1
    fi
}
