-- REMOTE SPY ULTIMATE V4 ⚡ - MOBILE OPTIMIZED
-- Features: Dynamic Tabs, Dragging, Resizing, Minimizing, & Stealth.
-- Full support for Mobile (Touch) and PC.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local ParentUI = (gethui and gethui()) or CoreGui

if CoreGui:FindFirstChild("RSpy_Ultimate_V4") then
    CoreGui:FindFirstChild("RSpy_Ultimate_V4"):Destroy()
end

-- Theme Configuration
local Theme = {
    Bg = Color3.fromRGB(12, 12, 15),
    Sidebar = Color3.fromRGB(18, 18, 22),
    Main = Color3.fromRGB(14, 14, 17),
    Accent = Color3.fromRGB(0, 180, 255),
    AccentSoft = Color3.fromRGB(0, 140, 220),
    Text = Color3.fromRGB(235, 235, 245),
    Muted = Color3.fromRGB(140, 140, 150),
    Border = Color3.fromRGB(40, 40, 48),
    RemoteEvent = Color3.fromRGB(0, 255, 150),
    RemoteFunction = Color3.fromRGB(255, 160, 0)
}

local Font = Enum.Font.Code

-- State Management
local State = {
    Groups = {},
    SelectedPath = nil,
    SelectedLog = nil,
    Visible = true,
    IsMinimized = false
}

-- UI Utilities
local function Create(cls, props)
    local inst = Instance.new(cls)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function MakeCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or UDim.new(0, 8)
    return c
end

local function MakeStroke(p, c, t)
    local s = Instance.new("UIStroke", p)
    s.Color = c or Theme.Border
    s.Thickness = t or 1.2
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

-- GUI Root
local ScreenGui = Create("ScreenGui", { Name = "RSpy_Ultimate_V4", Parent = ParentUI, IgnoreGuiInset = true })

-- Main Container
local MainFrame = Create("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    Size = UDim2.new(0, 750, 0, 450),
    Position = UDim2.new(0.5, -375, 0.5, -225),
    BackgroundColor3 = Theme.Bg,
    Active = true
})
MakeCorner(MainFrame)
MakeStroke(MainFrame, Theme.Accent, 1.5).Transparency = 0.4

-- Drag Handle Area (Header)
local Header = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0
})
MakeCorner(Header)
Create("Frame", { Size = UDim2.new(1, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = Header })

local Title = Create("TextLabel", {
    Parent = Header,
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "REMOTE SPY PRO V4 ⚡ [MOBILE]",
    TextColor3 = Theme.Accent,
    TextSize = 13,
    Font = Font,
    TextXAlignment = "Left"
})

local MinBtn = Create("TextButton", {
    Parent = Header, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0, 3),
    BackgroundTransparency = 1, Text = "−", TextColor3 = Theme.Muted, TextSize = 18, Font = Font
})

-- Resize Handle (Bottom Right)
local ResizeHandle = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(0, 20, 0, 20),
    Position = UDim2.new(1, -20, 1, -20),
    BackgroundTransparency = 1,
    ZIndex = 100
})
local ResizeIcon = Create("ImageLabel", {
    Parent = ResizeHandle,
    Size = UDim2.new(0, 15, 0, 15),
    Position = UDim2.new(0.5, -7, 0.5, -7),
    BackgroundTransparency = 1,
    Image = "rbxassetid://11417056038", -- Resize corner icon
    ImageColor3 = Theme.Muted
})

-- Sidebar (Unique Remotes)
local Sidebar = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(0, 200, 1, -55),
    Position = UDim2.new(0, 10, 0, 45),
    BackgroundColor3 = Theme.Sidebar
})
MakeCorner(Sidebar)
MakeStroke(Sidebar)

local SidebarScroll = Create("ScrollingFrame", {
    Parent = Sidebar, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5),
    BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent
})
local SidebarLayout = Create("UIListLayout", { Parent = SidebarScroll, Padding = UDim.new(0, 4) })

-- Middle Panel (Logs)
local LogsPanel = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(0, 260, 1, -55),
    Position = UDim2.new(0, 220, 0, 45),
    BackgroundColor3 = Theme.Main
})
MakeCorner(LogsPanel)
MakeStroke(LogsPanel)

local LogsScroll = Create("ScrollingFrame", {
    Parent = LogsPanel, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5),
    BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent
})
local LogsLayout = Create("UIListLayout", { Parent = LogsScroll, Padding = UDim.new(0, 4), SortOrder = "LayoutOrder" })

-- Inspector Panel (Right)
local Inspector = Create("Frame", {
    Parent = MainFrame,
    Size = UDim2.new(1, -500, 1, -55),
    Position = UDim2.new(0, 490, 0, 45),
    BackgroundColor3 = Theme.Sidebar
})
MakeCorner(Inspector)
MakeStroke(Inspector)

local InspectScroll = Create("ScrollingFrame", {
    Parent = Inspector, Size = UDim2.new(1, -15, 1, -50), Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent
})
local InspectBox = Create("TextBox", {
    Parent = InspectScroll, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    TextColor3 = Theme.Muted, TextSize = 11, Font = Font, TextXAlignment = "Left", TextYAlignment = "Top",
    TextWrapped = true, ReadOnly = true, MultiLine = true, ClearTextOnFocus = false, Text = "-- Click a log --"
})

local ActionBtn = Create("TextButton", {
    Parent = Inspector, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 1, -35),
    BackgroundColor3 = Theme.Bg, Text = "COPY RE-RUN CODE", TextColor3 = Theme.Text, Font = Font, TextSize = 10
})
MakeCorner(ActionBtn, UDim.new(0, 6))
MakeStroke(ActionBtn)

