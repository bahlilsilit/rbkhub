
-- [[ RBK SIMPLE LOADER ]]
-- Just load the main script.

local function Load()
    local success, err = pcall(function()
        if readfile and isfile and isfile("RbkHub/main.lua") then
            loadstring(readfile("RbkHub/main.lua"))()
        else
             loadstring(game:HttpGet("https://raw.githubusercontent.com/bahlilsilit/rbkhub/refs/heads/main/main.lua"))()
            warn("[RBK] main.lua tidak ditemukan di folder workspace.")
        end
    end)
    
    if not success then
        warn("[RBK] Gagal memuat script: " .. tostring(err))
    end
end

Load()
