#!/usr/bin/env bash

_debug=0

function debug() {
    if [ $_debug -ne 0 ]; then
        echo $@
    fi
}

#debug "this message is not printed"
#_debug=1
#debug "this is printed"
#_debug=0
#debug "second message that is not printed."
