# do not delete / or prompt if deleting more than 3 files at a time
abbr -a rm 'rm -I --preserve-root'

# confirmation
abbr -a mv 'mv -i'
abbr -a cp 'cp -i'
abbr -a ln 'ln -i'

# parenting changing perms on
abbr -a chown 'chown --preserve-root'
abbr -a chmod 'chmod --preserve-root'
abbr -a chgrp 'chgrp --preserve-root'

abbr -a cd 'z'
abbr -a cd.. 'cd ..'
abbr -a . 'cd ..'
abbr -a .. 'cd ../..'
abbr -a ... 'cd ../../..'

abbr -a home 'cd $HOME'
