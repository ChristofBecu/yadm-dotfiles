if status is-interactive
    # Commands to run in interactive sessions can go here
    if status is-login
        if test -z "$DISPLAY" -a $XDG_VTNR -eq 1
            exec startx
        end
	end

end
