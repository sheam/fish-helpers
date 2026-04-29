function gitprune
    echo "Fetching and pruning remote tracking branches..."
    if not git fetch --prune
        echo "Error: Failed to fetch from remote"
        return 1
    end

    set -l current_branch (git branch --show-current)

    set -l branches_to_delete
    for branch in (git branch | string replace -r '^\*?\s+' '')
        test -z "$branch"; and continue
        test "$branch" = "$current_branch"; and continue
        if not git show-ref --verify --quiet "refs/remotes/origin/$branch"
            set -a branches_to_delete $branch
        end
    end

    if test (count $branches_to_delete) -eq 0
        echo "No local branches to prune."
        return 0
    end

    echo "The following local branches will be deleted:"
    for branch in $branches_to_delete
        echo "  $branch"
    end

    read -P "Proceed? (y/N) " confirm
    if not string match -qr '^[Yy]$' -- $confirm
        echo "Aborted."
        return 0
    end

    for branch in $branches_to_delete
        git branch -D $branch
    end
end
