#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

if [ -f ~/.bash_path ]; then
	source ~/.bash_path
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

eval "$(zoxide init bash)"

source ~/sources/forgit/forgit.plugin.sh

