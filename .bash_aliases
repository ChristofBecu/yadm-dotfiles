alias c='clear'
alias h='history'
alias j='jobs -l'
alias home='cd $HOME'

# do not delete / or prompt if deleting more than 3 files at a time
alias rm='rm -I --preserve-root'

# confirmation
alias mv='mv -i'
alias cp='mv -i'
alias ln='ln -i'

# parenting changing perms on
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias grep='grep --color=auto'
alias diff='colordiff'

alias dotfiles='/usr/bin/git --git-dir=/home/bedawang/.dotfiles/ --work-tree=/home/bedawang'
alias cat='bat'

alias ls='eza --icons'
alias lsa='eza -lha -G --icons'

alias neofetch='fastfetch'

alias cd='z'
alias cd..='cd ..'
alias .='cd ..'
alias ..='cd ../..'
alias ...='cd ../../..'

alias mkcd='function _mkcd() { mkdir -p "$1" && cd "$1"; }; _mkcd'

alias pkgInfo="pacman -Qq | fzf --preview 'pacman -Qil {} | 
bat -fpl yml' --layout=reverse --bind 'enter:execute(pacman -Qil 
{} | less)'"
