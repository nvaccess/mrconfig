getBitbucketURL() {
    bt_ssh=git@bitbucket.org:nvdaaddonteam
    bt=https://bitbucket.org/nvdaaddonteam
    name=$(basename $MR_REPO)
    echo ${bt}/${name}.git
}
