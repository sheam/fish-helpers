function yzd --description 'yazi file browser with directory changing'
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if set -l cwd (cat "$tmp"); and test -d "$cwd"
        cd "$cwd"
    end
    rm -f "$tmp"
end

abbr -a less 'glow -p'
abbr -a g glow
