function fish_prompt
    set -l last_status $status

    # Directory on its own line
    echo ''
    set_color --bold yellow
    echo (prompt_pwd)
    set_color normal

    # Prompt character
    if test $last_status -eq 0
        set_color --bold green
        echo -n '➜ '
    else
        set_color --bold red
        echo -n '✗ '
    end
    set_color normal
end

function fish_right_prompt
    set -l parts

    # Git branch + dirty indicator
    if command -q git; and git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null; or git describe --tags --exact-match 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
        if test -n "$branch"
            set -l git_info (set_color purple)$branch(set_color normal)
            if not git diff-index --quiet HEAD -- 2>/dev/null; or test -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -1)"
                set git_info $git_info(set_color red)' *'(set_color normal)
            end
            set -a parts $git_info
        end
    end

    # Container name
    if set -q CONTAINER_ID
        set -a parts (set_color cyan)'⬡ '$CONTAINER_ID(set_color normal)
    else if test -f /run/.containerenv
        set -l cname (string match -r 'name="([^"]+)"' < /run/.containerenv)[2]
        if test -n "$cname"
            set -a parts (set_color cyan)'⬡ '$cname(set_color normal)
        else
            set -a parts (set_color cyan)'⬡ container'(set_color normal)
        end
    else if test -f /.dockerenv
        set -a parts (set_color cyan)'⬡ docker'(set_color normal)
    end

    # user@host on SSH only
    if set -q SSH_CONNECTION
        set -a parts (set_color green)$USER(set_color blue)'@'(prompt_hostname)(set_color normal)
    end

    echo (string join ' │ ' $parts)
end
