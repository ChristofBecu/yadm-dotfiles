
local lfs = require('lfs') -- LuaFileSystem module for directory operations

-- Step 1: List all Lua files in the current directory
local function get_lua_files(dir)
    local files = {}
    for file in lfs.dir(dir) do
        if file:match(".lua$") then -- ".lua" extension
            table.insert(files, file)
        end
    end
    return files
end

-- Step 2: Open each file and read its content
local function read_file(path)
    local file = io.open(path, "r") -- r read mode
    if not file then return nil end
    local content = file:read("*a") -- *a reads the whole file
    file:close()
    return content
end

-- Step 3: Search for key mapping patterns in the file content
local function extract_key_mappings(content)
    local mappings = {}
    for mode, key, action in string.gmatch(content, "map%('(%w)', '(%w+)', '(%w+)'%)") do
        if not mappings[mode] then mappings[mode] = {} end
        mappings[mode][key] = action
    end
    return mappings
end

-- Step 4: Extract and summarize the key mappings
local function summarize_key_mappings(dir)
    local files = get_lua_files(dir)
    local key_mappings = {}
    for _, file in ipairs(files) do
        local content = read_file(dir .. '/' .. file)
        if content then
            local mappings = extract_key_mappings(content)
            for mode, map in pairs(mappings) do
                if not key_mappings[mode] then key_mappings[mode] = {} end
                for key, action in pairs(map) do
                    key_mappings[mode][key] = action
                end
            end
        end
    end
    return key_mappings
end

-- Print the summarized key mappings
local key_mappings = summarize_key_mappings('.')
for mode, mappings in pairs(key_mappings) do
    print('Mode: ' .. mode)
    for key, action in pairs(mappings) do
        print('  Key: ' .. key .. ', Action: ' .. action)
    end
end
