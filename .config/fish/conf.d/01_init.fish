set -x PATH $PATH /home/bedawang/.cargo/bin
set -x PATH $PATH /home/bedawang/scripts
set -x PATH $PATH /home/bedawang/.local/share/nvm/v22.14.0/bin/
set -x PATH $PATH /home/bedawang/bin/
set -x PATH $PATH /home/bedawang/.dotnet
set -x PATH $PATH /home/bedawang/.dotnet/tools
set -x PATH $PATH /home/bedawang/.local/bin
set -x PATH $PATH /home/bedawang/.local/share/nvm/v22.14.0/lib/node_modules/@angular/cli/bin
set -x PATH $PATH /home/bedawang/dev/external/vcpkg

zoxide init fish | source

set fish_greeting

set -x NVM_DIR $HOME/.nvm

