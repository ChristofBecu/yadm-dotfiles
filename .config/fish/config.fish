if status is-interactive
    # Commands to run in interactive sessions can go here
	if tty | grep -q '/dev/tty1'
	    exec startx
	end
end
