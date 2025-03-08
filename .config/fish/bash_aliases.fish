abbr -a c 'clear'
abbr -a h 'history'
abbr -a j 'jobs -l'
abbr -a home 'cd $HOME'

# do not delete / or prompt if deleting more than 3 files at a time
abbr -a rm 'rm -I --preserve-root'

# confirmation
abbr -a mv 'mv -i'
abbr -a cp 'mv -i'
abbr -a ln 'ln -i'

# parenting changing perms on
abbr -a chown 'chown --preserve-root'
abbr -a chmod 'chmod --preserve-root'
abbr -a chgrp 'chgrp --preserve-root'

abbr -a grep 'grep --color=auto'
abbr -a diff 'colordiff'

abbr -a dotfiles '/usr/bin/git --git-dir=/home/bedawang/.dotfiles/ --work-tree=/home/bedawang'
abbr -a cat 'bat'

abbr -a ls 'eza --icons'
abbr -a lsa 'eza -lha -G --icons'

abbr -a neofetch 'fastfetch'

abbr -a cd 'z'
abbr -a cd.. 'cd ..'
abbr -a . 'cd ..'
abbr -a .. 'cd ../..'
abbr -a ... 'cd ../../..'

abbr -a mkcd 'function _mkcd() { mkdir -p "$1" && cd "$1"; }; _mkcd'

alias pkgInfo="pacman -Qq | fzf --preview 'pacman -Qil {} | 
bat -fpl yml' --layout=reverse --bind 'enter:execute(pacman -Qil 
{} | less)'"
