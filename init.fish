# Source this file from your fish config.fish

set -g FISH_HELPERS (status dirname)

set -l helpers alias vars path bm log prompt ssh git kitty

function _fish_load_script
    set -l name $argv[1]
    set -l base_script $FISH_HELPERS/$name.fish
    set -l linux_script $FISH_HELPERS/$name.linux.fish
    set -l local_script $FISH_HELPERS/$name.local.fish

    if test -f $base_script
        test -n "$DEBUG"; and echo "Sourcing $base_script"
        source $base_script
    end

    if test -f $linux_script
        test -n "$DEBUG"; and echo "Sourcing $linux_script"
        source $linux_script
    end

    if test -f $local_script
        test -n "$DEBUG"; and echo "Sourcing $local_script"
        source $local_script
    end
end

for helper in $helpers
    _fish_load_script $helper
end
