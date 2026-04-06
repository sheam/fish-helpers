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

function _prompt_find_up
    set -l file $argv[1]
    set -l dir (pwd)
    set -l depth 0
    while true
        if test -f "$dir/$file"
            return 0
        end
        if test -d "$dir/.git" -o $depth -ge 3 -o "$dir" = "/" -o "$dir" = $HOME
            return 1
        end
        set dir (dirname $dir)
        set depth (math $depth + 1)
    end
end

function fish_right_prompt
    set -l parts

    # Language detection (walks up to home dir)
    if _prompt_find_up go.mod; and command -q go
        set -l m (go version 2>/dev/null | string match -r 'go(\d+\.\d+[\d.]*)')
        set -a parts (set_color cyan)'🐹 go '(set_color normal)(set_color --bold white)$m[2](set_color normal)
    end
    if _prompt_find_up Cargo.toml; and command -q rustc
        set -l m (rustc --version 2>/dev/null | string split ' ')
        set -a parts (set_color brred)'🦀 '(set_color normal)(set_color --bold white)$m[2](set_color normal)
    end
    if _prompt_find_up package.json; and command -q node
        set -l ver (node --version 2>/dev/null)
        if _prompt_find_up tsconfig.json
            set -a parts (set_color blue)'󰛦 '(set_color normal)(set_color --bold white)$ver(set_color normal)
        else
            set -a parts (set_color green)'⬡ '(set_color normal)(set_color --bold white)$ver(set_color normal)
        end
    end
    if begin
            _prompt_find_up pyproject.toml
            or _prompt_find_up requirements.txt
            or _prompt_find_up setup.py
        end; and command -q python3
        set -l m (python3 --version 2>/dev/null | string split ' ')
        set -a parts (set_color yellow)'🐍 '(set_color normal)(set_color --bold white)$m[2](set_color normal)
    end

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

    # rpm-ostree staged deployment (fast file check — no subprocess)
    if test -f /run/ostree/staged-deployment
        set -a parts (set_color bryellow)'󰚰 reboot to update'(set_color normal)
    end

    # user@host on SSH only
    if set -q SSH_CONNECTION
        set -a parts (set_color green)$USER(set_color blue)'@'(prompt_hostname)(set_color normal)
    end

    echo (string join ' │ ' $parts)
end
