function yzd --description 'yazi file browser with directory changing'
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if set -l cwd (cat "$tmp"); and test -d "$cwd"
        cd "$cwd"
    end
    rm -f "$tmp"
end

function tomd --description 'Convert file to HTML with pandoc'
    if test (count $argv) -ne 1
        echo "Usage: tomd <file>"
        return 1
    end
    set -l file $argv[1]
    set -l name (string replace -r '\.[^.]+$' '' (basename $file))
    set -l out ~/Documents/$name.html
    pandoc -s $file -o $out
    echo $out
end

abbr -a less 'glow -p'
abbr -a g glow
