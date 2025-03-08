if status is-interactive
    # Commands to run in interactive sessions can go here
	if tty | grep -q '/dev/tty1'
	    exec startx
	end
end


set -x PATH $PATH /home/bedawang/.cargo/bin

zoxide init fish | source

source ~/.config/fish/bash_aliases.fish

