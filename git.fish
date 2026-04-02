function rebase --description 'Fetch and rebase current branch onto origin/<branch>'
    if test (count $argv) -eq 0
        echo "Usage: rebase <branch-name>"
        echo ""
        echo "Fetches the latest changes from origin/<branch-name> and rebases"
        echo "the current branch onto it."
        echo ""
        echo "Example: rebase main"
        return 1
    end

    set -l branch $argv[1]

    echo "Fetching latest changes from origin/$branch..."
    if not git fetch origin $branch
        echo "Error: Failed to fetch origin/$branch"
        return 1
    end

    echo "Rebasing current branch onto origin/$branch..."
    if not git rebase origin/$branch
        echo "Error: Rebase failed. You may need to resolve conflicts."
        echo "Use 'git rebase --continue' after resolving conflicts, or 'git rebase --abort' to cancel."
        return 1
    end

    echo "Successfully rebased onto origin/$branch"
    return 0
end

# Tab completion for rebase command
complete -c rebase -f -xa '(git branch -a 2>/dev/null | string replace -r "^[* ] " "" | string replace -r "remotes/origin/" "" | sort -u)'

function git_rebase_all_master --description 'Rebase submodules onto master based on parent branch'
    set -l dry_run false
    if test "$argv[1]" = --dry-run; or test "$argv[1]" = -n
        set dry_run true
    end

    set -l parent_branch (git symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$parent_branch"
        echo "Error: Parent repo is on a detached HEAD. Please checkout a branch first."
        return 1
    end

    set -l rebased
    set -l detached
    set -l pulled
    set -l skipped
    set -l failed

    if test $dry_run = true
        echo "[DRY RUN] No changes will be made."
        echo ""
    end

    echo "Parent repo branch: $parent_branch"
    echo ""

    for sm_path in (git submodule foreach --quiet 'echo $sm_path')
        echo "=== Submodule: $sm_path ==="

        set -l sub_branch (git -C $sm_path symbolic-ref --short HEAD 2>/dev/null)

        if test -z "$sub_branch"
            # Detached HEAD — checkout latest master
            if test $dry_run = true
                echo "  Detached HEAD detected. Would checkout latest master."
            else
                echo "  Detached HEAD detected. Checking out latest master..."
                git -C $sm_path fetch origin master
                git -C $sm_path checkout master
                git -C $sm_path pull origin master
            end
            set -a detached $sm_path
        else if test "$sub_branch" = master
            # On master — pull latest
            if test $dry_run = true
                echo "  On master. Would pull latest."
            else
                echo "  On master. Pulling latest..."
                git -C $sm_path pull origin master
            end
            set -a pulled $sm_path
        else if test "$sub_branch" = "$parent_branch"
            # Branch matches parent — rebase onto latest master
            if test $dry_run = true
                echo "  On branch '$sub_branch' (matches parent). Would rebase onto origin/master."
            else
                echo "  On branch '$sub_branch' (matches parent). Rebasing onto origin/master..."
                git -C $sm_path fetch origin master
                if not git -C $sm_path rebase origin/master
                    echo "  Error: Rebase failed in $sm_path. Aborting rebase."
                    git -C $sm_path rebase --abort
                    echo "  Resolve conflicts manually and retry."
                    set -a failed $sm_path
                    echo ""
                    continue
                else
                    echo "  Successfully rebased '$sub_branch' onto origin/master."
                end
            end
            set -a rebased $sm_path
        else
            echo "  On branch '$sub_branch' (does not match parent '$parent_branch'). Skipping."
            set -a skipped $sm_path
        end

        echo ""
    end

    # Report
    echo "==============================="
    if test $dry_run = true
        echo "  DRY RUN REPORT"
    else
        echo "  SUMMARY REPORT"
    end
    echo "==============================="

    if test (count $rebased) -gt 0
        echo ""
        echo "Rebased onto master ("(count $rebased)"):"
        for r in $rebased; echo "  - $r"; end
    end

    if test (count $detached) -gt 0
        echo ""
        echo "Detached HEAD → checked out master ("(count $detached)"):"
        for r in $detached; echo "  - $r"; end
    end

    if test (count $pulled) -gt 0
        echo ""
        echo "On master → pulled latest ("(count $pulled)"):"
        for r in $pulled; echo "  - $r"; end
    end

    if test (count $failed) -gt 0
        echo ""
        echo "Rebase FAILED ("(count $failed)"):"
        for r in $failed; echo "  - $r"; end
    end

    if test (count $skipped) -gt 0
        echo ""
        echo "Skipped ("(count $skipped)"):"
        for r in $skipped; echo "  - $r"; end
    end

    echo ""
end
