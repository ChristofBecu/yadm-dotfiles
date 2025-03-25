abbr -a c 'clear'
abbr -a h 'history'
abbr -a j 'jobs -l'

abbr -a grep 'grep --color=auto'
abbr -a diff 'colordiff'

abbr -a dotfiles '/usr/bin/git --git-dir=/home/bedawang/.dotfiles/ --work-tree=/home/bedawang'
abbr -a cat 'bat'

abbr -a ls 'eza --icons'
abbr -a lsa 'eza -lha -G --icons'

abbr -a neofetch 'fastfetch'

abbr -a ai 'ai.sh'

alias pkgInfo="pacman -Qq | fzf --preview 'pacman -Qil {} | 
bat -fpl yml' --layout=reverse --bind 'enter:execute(pacman -Qil 
{} | less)'"
