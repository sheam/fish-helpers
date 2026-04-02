if not set -q XDG_RUNTIME_DIR
    set -gx XDG_RUNTIME_DIR /run/user/(id -u)
end

set -gx EDITOR hx
set -gx GOPATH $HOME/.local/share/go
