return {
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      branch = "main",
      dependencies = {
          { "github/copilot.vim" },
  --      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
        { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
      },
      opts = {
        debug = true, -- Enable debugging
        -- See Configuration section for rest
        prompts = {
          Commit = {
              prompt = "Generate a commit message following the Conventional Commits format. Determine the type of change (feat, fix, refactor, docs, style, chore, test) based on the modifications. If the commit relates to a specific application, configuration, or tool (e.g., Neovim, dotfiles, i3, Fastify), include it as a scope. Keep the title under 50 characters. Wrap the body at 72 characters. Use imperative mood in the title. List key changes in bullet points. Format as a gitcommit code block.",
              
          },
        },
      },
      -- See Commands section for default commands if you want to lazy load on them
    },
    vim.keymap.set('n', '<C-c>', '<Cmd>CopilotChatToggle<CR>')

  }