# Basic shortcuts
abbr n 'nvim'                      # Launch Neovim
abbr ne 'nvim ./'                  # Open Neovim in the current directory
abbr nv 'nvim ~/.config/nvim/'     # Open Neovim config

# Quick edits
abbr ninit 'nvim ~/.config/nvim/init.lua'    # Edit init.lua
abbr nkey 'nvim ~/.config/nvim/lua/keymaps.lua'   # Edit keymaps
abbr nplug 'nvim ~/.config/nvim/lua/plugins.lua'  # Edit plugins

# Useful actions
abbr nvrc 'source ~/.config/nvim/init.lua'   # Reload Neovim config
abbr nlog 'nvim /var/log/syslog'             # View system log
abbr nj 'nvim ~/.config/fish/config.fish'    # Edit Fish config in Neovim

# File operations
abbr ne. 'nvim .'                  # Open Neovim in the current directory
abbr nr 'nvim -R'                  # Open Neovim in read-only mode
abbr ncd 'nvim +cd %:p:h'         # Change Neovim working dir to the current file

# LSP and debugging
abbr nlint 'nvim +checkhealth'     # Run Neovim's health check
abbr ndebug 'nvim --noplugin -u NONE'   # Start Neovim without plugins

# Diff and merges
abbr nd 'nvim -d'                 # Diff two files
abbr ndf 'nvim -d file1 file2'    # Example diff command
abbr nmer 'nvim -d file1 file2 file3'   # Merge conflicts with Neovim

# Project management
abbr nproj 'nvim $(fzf)'          # Use fzf to open a project
abbr ntodo 'nvim ~/TODO.md'       # Edit a personal TODO file

# Fast quitting
abbr nq 'nvim +qall!'             # Quit all Neovim windows (force)

