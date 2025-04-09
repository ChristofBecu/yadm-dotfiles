set -x PATH $PATH /home/bedawang/.cargo/bin
set -x PATH $PATH /home/bedawang/scripts
set -x PATH $PATH /home/bedawang/.local/share/nvm/v22.14.0/bin/

zoxide init fish | source

set fish_greeting

set -x NVM_DIR $HOME/.nvm

