function review() {
    if [ $# -ne 2 ]; then
        echo "Usage: review [remote] [branch]"
        return 1
    fi
    
    remote=$1
    branch=$2
    new_branch="${remote}_${branch}"
    
    # Ensure we have latest origin/master to compare branch to
    git fetch origin master && \

    # Create a new branch
    git checkout -b $new_branch && \

    # Fetch remote/branch code
    git fetch $remote $branch && \

    # Set new branch to remote/branch
    git reset --hard $remote/$branch
}
