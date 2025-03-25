local function insert_copilot_commit()
    print("Inserting Copilot commit message...")

    -- Get the current buffer's lines (Copilot commit message)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local commit_message = {}
    local capture = false

    -- Extract the commit message from the Copilot buffer
    for _, line in ipairs(lines) do
        if line:match("^```gitcommit") then
            capture = true
        elseif line:match("^```") and capture then
            break
        elseif capture then
            table.insert(commit_message, line)
        end
    end

    if #commit_message == 0 then
        print("No Copilot commit message found.")
        return
    end

    -- Find the COMMIT_EDITMSG buffer
    local commit_editmsg_buf = nil
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):match("COMMIT_EDITMSG$") then
            commit_editmsg_buf = buf
            break
        end
    end

    if not commit_editmsg_buf then
        print("COMMIT_EDITMSG buffer not found.")
        return
    end

    -- Get the lines from the COMMIT_EDITMSG buffer
    local editmsg_lines = vim.api.nvim_buf_get_lines(commit_editmsg_buf, 0, -1, false)

    -- Find the insertion point in the COMMIT_EDITMSG buffer
    local insert_index = 0
    for i, line in ipairs(editmsg_lines) do
        if line:match("# ------------------------ >8 ------------------------") then
            insert_index = i - 1
            break
        end
    end

    -- Insert the commit message into the COMMIT_EDITMSG buffer
    if insert_index > 0 then
        vim.api.nvim_buf_set_lines(commit_editmsg_buf, insert_index, insert_index, false, commit_message)
        print("Commit message inserted into COMMIT_EDITMSG.")
    else
        print("No insertion point found in COMMIT_EDITMSG. Appending commit message at the end.")
        vim.api.nvim_buf_set_lines(commit_editmsg_buf, -1, -1, false, commit_message)
    end

    -- Close the Copilot Chat window if succesfull
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_get_name(buf):match("CopilotChat") then
            vim.api.nvim_win_close(win, true)
            print("Copilot Chat window closed.")
            break
        end
    end
end

vim.keymap.set("n", "<leader>c", insert_copilot_commit, { desc = "Insert Copilot commit message" })