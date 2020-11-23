getGithubURL() {
    name=$(basename $MR_REPO)
    if [ "$1" != "" ]; then
        name="$1"
    fi
    uri="https://github.com/nvdaaddons"
    if [ "$MR_USE_PROTOCOL" = "ssh" ]; then
        uri="git@github.com:nvdaaddons"
    fi
    echo ${uri}/${name}.git
}

getNVAccessGithubURL() {
    name=$(basename $MR_REPO)
    if [ "$1" != "" ]; then
        name="$1"
    fi
    uri="https://github.com/nvaccess"
    if [ "$MR_USE_PROTOCOL" = "ssh" ]; then
        uri="git@github.com:nvaccess"
    fi
    echo ${uri}/${name}.git
}
