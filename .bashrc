#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#PS1='[\u@\h \W]\$ '
PS1='[\[\033[38;5;82m\]\u\[\033[0m\]@\[\033[38;5;214m\]\h\[\033[0m\] \[\033[38;5;39m\]\W\[\033[0m\]$(git rev-parse --is-inside-work-tree &>/dev/null && echo " \[\033[38;5;45m\]($(git branch --show-current 2>/dev/null))\[\033[0m\]")]\$ '


if [ -f ~/.bash_path ]; then
	source ~/.bash_path
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

eval "$(zoxide init bash)"

source ~/sources/forgit/forgit.plugin.sh

. "$HOME/.cargo/env"

export PATH="$HOME/.dotnet:$PATH"

source /home/bedawang/.config/broot/launcher/bash/br