-- LOGIC: DRAGGING & RESIZING (MOBILE FRIENDLY)

local function EnableInteract(frame, toggleHandle, type)
    local active = false
    local dragInput, dragStart, startPos, startSize

    toggleHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            dragStart = input.Position
            startPos = frame.Position
            startSize = frame.Size
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    active = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if type == "drag" then
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            elseif type == "resize" then
                local newX = math.clamp(startSize.X.Offset + delta.X, 400, 1200)
                local newY = math.clamp(startSize.Y.Offset + delta.Y, 300, 800)
                frame.Size = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
end

EnableInteract(MainFrame, Header, "drag")
EnableInteract(MainFrame, ResizeHandle, "resize")

-- LOGIC: MINIMIZE
local FloatingIcon = Create("TextButton", {
    Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.4, 0),
    BackgroundColor3 = Theme.Accent, Text = "⚡", TextSize = 25, TextColor3 = Color3.new(1,1,1), Visible = false
})
MakeCorner(FloatingIcon, UDim.new(1, 0))
MakeStroke(FloatingIcon, Color3.new(1,1,1), 2)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingIcon.Visible = true
end)
FloatingIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatingIcon.Visible = false
end)

-- LOGIC: RENDERING & CAPTURING

local function GetRemotePath(obj)
    local p = obj.Name; local cur = obj.Parent
    while cur and cur ~= game do p = cur.Name .. "." .. p; cur = cur.Parent end
    return p
end

local function RenderHistory(path)
    for _, v in pairs(LogsScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local group = State.Groups[path]
    if not group then return end
    for i, log in ipairs(group.Logs) do
        local b = Create("TextButton", {
            Parent = LogsScroll, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Theme.Bg,
            Text = "  [" .. log.Time .. "] Call #" .. i, TextColor3 = Theme.Text, Font = Font,
            TextSize = 11, TextXAlignment = "Left", LayoutOrder = -i
        })
        MakeCorner(b, UDim.new(0, 4))
        MakeStroke(b)
        b.MouseButton1Click:Connect(function()
            State.SelectedLog = log
            State.SelectedPath = path
            local s = string.format("-- %s --\nPath: %s\nTime: %s\n\n-- ARGS --\n", log.Type:upper(), path, log.Time)
            for j, arg in ipairs(log.Args) do s = s .. string.format("[%d] (%s) = %s\n", j, typeof(arg), Serialize(arg)) end
            s = s .. "\n-- STACK --\n" .. log.Stack
            InspectBox.Text = s; InspectBox.TextColor3 = Theme.Text
            InspectScroll.CanvasSize = UDim2.new(0, 0, 0, InspectBox.TextBounds.Y + 20)
        end)
    end
    LogsScroll.CanvasSize = UDim2.new(0,0,0,LogsLayout.AbsoluteContentSize.Y + 10)
end

local function LogCapture(remote, args, isFunc)
    pcall(function()
        local path = GetRemotePath(remote)
        if not State.Groups[path] then
            State.Groups[path] = { Name = remote.Name, Type = (isFunc and "RemoteFunction" or "RemoteEvent"), Logs = {} }
            local b = Create("TextButton", {
                Parent = SidebarScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Bg,
                Text = "  " .. remote.Name, TextColor3 = isFunc and Theme.RemoteFunction or Theme.RemoteEvent,
                Font = Font, TextSize = 11, TextXAlignment = "Left"
            })
            MakeCorner(b)
            MakeStroke(b)
            b.MouseButton1Click:Connect(function() State.SelectedPath = path; RenderHistory(path) end)
            SidebarScroll.CanvasSize = UDim2.new(0,0,0,SidebarLayout.AbsoluteContentSize.Y + 10)
        end
        local log = { Time = os.date("%X"), Args = args, Type = State.Groups[path].Type, Stack = debug.traceback() }
        table.insert(State.Groups[path].Logs, log)
        if #State.Groups[path].Logs > 50 then table.remove(State.Groups[path].Logs, 1) end
        if State.SelectedPath == path then RenderHistory(path) end
    end)
end

-- HOOKING CORE
local mt = getrawmetatable(game)
local oldNC = mt.__namecall
local oldIdx = mt.__index
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local m = getnamecallmethod()
    if (m == "FireServer" or m == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        task.spawn(LogCapture, self, {...}, m == "InvokeServer")
    end
    return oldNC(self, ...)
end)
mt.__index = newcclosure(function(self, k)
    if (k == "FireServer" or k == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        return newcclosure(function(rem, ...)
            task.spawn(LogCapture, rem, {...}, k == "InvokeServer")
            return oldIdx(rem, k)(rem, ...)
        end)
    end
    return oldIdx(self, k)
end)
setreadonly(mt, true)

ActionBtn.MouseButton1Click:Connect(function()
    if State.SelectedLog and setclipboard then
        local log = State.SelectedLog
        local s = string.format("-- Remote Spy v4\nlocal remote = game.%s\nlocal args = {\n", State.SelectedPath)
        for _, v in ipairs(log.Args) do s = s .. "    " .. Serialize(v) .. ",\n" end
        s = s .. "}\n" .. (log.Type == "RemoteFunction" and "remote:InvokeServer" or "remote:FireServer") .. "(unpack(args))"
        setclipboard(s)
    end
end)

print("[REMOTE SPY V4] Mobile-Optimized Active.")
