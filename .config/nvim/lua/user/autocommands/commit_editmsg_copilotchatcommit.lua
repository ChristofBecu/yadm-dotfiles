-- Set up an autocommand to trigger CopilotChatCommit when editing a commit message
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "COMMIT_EDITMSG",
    callback = function()
        vim.cmd("CopilotChatCommit")
    end,
    desc = "Automatically trigger CopilotChatCommit when editing a commit message",
})