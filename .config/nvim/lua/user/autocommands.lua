local function load_autocommands()
    local autocommands_dir = vim.fn.stdpath("config") .. "/lua/user/autocommands"
    local handle = vim.loop.fs_scandir(autocommands_dir)
    if not handle then
        return
    end

    while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then
            break
        end

        -- Only require Lua files
        if type == "file" and name:match("%.lua$") then
            local module_name = "user.autocommands." .. name:gsub("%.lua$", "")
            require(module_name)
        end
    end
end

load_autocommands()