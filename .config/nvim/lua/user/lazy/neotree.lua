return {
    
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function ()
        require('neo-tree').setup{ filesystem = {
          filtered_items = {
            visible = true, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = true,
            hide_hidden = true,
            hide_gitignored = true,
            always_show = { -- remains visible even if other settings would normally hide it
              ".vscode", ".jenkinsfiles"
            },
            never_show = {
              ".git",
              ".github"
            }
          }
      }
    }
  end,
  vim.keymap.set('n', '<C-t>', '<Cmd>Neotree toggle<CR>')
}