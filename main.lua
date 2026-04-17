-- REMOTE SPY ULTIMATE V3 ⚡ - DYNAMIC GROUPING
-- Grouped logs by unique Remote for maximum organization.
-- Persistent, Stealth, and Highly Organized.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local ParentUI = (gethui and gethui()) or CoreGui

if CoreGui:FindFirstChild("RSpy_Ultimate_V3") then
    CoreGui:FindFirstChild("RSpy_Ultimate_V3"):Destroy()
end

-- Design
local Theme = {
    Bg = Color3.fromRGB(13, 13, 15),
    Sidebar = Color3.fromRGB(20, 20, 24),
    Main = Color3.fromRGB(15, 15, 18),
    Accent = Color3.fromRGB(0, 200, 255),
    AccentSecondary = Color3.fromRGB(0, 150, 220),
    Text = Color3.fromRGB(230, 230, 240),
    Muted = Color3.fromRGB(140, 140, 155),
    Border = Color3.fromRGB(35, 35, 42),
    RemoteEvent = Color3.fromRGB(0, 255, 170),
    RemoteFunction = Color3.fromRGB(255, 170, 0)
}

local Font = Enum.Font.Code

-- State Management
local State = {
    Groups = {}, -- { [Path] = { Name, Type, Logs = { ... } } }
    SelectedPath = nil,
    SelectedLog = nil,
    TotalFired = 0,
    Visible = true
}

-- Helpers
local function Create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function MakeCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or UDim.new(0, 7)
    return c
end

local function MakeStroke(p, c, t)
    local s = Instance.new("UIStroke", p)
    s.Color = c or Theme.Border
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function Serialize(val, seen)
    seen = seen or {}
    local t = typeof(val)
    if t == "table" then
        if seen[val] then return "{RECURSIVE}" end
        seen[val] = true
        local s = "{"
        local first = true
        for k, v in pairs(val) do
            if not first then s = s .. ", " end
            s = s .. "[" .. Serialize(k, seen) .. "] = " .. Serialize(v, seen)
            first = false
        end
        return s .. "}"
    elseif t == "string" then return '"' .. val .. '"'
    elseif t == "Instance" then return val:GetFullName()
    elseif t == "Vector3" then return string.format("Vector3.new(%.2f, %.2f, %.2f)", val.X, val.Y, val.Z)
    elseif t == "CFrame" then return "CFrame.new(...)"
    else return tostring(val) end
end

-- UI Structure
local ScreenGui = Create("ScreenGui", { Name = "RSpy_Ultimate_V3", Parent = ParentUI, IgnoreGuiInset = true })
local MainFrame = Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 800, 0, 480),
    Position = UDim2.new(0.5, -400, 0.5, -240),
    BackgroundColor3 = Theme.Bg,
    Active = true
})
MakeCorner(MainFrame, UDim.new(0, 10))
MakeStroke(MainFrame, Theme.Accent, 1.2).Transparency = 0.5

-- [SIDEBAR: Remote List]
local Sidebar = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(0, 220, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Theme.Sidebar
})
MakeCorner(Sidebar)
MakeStroke(Sidebar)

local SidebarTitle = Create("TextLabel", {
    Parent = Sidebar, Size = UDim2.new(1, 0, 0, 30), Text = " REMOTES DETECTED",
    TextColor3 = Theme.Accent, Font = Font, TextSize = 12, TextXAlignment = "Left", BackgroundTransparency = 1
})

local SidebarScroll = Create("ScrollingFrame", {
    Parent = Sidebar, Size = UDim2.new(1, -10, 1, -40), Position = UDim2.new(0, 5, 0, 35),
    BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent
})
local SidebarLayout = Create("UIListLayout", { Parent = SidebarScroll, Padding = UDim.new(0, 4) })

-- [LOGS PANEL: Specific Remote History]
local LogsPanel = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(0, 280, 1, -20),
    Position = UDim2.new(0, 240, 0, 10),
    BackgroundColor3 = Theme.Main
})
MakeCorner(LogsPanel)
MakeStroke(LogsPanel)

local LogsTitle = Create("TextLabel", {
    Parent = LogsPanel, Size = UDim2.new(1, 0, 0, 30), Text = " HISTORY",
    TextColor3 = Theme.Text, Font = Font, TextSize = 12, TextXAlignment = "Center", BackgroundTransparency = 1
})

local LogsScroll = Create("ScrollingFrame", {
    Parent = LogsPanel, Size = UDim2.new(1, -10, 1, -40), Position = UDim2.new(0, 5, 0, 35),
    BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent
})
local LogsLayout = Create("UIListLayout", { Parent = LogsScroll, Padding = UDim.new(0, 4), SortOrder = "LayoutOrder" })

-- [INSPECTOR: Data View]
local Inspector = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, -540, 1, -20),
    Position = UDim2.new(0, 530, 0, 10),
    BackgroundColor3 = Theme.Sidebar
})
MakeCorner(Inspector)
MakeStroke(Inspector)

local InspectScroll = Create("ScrollingFrame", {
    Parent = Inspector, Size = UDim2.new(1, -20, 1, -60), Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent
})
local InspectBox = Create("TextBox", {
    Parent = InspectScroll, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    TextColor3 = Theme.Muted, TextSize = 12, Font = Font, TextXAlignment = "Left", TextYAlignment = "Top",
    TextWrapped = true, ReadOnly = true, MultiLine = true, ClearTextOnFocus = false, Text = "-- Click a log --"
})

