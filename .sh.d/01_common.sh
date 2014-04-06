PATH2TOPDIR=../..
DEBUG=1

logMsg() {
    if [ $DEBUG -ne 0 ]; then
        echo 1>&2 `date '+%H:%M:%S'` "$@"
    fi
}

_checkProgExists() {
   
    while [ -n "$1" ]; do
        if [ -z "$(command -v "$1")" ]; then
            logMsg "$1: command not found"
            exit 1
        fi
        shift
    done
}

checkNeededProgsExists() {
    # checks if the required command exists
    _checkProgExists msgfmt msgmerge po4a-translate pocount scons
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
    if ! git branch -r | grep -q "origin/stable"; then 
        logMsg "Warning: this addon has no stable branch, aborting."
        exit 1
    fi
}
