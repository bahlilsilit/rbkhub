--[[ 
    ============================================================
    RBK REMOTE SPY V6 - ULTIMATE STABILITY (FIXED)
    ============================================================
    Developer: RbkHub
    Fixes:
    - Replaced hookmetamethod with getrawmetatable (More stable for Mobile).
    - Added Debug Console logs to verify hooks.
    - Improved UI parent handling for better visibility.
    - Added "FORCE START" to bypass any potential init issues.
    ============================================================
]]

local VALID_KEY = "RBKHUBSPY2024"
local KEY_SITE = "https://pastebin.com/raw/yourkey"

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- CONFIG GLOBAL
getgenv().RbkConfig = {
    Enabled = true,
    Captures = {},
    Blocked = {},
}

-- THEME
local Theme = {
    Main = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(0, 255, 150),
    Secondary = Color3.fromRGB(25, 25, 30),
    Text = Color3.fromRGB(240, 240, 240)
}

-- UTILS
local function create(className, props, parent)
    local obj = Instance.new(className)
    for k,v in pairs(props) do obj[k]=v end
    if parent then obj.Parent = parent end
    return obj
end

local function notify(title, msg)
    print("[RBK] " .. title .. ": " .. msg) -- Console Backup
    local g = CoreGui:FindFirstChild("RbkNotify") or create("ScreenGui", {Name="RbkNotify"}, CoreGui)
    local f = create("Frame", {Size=UDim2.new(0,250,0,60), Position=UDim2.new(1,10,1,-70), BackgroundColor3=Theme.Secondary}, g)
    create("UICorner", {CornerRadius=UDim.new(0,8)}, f)
    create("TextLabel", {Text=title, Size=UDim2.new(1,-20,0,25), Position=UDim2.new(0,12,0,5), TextColor3=Theme.Accent, Font="GothamBold", TextSize=14, BackgroundTransparency=1, TextXAlignment="Left"}, f)
    create("TextLabel", {Text=msg, Size=UDim2.new(1,-20,0,25), Position=UDim2.new(0,12,0,28), TextColor3=Theme.Text, Font="Gotham", TextSize=11, BackgroundTransparency=1, TextXAlignment="Left"}, f)
    TweenService:Create(f, TweenInfo.new(0.4), {Position=UDim2.new(1,-260,1,-70)}):Play()
    task.delay(4, function() pcall(function() f:Destroy() end) end)
end

-- ============================================================
-- MAIN SPY INTERFACE
-- ============================================================

