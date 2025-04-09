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
