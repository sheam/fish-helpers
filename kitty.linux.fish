# Switch kitty theme in distrobox containers, restore on exit
if set -q CONTAINER_ID; and test "$TERM" = xterm-kitty
    kitty @ --to unix:/tmp/kitty-$KITTY_PID set-colors --match id:$KITTY_WINDOW_ID ~/.config/kitty/solarized-dark.conf

    function _kitty_restore_theme --on-event fish_exit
        kitty @ --to unix:/tmp/kitty-$KITTY_PID set-colors --match id:$KITTY_WINDOW_ID ~/.config/kitty/current-theme.conf
    end
end
