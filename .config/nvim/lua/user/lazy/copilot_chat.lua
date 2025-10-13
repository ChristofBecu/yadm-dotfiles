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
              prompt = '$gpt-5-mini: Generate a commit message following the Conventional Commits format. Identify the correct type (feat, fix, refactor, docs, style, chore, test) based on the code changes. Infer the relevant scope (e.g., nvim, i3, dotfiles, fastify) if applicable. Keep the title under 50 characters, using imperative mood. Wrap the body at 72 characters. Be concise: Clearly explain what changed and why in as few words as possible. List key changes in three or fewer bullet points—only the most relevant details. If the commit introduces breaking changes, add ! after the type and include a BREAKING CHANGE: section at the end. Format as a gitcommit code block.'
          },
        },
      },
      -- See Commands section for default commands if you want to lazy load on them
    },
    vim.keymap.set('n', '<C-c>', '<Cmd>CopilotChatToggle<CR>')

  }
