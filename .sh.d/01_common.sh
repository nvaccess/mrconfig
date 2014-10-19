PATH2TOPDIR=../..
DEBUG=1
#set -x

logMsg() {
    if [ $DEBUG -ne 0 ]; then
        echo 1>&2 "$@"
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
    _checkProgExists elinks fromdos msgfmt msgmerge po4a-translate pocount scons wdiff wget
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

# suppose to be run from available.d in the mr config repo.
registerAddon () {
    addonName="$1"
    curDir=$(basename $PWD)
    if test "$curDir" != "available.d" ; then
        echo "To run this command, we need to be in the available.d directory"
        exit 1
    fi
    logMsg "Registering addon ${addonName}"
    # check that the repo exists on bitbucket:
    tmpName=$(mktemp -d)
    if git clone $(getBitbucketURL $addonName) ${tmpName}; then
        rm -rf ${tmpName}
        echo "[addons/${addonName}]" >10_${addonName}
        echo "checkout = git clone \$(getBitbucketURL) \$MR_REPO" >>10_${addonName}
        git add 10_${addonName}
        git commit -m "added ${addonName} to mr config." 10_${addonName}
        # create a symlink for the new addon in enabled.d
        cd ../enabled.d && ln -s ../10_${addonName} .
        echo "all done, inspect commit and push if everything looks ok."
    else
        echo "unable to clone the ${addonName} repo from bitbucket nvdaaddonteam, please make sure the name is correct."
        exit 1
    fi
}
