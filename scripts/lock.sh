#!/usr/bin/env bash
# mhameed 2013-03-19 13:12:03 +0100


cleanup() {
    #echo "cleaning up lock"
    rm $LOCKDIR/pid
    rmdir $LOCKDIR
    trap '' EXIT
}

grabLock () {
    if [ $# -eq 0 ]; then
        # no lock name was given
        LOCKDIR=/tmp/lock.sh.lock
    else
        LOCKDIR="$1"
    fi
    if ! mkdir $LOCKDIR >/dev/null 2>&1;  then
        pid=$(cat $LOCKDIR/pid)
        echo "could not grab $LOCKDIR, $pid got it."
        running=$(ps -p $pid -o pid= -o comm= | wc -l)
        if [ "$running" == "0" ]; then
            echo "it looks like the lock is stail., no pid $pid was found."
            exit 1
        fi
        exit 0
    fi
    trap "cleanup exit 0;" EXIT
    trap "reset; cleanup; exit 1" INT TERM 
    echo $$ >$LOCKDIR/pid
}

