PATH2TOPDIR=../..
DEBUG=1

logMsg() {
    if [ $DEBUG -ne 0 ]; then
        echo `date '+%Y/%m/%d %H:%M:%S'` "$1"
    fi
}

# A check to see if the current directory looks like an addon.
isAddon() {
	test -d ${MR_REPO}/addon -a -f sconstruct -a -f buildVars.py
}

