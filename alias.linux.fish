function yzd --description 'yazi file browser with directory changing'
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if set -l cwd (cat "$tmp"); and test -d "$cwd"
        cd "$cwd"
    end
    rm -f "$tmp"
end

# Resolved at source time: inside a function, `status filename` isn't reliable.
set -g __md2_css (path resolve (path dirname (status filename)))/pandoc.css

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
    set -l outdir (dirname $file)
    if test -d ~/Documents
        set outdir ~/Documents
    else if test -d ~/docs
        set outdir ~/docs
    end
    set -l out $outdir/$name.html

    if not test -f $__md2_css
        echo "md2: stylesheet not found: $__md2_css" >&2
        return 1
    end

    pandoc $file -s --embed-resources -o $out --css $__md2_css --metadata title="$name"
    or return 1
    echo "Generated $out"

    if set -q _flag_pdf
        set -l pdf_out $outdir/$name.pdf
        if pandoc $file -s -o $pdf_out --pdf-engine=weasyprint --css $__md2_css --metadata title="$name"
            echo "Generated $pdf_out"
        else
            echo "md2: PDF generation failed" >&2
            return 1
        end
    end
end

abbr -a less 'glow -p'
abbr -a g glow
abbr -a tb toolbox enter fedora-toolbox-44
