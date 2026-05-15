function yzd --description 'yazi file browser with directory changing'
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if set -l cwd (cat "$tmp"); and test -d "$cwd"
        cd "$cwd"
    end
    rm -f "$tmp"
end

function md2 --description 'Convert a Markdown file to HTML (and optionally PDF) using pandoc.'
    argparse 'h/help' 'p/pdf' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: md2 [-p|--pdf] [-h|--help] <file>"
        echo "  -p, --pdf   Also generate a PDF alongside the HTML"
        echo "  -h, --help  Show this help"
        return 0
    end

    if test (count $argv) -ne 1
        echo "Usage: md2 [-p|--pdf] [-h|--help] <file>"
        return 1
    end

    set -l file $argv[1]
    set -l name (string replace -r '\.[^.]+$' '' (basename $file))
    set -l out ~/Documents/$name.html

    pandoc $file -s -o $out --css $HOME/code/fish/pandoc.css --metadata title="$name"
    echo "Generated $out"

    if set -q _flag_pdf
        set -l pdf_out ~/Documents/$name.pdf
        pandoc $file -s -o $pdf_out --pdf-engine=weasyprint --css $HOME/code/fish/pandoc.css --metadata title="$name" 2>/dev/null
        echo "Generated $pdf_out"
    end
end

abbr -a less 'glow -p'
abbr -a g glow
abbr -a tb toolbox enter fedora-toolbox-44
