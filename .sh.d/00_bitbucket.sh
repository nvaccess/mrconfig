getBitbucketURL() {
    name=$(basename $MR_REPO)
    if [ "$1" != "" ]; then
        name="$1"
    fi
    bt_ssh=git@bitbucket.org:nvdaaddonteam
    bt=https://bitbucket.org/nvdaaddonteam
    echo ${bt}/${name}.git
}