-- Actions
local ActionFrame = Create("Frame", {
    Parent = Inspector, Size = UDim2.new(1, -20, 0, 35), Position = UDim2.new(0, 10, 1, -45), BackgroundTransparency = 1
})
local function AddActionBtn(txt, cb, col)
    local b = Create("TextButton", {
        Parent = ActionFrame, Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = col or Theme.Bg,
        Text = txt, TextColor3 = Theme.Text, Font = Font, TextSize = 11
    })
    MakeCorner(b, UDim.new(0, 6))
    MakeStroke(b)
    b.MouseButton1Click:Connect(cb)
    return b
end

AddActionBtn("COPY CODE", function()
    if State.SelectedLog and setclipboard then
        local log = State.SelectedLog
        local s = string.format("-- Remote Spy v3\nlocal remote = %s\nlocal args = {\n", "game." .. State.SelectedPath)
        for _, v in ipairs(log.Args) do s = s .. "    " .. Serialize(v) .. ",\n" end
        s = s .. "}\n" .. (log.Type == "RemoteFunction" and "remote:InvokeServer" or "remote:FireServer") .. "(unpack(args))"
        setclipboard(s)
    end
end, Theme.AccentSecondary)

-- RENDERING LOGIC

local function UpdateInspector(log)
    State.SelectedLog = log
    local s = string.format("-- %s --\n", log.Type:upper())
    s = s .. "Time: " .. log.Time .. "\n\n-- ARGS --\n"
    for i, v in ipairs(log.Args) do s = s .. string.format("[%d] (%s) = %s\n", i, typeof(v), Serialize(v)) end
    s = s .. "\n-- STACK --\n" .. log.Stack
    InspectBox.Text = s
    InspectBox.TextColor3 = Theme.Text
    InspectScroll.CanvasSize = UDim2.new(0, 0, 0, InspectBox.TextBounds.Y + 20)
end

local function RenderHistory(path)
    for _, v in pairs(LogsScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local group = State.Groups[path]
    if not group then return end
    
    LogsTitle.Text = group.Name:upper() .. " HISTORY"
    
    for i, log in ipairs(group.Logs) do
        local b = Create("TextButton", {
            Parent = LogsScroll, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Bg,
            Text = "  [" .. log.Time .. "] Call #" .. i, TextColor3 = Theme.Text, Font = Font,
            TextSize = 11, TextXAlignment = "Left", LayoutOrder = -i
        })
        MakeCorner(b)
        MakeStroke(b)
        b.MouseButton1Click:Connect(function() UpdateInspector(log) end)
    end
    LogsScroll.CanvasSize = UDim2.new(0,0,0,LogsLayout.AbsoluteContentSize.Y + 10)
end

local function GetRemotePath(obj)
    local p = obj.Name
    local cur = obj.Parent
    while cur and cur ~= game do
        p = cur.Name .. "." .. p
        cur = cur.Parent
    end
    return p
end

local function LogCapture(remote, args, isFunc)
    pcall(function()
        local path = GetRemotePath(remote)
        if not State.Groups[path] then
            -- Create Sidebar Entry
            State.Groups[path] = { Name = remote.Name, Type = (isFunc and "RemoteFunction" or "RemoteEvent"), Logs = {} }
            
            local b = Create("TextButton", {
                Parent = SidebarScroll, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Theme.Bg,
                Text = "  " .. remote.Name, TextColor3 = isFunc and Theme.RemoteFunction or Theme.RemoteEvent,
                Font = Font, TextSize = 11, TextXAlignment = "Left"
            })
            MakeCorner(b)
            MakeStroke(b)
            
            b.MouseButton1Click:Connect(function()
                State.SelectedPath = path
                RenderHistory(path)
            end)
            SidebarScroll.CanvasSize = UDim2.new(0,0,0,SidebarLayout.AbsoluteContentSize.Y + 10)
        end
        
        local log = {
            Time = os.date("%X"),
            Args = args,
            Type = State.Groups[path].Type,
            Stack = debug.traceback()
        }
        
        table.insert(State.Groups[path].Logs, log)
        if #State.Groups[path].Logs > 100 then table.remove(State.Groups[path].Logs, 1) end
        
        if State.SelectedPath == path then
            RenderHistory(path)
        end
    end)
end

-- HOOKING
local mt = getrawmetatable(game)
local oldNC = mt.__namecall
local oldIdx = mt.__index
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local m = getnamecallmethod()
    if (m == "FireServer" or m == "InvokeServer") then
        task.spawn(LogCapture, self, {...}, m == "InvokeServer")
    end
    return oldNC(self, ...)
end)

mt.__index = newcclosure(function(self, k)
    if (k == "FireServer" or k == "InvokeServer") then
        if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
            return newcclosure(function(rem, ...)
                task.spawn(LogCapture, rem, {...}, k == "InvokeServer")
                return oldIdx(rem, k)(rem, ...)
            end)
        end
    end
    return oldIdx(self, k)
end)
setreadonly(mt, true)

-- Dragging
local function EnableDrag(obj)
    local dragToggle, dragInput, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true; dragStart = input.Position; startPos = obj.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end end)
end
EnableDrag(MainFrame)

print("[REMOTE SPY V3] Multi-Tab Grouping Active.")
