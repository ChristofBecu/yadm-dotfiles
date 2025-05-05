local function run_dotnet_command()
    print("Executing: dotnet run")

    -- Run the "dotnet run" command in a terminal buffer
    vim.cmd("split | terminal dotnet run")
end

vim.keymap.set("n", "<leader>d", run_dotnet_command, { desc = "Run dotnet run" })
