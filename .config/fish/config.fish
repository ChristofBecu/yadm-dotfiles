if status is-interactive
    # Commands to run in interactive sessions can go here
    if status is-login
        if test -z "$DISPLAY" -a $XDG_VTNR -eq 1
            exec startx
        end
	end

end

thefuck --alias | source

# IntelliShell
set -gx INTELLI_HOME "/home/bedawang/.local/share/intelli-shell"
set -gx INTELLI_SEARCH_HOTKEY ctrl-space
# set -gx INTELLI_VARIABLE_HOTKEY ctrl-l
# set -gx INTELLI_BOOKMARK_HOTKEY ctrl-b
# set -gx INTELLI_FIX_HOTKEY ctrl-x
# set -gx INTELLI_SKIP_ESC_BIND 0
# alias is="intelli-shell"
fish_add_path "$INTELLI_HOME/bin"
intelli-shell init fish | source
