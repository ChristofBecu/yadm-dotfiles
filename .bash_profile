#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [ "$(tty)" == "/dev/tty1" ]; then
	if ! pgrep -x Xorg > /dev/null; then
		startx
	fi
fi

. "$HOME/.cargo/env"

source /home/bedawang/.config/broot/launcher/bash/br

# IntelliShell
export INTELLI_HOME="/home/bedawang/.local/share/intelli-shell"
# export INTELLI_SEARCH_HOTKEY=\\C-@
# export INTELLI_VARIABLE_HOTKEY=\\C-l
# export INTELLI_BOOKMARK_HOTKEY=\\C-b
# export INTELLI_FIX_HOTKEY=\\C-x
# export INTELLI_SKIP_ESC_BIND=0
# alias is="intelli-shell"
export PATH="$INTELLI_HOME/bin:$PATH"
eval "$(intelli-shell init bash)"
