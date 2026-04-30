# Switch kitty theme in pixi shells, restore on exit
# PIXI_ENVIRONMENT_NAME is set after fish config runs, so we watch for it
if test "$TERM" = xterm-kitty
    function _kitty_pixi_theme --on-variable PIXI_ENVIRONMENT_NAME
        functions -e _kitty_pixi_theme
        if set -q PIXI_ENVIRONMENT_NAME
            kitty @ --to unix:/tmp/kitty-$KITTY_PID set-colors --match id:$KITTY_WINDOW_ID ~/.config/kitty/atelier-sulphur-pool-dark.conf
            function _kitty_restore_theme --on-event fish_exit
                kitty @ --to unix:/tmp/kitty-$KITTY_PID set-colors --match id:$KITTY_WINDOW_ID ~/.config/kitty/current-theme.conf
            end
        end
    end
end

# Switch kitty theme in distrobox containers, restore on exit
if set -q CONTAINER_ID; and test "$TERM" = xterm-kitty
    kitty @ --to unix:/tmp/kitty-$KITTY_PID set-colors --match id:$KITTY_WINDOW_ID ~/.config/kitty/solarized-dark.conf

    # Default `555` is too dim against solarized base03 background
    set fish_color_autosuggestion 93a1a1

    function _kitty_restore_theme --on-event fish_exit
        kitty @ --to unix:/tmp/kitty-$KITTY_PID set-colors --match id:$KITTY_WINDOW_ID ~/.config/kitty/current-theme.conf
    end
end
