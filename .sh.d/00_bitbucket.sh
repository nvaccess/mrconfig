getBitbucketURL() {
    name=$(basename $MR_REPO)
    if [ "$1" != "" ]; then
        name="$1"
    fi
    uri=https://bitbucket.org/nvdaaddonteam
    if [ "$MR_USE_PROTOCOL" = "ssh" ]; then
        uri="git@bitbucket.org:nvdaaddonteam"
    fi
    echo ${uri}/${name}.git
}