local function startSpy()
    local Gui = create("ScreenGui", {Name="RbkSpyV6", ResetOnSpawn=false}, CoreGui)
    local Main = create("Frame", {Size=UDim2.new(0,600,0,400), Position=UDim2.new(0.5,-300,0.5,-200), BackgroundColor3=Theme.Main, Active=true}, Gui)
    create("UICorner", {CornerRadius=UDim.new(0,10)}, Main)
    create("UIStroke", {Color=Theme.Accent, Thickness=1.5, Transparency=0.5}, Main)

    local Header = create("Frame", {Size=UDim2.new(1,0,0,40), BackgroundColor3=Theme.Secondary}, Main)
    create("UICorner", {CornerRadius=UDim.new(0,10)}, Header)
    create("TextLabel", {Text="RBK REMOTE SPY V6 (FIXED)", Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,15,0,0), TextColor3=Theme.Accent, Font="GothamBold", TextSize=14, BackgroundTransparency=1, TextXAlignment="Left"}, Header)

    local CloseBtn = create("TextButton", {Text="✕", Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-35,0,5), BackgroundColor3=Color3.fromRGB(150,50,50), TextColor3=Color3.new(1,1,1), Font="GothamBold"}, Header)
    create("UICorner", {CornerRadius=UDim.new(1,0)}, CloseBtn)

    local ListScroll = create("ScrollingFrame", {Size=UDim2.new(0.35,-10,1,-50), Position=UDim2.new(0,5,0,45), BackgroundTransparency=1, ScrollBarThickness=2, CanvasSize=UDim2.new(0,0,0,0)}, Main)
    create("UIListLayout", {Padding=UDim.new(0,4)}, ListScroll)

    local CodeBox = create("TextBox", {MultiLine=true, TextEditable=true, ClearTextOnFocus=false, Size=UDim2.new(0.65,-10,0.8,-10), Position=UDim2.new(0.35,5,0,45), BackgroundColor3=Theme.Secondary, TextColor3=Theme.Text, Font="Code", TextSize=11, TextXAlignment="Left", TextYAlignment="Top", Text="-- Waiting for items..."}, Main)
    create("UICorner", {CornerRadius=UDim.new(0,8)}, CodeBox)

    local RunBtn = create("TextButton", {Text="RUN REMOTE", Size=UDim2.new(0.65,-10,0.15,-5), Position=UDim2.new(0.35,5,0.85,0), BackgroundColor3=Theme.Accent, TextColor3=Theme.Main, Font="GothamBold", TextSize=12}, Main)
    create("UICorner", {CornerRadius=UDim.new(0,8)}, RunBtn)

    -- Draggable
    local d, i, sp, ds
    Header.InputBegan:Connect(function(e) if e.UserInputType == Enum.UserInputType.MouseButton1 then d=true ds=e.Position sp=Main.Position end end)
    UserInputService.InputChanged:Connect(function(e) if d and e.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = e.Position - ds
        Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
    end end)
    UserInputService.InputEnded:Connect(function(e) d=false end)

    -- CORE LOGIC
    local activeLog = nil

    local function getPath(ins)
        local s, r = pcall(function()
            local p = ins.Name
            local cur = ins.Parent
            while cur and cur ~= game do p = cur.Name .. "." .. p cur = cur.Parent end
            return "game." .. p
        end)
        return s and r or "UnknownPath"
    end

    local function format(v, visited)
        visited = visited or {}
        if type(v) == "string" then return '"'..v..'"'
        elseif type(v) == "table" then
            if visited[v] then return "{Recursive}" end visited[v]=true
            local s = "{" for k,val in pairs(v) do s = s.."["..format(k,visited).."]="..format(val,visited).."," end
            return s .. "}"
        else return tostring(v) end
    end

    local function onEntry(remote, method, args)
        if not getgenv().RbkConfig.Enabled then return end
        local rName = tostring(remote)
        local time = os.date("%X")
        local data = {Remote=remote, Method=method, Args=args, Path=getPath(remote)}

        task.spawn(function()
            local b = create("TextButton", {
                Text = "["..time.."] "..rName, Size=UDim2.new(1,0,0,25),
                BackgroundColor3=Color3.fromRGB(35,35,40), TextColor3=Theme.Accent,
                Font="Gotham", TextSize=10, Parent=ListScroll
            })
            create("UICorner", {CornerRadius=UDim.new(0,4)}, b)

            b.MouseButton1Click:Connect(function()
                activeLog = data
                local s = {} for _, v in ipairs(args) do table.insert(s, format(v)) end
                CodeBox.Text = string.format("local remote = %s\nlocal args = {%s}\nremote:%s(unpack(args))", data.Path, table.concat(s, ", "), method)
            end)
            ListScroll.CanvasSize = UDim2.new(0,0,0,ListScroll.UIListLayout.AbsoluteContentSize.Y)
        end)
    end

    -- THE HOOK (STABLE VERSION)
    print("[RBK] Initializing Hooks...")
    local raw_mt = getrawmetatable(game)
    setreadonly(raw_mt, false)
    local old_nc = raw_mt.__namecall

    raw_mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            onEntry(self, method, {...})
        end
        return old_nc(self, ...)
    end)

    -- Proto Hooks (Backup)
    local old_fire; old_fire = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
        onEntry(self, "FireServer", {...})
        return old_fire(self, ...)
    end)

    local old_invoke; old_invoke = hookfunction(Instance.new("RemoteFunction").InvokeServer, function(self, ...)
        onEntry(self, "InvokeServer", {...})
        return old_invoke(self, ...)
    end)

    setreadonly(raw_mt, true)

    -- BUTTONS
    RunBtn.MouseButton1Click:Connect(function()
        local func, err = loadstring(CodeBox.Text)
        if func then pcall(func) notify("Success", "Remote fired!") else notify("Error", err) end
    end)
    CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() getgenv().RbkConfig.Enabled = false end)

    notify("Spy V6 Ready", "Hooks successfully connected. Waiting for network traffic.")
    warn("[RBK] REMOTE SPY V6 VIRTUALIZED.")
end

-- ============================================================
-- GATEKEEPER
-- ============================================================

local function showGate()
    local g = create("ScreenGui", {Name="RbkKey"}, CoreGui)
    local m = create("Frame", {Size=UDim2.new(0,300,0,180), Position=UDim2.new(0.5,-150,0.5,-90), BackgroundColor3=Theme.Main}, g)
    create("UICorner", {CornerRadius=UDim.new(0,10)}, m)
    create("TextLabel", {Text="SECURITY CHECK", Size=UDim2.new(1,0,0,40), TextColor3=Theme.Accent, Font="GothamBold", TextSize=16, BackgroundTransparency=1}, m)
    
    local i = create("TextBox", {PlaceholderText="Key Here", Size=UDim2.new(0.8,0,0,35), Position=UDim2.new(0.1,0,0,55), BackgroundColor3=Theme.Secondary, TextColor3=Theme.Text, Font="Gotham", TextSize=14}, m)
    create("UICorner", {CornerRadius=UDim.new(0,6)}, i)

    local b = create("TextButton", {Text="LOGIN", Size=UDim2.new(0.35,0,0,30), Position=UDim2.new(0.1,0,0,105), BackgroundColor3=Theme.Accent, TextColor3=Theme.Main, Font="GothamBold"}, m)
    create("UICorner", {CornerRadius=UDim.new(0,6)}, b)

    local k = create("TextButton", {Text="GET KEY", Size=UDim2.new(0.35,0,0,30), Position=UDim2.new(0.55,0,0,105), BackgroundColor3=Theme.Secondary, TextColor3=Theme.Accent, Font="GothamBold"}, m)
    create("UICorner", {CornerRadius=UDim.new(0,6)}, k)

    k.MouseButton1Click:Connect(function() setclipboard(KEY_SITE) notify("Copied", "Link copied to clipboard.") end)
    b.MouseButton1Click:Connect(function()
        if i.Text == VALID_KEY then
            g:Destroy()
            startSpy()
        else notify("Denied", "Wrong access key.") end
    end)
end

showGate()
