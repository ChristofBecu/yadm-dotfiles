return {
    "VonHeikemen/lsp-zero.nvim",
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "j-hui/fidget.nvim",
 
    config=function()
        local lsp = require("lsp-zero")
        lsp.preset("recommended")

        lsp.on_attach(function(bufnr)
            lsp.default_keymaps({buffer= bufnr})
        end)

        require('mason').setup({})
        require('mason-lspconfig').setup({
        ensure_installed = {
            'tsserver',
            'rust_analyzer',
            'eslint',
            'luau_lsp',
            'csharp_ls',
            'pyright',
            },
         handlers = {
            lsp.default_setup,
             },
        })

        lsp.setup()
    end
}

