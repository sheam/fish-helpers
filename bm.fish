set -g BOOKMARK_FILE ~/.local/share/cli_bookmarks.txt

function bm --description 'Directory bookmark manager'
    _bm_ensure_file
    if test (count $argv) -eq 0; or test "$argv[1]" = -l
        _bm_print_bookmarks
        return $status
    end

    if test "$argv[1]" = -h
        _bm_print_help
        return $status
    end

    if test "$argv[1]" = -r
        _bm_delete_bookmark $argv[2]
        return $status
    end

    if test "$argv[1]" = -s
        _bm_set_bookmark $argv[2]
        return $status
    end

    if test (count $argv) -eq 1
        set -l d (_bm_get_location_from_name $argv[1])
        if test $status -eq 0
            cd "$d"
            return 0
        else
            echo "ERROR: Bookmark '$argv[1]' not found"
            return 1
        end
    end

    _bm_print_help
end

function _bm_print_help
    echo "To set a bookmark, cd to the directory you want to bookmark and then:"
    echo "    bm -s <NAME>"
    echo "To delete a bookmark:"
    echo "    bm -r <NAME>"
    echo "To CD to a directory by bookmark name:"
    echo "    bm <NAME>"
    echo "To print a list of bookmarks: "
    echo "    bm -l"
    echo "To print help: "
    echo "    bm -h"
end

function _bm_ensure_file
    if not test -f "$BOOKMARK_FILE"
        echo "Bookmark file $BOOKMARK_FILE not found. Creating."
        mkdir -p (dirname $BOOKMARK_FILE)
        touch $BOOKMARK_FILE
    end
end

function _bm_print_bookmarks
    echo ""
    printf "%-15s   %-60s\n" BOOKMARK LOCATION
    printf "%-15s   %-60s\n" -------- --------
    for line in (sort $BOOKMARK_FILE)
        set -l parts (string split \t -- $line | string match -rv '^$')
        if test (count $parts) -ge 2
            printf "%-15s   %-60s\n" $parts[1] $parts[2]
        end
    end
    return 0
end

function _bm_get_location_from_name
    set -l target $argv[1]
    for line in (cat $BOOKMARK_FILE)
        set -l parts (string split \t -- $line | string match -rv '^$')
        if test (count $parts) -ge 2; and test "$parts[1]" = "$target"
            echo $parts[2]
            return 0
        end
    end
    return 1
end

function _bm_get_name_from_location
    set -l target $argv[1]
    for line in (cat $BOOKMARK_FILE)
        set -l parts (string split \t -- $line | string match -rv '^$')
        if test (count $parts) -ge 2; and test "$parts[2]" = "$target"
            echo $parts[1]
            return 0
        end
    end
    return 1
end

function _bm_set_bookmark
    set -l name $argv[1]
    set -l location $PWD
    if test -z "$name"; or test -z "$location"
        echo "set_bookmark requires two arguments, NAME LOCATION."
        return 1
    end

    set -l existing_location (_bm_get_location_from_name $name)
    if test $status -eq 0
        echo "The bookmark named '$name' already exists and points to '$existing_location'."
        read -P "Do you want to replace it? [y/N] " -l reply
        if not string match -qir '^y' -- $reply
            echo "Bookmark not updated."
            return 1
        end
        _bm_delete_bookmark $name >/dev/null
    end

    set -l existing_name (_bm_get_name_from_location $location)
    if test $status -eq 0
        _bm_delete_bookmark $existing_name >/dev/null
    end

    echo -e "$name\t\t$location" >>$BOOKMARK_FILE
    return 0
end

function _bm_delete_bookmark
    set -l target $argv[1]
    if test -z "$target"
        echo "delete_bookmark requires a parameter NAME"
        return 1
    end

    set -l tmp /tmp/cli_bookmarks
    rm -f $tmp
    touch $tmp
    for line in (cat $BOOKMARK_FILE)
        set -l parts (string split \t -- $line | string match -rv '^$')
        if test (count $parts) -ge 2; and test "$parts[1]" = "$target"
            echo "removed $parts[1] ($parts[2])"
        else if test -n "$line"
            echo -e "$parts[1]\t\t$parts[2]" >>$tmp
        end
    end
    sort $tmp >$BOOKMARK_FILE
end

# Tab completion for bm command
complete -c bm -f
complete -c bm -s l -d 'List all bookmarks'
complete -c bm -s h -d 'Show help'
complete -c bm -s r -d 'Remove bookmark' -xa '(test -f ~/.local/share/cli_bookmarks.txt; and awk \'{print $1}\' ~/.local/share/cli_bookmarks.txt)'
complete -c bm -s s -d 'Save current directory as bookmark'
complete -c bm -n 'not __fish_seen_subcommand_from -l -h -r -s' -xa '(test -f ~/.local/share/cli_bookmarks.txt; and awk \'{print $1}\' ~/.local/share/cli_bookmarks.txt)'
