--[[
    PulseUI Library v2.0
    Made by Torch — Extended & Fixed
    
    FIXES:
    - Hover ทำให้ component ดำค้าง → ใช้ InputBegan/InputEnded ถูกต้อง + reset สี
    - Keybind leak → disconnect หลัง detect ครั้งแรก
    - Slider loop ไม่มี timeout → เพิ่ม guard
    - Global variable รั่ว → เพิ่ม local ทุกตัว
    
    NEW FEATURES:
    - ปุ่มแดง/ส้ม/เขียว ทำงานถูกต้อง (ปิด/พับ/ขยาย)
    - ฟอนต์ใหญ่ขึ้น อ่านง่าย ชัดเจน
    - Tab ใช้ฟอนต์ bold
    - ปรับขนาด UI ได้อิสระทุกทิศทาง (resize handles)
    - เลือกสีธีมได้ + Preset themes
    - หน้าตาใหม่ เท่ขึ้น
]]

--// Wait for game load
if not game:IsLoaded() then game.Loaded:Wait() end

--// Services
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local InsertService= game:GetService("InsertService")
local HttpService  = game:GetService("HttpService")

local LocalPlayer  = Players.LocalPlayer
local Mouse        = LocalPlayer:GetMouse()
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

--// Helpers
local function Tween(obj, t, props, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function SetProps(obj, props)
    for k,v in next, props do obj[k] = v end
    return obj
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function MakeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Color3.fromRGB(60,60,60)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    return s
end

local function MakePadding(parent, t, b, l, r)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    return p
end

local function MakeList(parent, dir, padding, sort)
    local l = Instance.new("UIListLayout", parent)
    l.FillDirection  = dir or Enum.FillDirection.Vertical
    l.SortOrder      = sort or Enum.SortOrder.LayoutOrder
    l.Padding        = UDim.new(0, padding or 0)
    return l
end

--// Theme Presets
local Presets = {
    Dark = {
        Primary      = Color3.fromRGB(18, 18, 22),
        Secondary    = Color3.fromRGB(24, 24, 30),
        Sidebar      = Color3.fromRGB(20, 20, 26),
        Component    = Color3.fromRGB(32, 32, 40),
        Hover        = Color3.fromRGB(42, 42, 52),
        Active       = Color3.fromRGB(50, 50, 62),
        Title        = Color3.fromRGB(245, 245, 250),
        Subtitle     = Color3.fromRGB(170, 170, 185),
        Muted        = Color3.fromRGB(100, 100, 115),
        Outline      = Color3.fromRGB(45, 45, 58),
        Accent       = Color3.fromRGB(130, 100, 255),
        AccentHover  = Color3.fromRGB(150, 120, 255),
        Success      = Color3.fromRGB(80, 200, 120),
        Warning      = Color3.fromRGB(255, 180, 50),
        Danger       = Color3.fromRGB(255, 80, 80),
    },
    Midnight = {
        Primary      = Color3.fromRGB(10, 12, 20),
        Secondary    = Color3.fromRGB(14, 17, 28),
        Sidebar      = Color3.fromRGB(12, 14, 24),
        Component    = Color3.fromRGB(22, 26, 42),
        Hover        = Color3.fromRGB(30, 35, 55),
        Active       = Color3.fromRGB(38, 44, 68),
        Title        = Color3.fromRGB(220, 230, 255),
        Subtitle     = Color3.fromRGB(140, 155, 200),
        Muted        = Color3.fromRGB(80, 90, 130),
        Outline      = Color3.fromRGB(35, 42, 70),
        Accent       = Color3.fromRGB(90, 130, 255),
        AccentHover  = Color3.fromRGB(110, 150, 255),
        Success      = Color3.fromRGB(70, 190, 140),
        Warning      = Color3.fromRGB(255, 165, 30),
        Danger       = Color3.fromRGB(220, 70, 70),
    },
    Rose = {
        Primary      = Color3.fromRGB(20, 14, 16),
        Secondary    = Color3.fromRGB(26, 18, 21),
        Sidebar      = Color3.fromRGB(22, 15, 18),
        Component    = Color3.fromRGB(36, 26, 30),
        Hover        = Color3.fromRGB(48, 34, 40),
        Active       = Color3.fromRGB(58, 42, 48),
        Title        = Color3.fromRGB(255, 240, 244),
        Subtitle     = Color3.fromRGB(200, 165, 175),
        Muted        = Color3.fromRGB(130, 95, 108),
        Outline      = Color3.fromRGB(60, 40, 48),
        Accent       = Color3.fromRGB(230, 80, 120),
        AccentHover  = Color3.fromRGB(245, 100, 140),
        Success      = Color3.fromRGB(80, 200, 130),
        Warning      = Color3.fromRGB(255, 175, 50),
        Danger       = Color3.fromRGB(255, 80, 80),
    },
    Nord = {
        Primary      = Color3.fromRGB(46, 52, 64),
        Secondary    = Color3.fromRGB(59, 66, 82),
        Sidebar      = Color3.fromRGB(46, 52, 64),
        Component    = Color3.fromRGB(67, 76, 94),
        Hover        = Color3.fromRGB(76, 86, 106),
        Active       = Color3.fromRGB(86, 96, 118),
        Title        = Color3.fromRGB(236, 239, 244),
        Subtitle     = Color3.fromRGB(194, 201, 216),
        Muted        = Color3.fromRGB(129, 141, 167),
        Outline      = Color3.fromRGB(76, 86, 106),
        Accent       = Color3.fromRGB(136, 192, 208),
        AccentHover  = Color3.fromRGB(156, 210, 226),
        Success      = Color3.fromRGB(163, 190, 140),
        Warning      = Color3.fromRGB(235, 203, 139),
        Danger       = Color3.fromRGB(191, 97, 106),
    },
}

--// State
local T = Presets.Dark  -- active theme (mutable reference)
local SavedBinds  = {}
local SavedConfig = {}
local Library     = {}

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PulseUI_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
xpcall(function() ScreenGui.Parent = game:GetService("CoreGui") end,
       function() ScreenGui.Parent = PlayerGui end)

-- Notification container
local NotifHolder = Instance.new("Frame", ScreenGui)
NotifHolder.Name = "Notifications"
NotifHolder.Size = UDim2.new(0, 280, 1, 0)
NotifHolder.Position = UDim2.new(1, -290, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.AnchorPoint = Vector2.new(0, 0)
MakeList(NotifHolder, Enum.FillDirection.Vertical, 8)
local NotifPad = Instance.new("UIPadding", NotifHolder)
NotifPad.PaddingTop = UDim.new(0, 12)
NotifPad.PaddingRight = UDim.new(0, 0)

-- ============================================================
--  DRAG
-- ============================================================
local function MakeDraggable(handle, target)
    local dragging, startMouse, startPos
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging    = true
            startMouse  = Vector2.new(inp.Position.X, inp.Position.Y)
            startPos    = target.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(inp.Position.X, inp.Position.Y) - startMouse
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ============================================================
--  RESIZE (all 4 edges + corners)
-- ============================================================
local function MakeResizable(window, minW, minH)
    minW = minW or 380
    minH = minH or 260

    local handles = {
        -- { name, cursor, anchorX, anchorY, resizeX, resizeY }
        { "Right",       "SizeEW",   1, 0.5,  1,  0 },
        { "Bottom",      "SizeNS",   0.5, 1,  0,  1 },
        { "Left",        "SizeEW",   0, 0.5, -1,  0 },
        { "Top",         "SizeNS",   0.5, 0,  0, -1 },
        { "BottomRight", "SizeNWSE", 1, 1,    1,  1 },
        { "BottomLeft",  "SizeSW",   0, 1,   -1,  1 },
        { "TopRight",    "SizeNE",   1, 0,    1, -1 },
        { "TopLeft",     "SizeNWSE", 0, 0,   -1, -1 },
    }

    local EDGE = 6

    for _, h in ipairs(handles) do
        local name, _, ax, ay, rx, ry = table.unpack(h)
        local frame = Instance.new("Frame", window)
        frame.Name = "Resize_"..name
        frame.BackgroundTransparency = 1
        frame.ZIndex = 20

        if rx ~= 0 and ry == 0 then
            -- horizontal edge
            frame.Size = UDim2.new(0, EDGE, 1, -20)
            frame.AnchorPoint = Vector2.new(ax, 0.5)
            frame.Position = UDim2.new(ax, 0, 0.5, 0)
        elseif ry ~= 0 and rx == 0 then
            -- vertical edge
            frame.Size = UDim2.new(1, -20, 0, EDGE)
            frame.AnchorPoint = Vector2.new(0.5, ay)
            frame.Position = UDim2.new(0.5, 0, ay, 0)
        else
            -- corner
            frame.Size = UDim2.new(0, 14, 0, 14)
            frame.AnchorPoint = Vector2.new(ax, ay)
            frame.Position = UDim2.new(ax, 0, ay, 0)
        end

        local resizing = false
        local startMouse, startSize, startPos

        frame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing   = true
                startMouse = Vector2.new(Mouse.X, Mouse.Y)
                startSize  = Vector2.new(window.AbsoluteSize.X, window.AbsoluteSize.Y)
                startPos   = window.Position
            end
        end)

        UIS.InputChanged:Connect(function(inp)
            if resizing and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local dm = Vector2.new(Mouse.X, Mouse.Y) - startMouse
                local nw = math.max(minW, startSize.X + dm.X * rx)
                local nh = math.max(minH, startSize.Y + dm.Y * ry)

                local dw = nw - startSize.X
                local dh = nh - startSize.Y

                window.Size = UDim2.new(0, nw, 0, nh)

                -- adjust position for left/top handles
                local px = startPos.X.Offset + (rx == -1 and -dw or 0)
                local py = startPos.Y.Offset + (ry == -1 and -dh or 0)
                window.Position = UDim2.new(startPos.X.Scale, px, startPos.Y.Scale, py)
            end
        end)

        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
    end
end

-- ============================================================
--  COMPONENT HOVER ANIMATION  (BUG FIX: สีดำค้าง)
-- ============================================================
local function AddHover(btn, normalColor, hoverColor)
    -- ใช้ MouseEnter/MouseLeave แทน InputBegan/InputEnded
    -- เพื่อให้ reset ได้แน่นอนแม้เมาส์ออกอย่างรวดเร็ว
    btn.MouseEnter:Connect(function()
        Tween(btn, .15, { BackgroundColor3 = hoverColor or T.Hover })
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, .15, { BackgroundColor3 = normalColor or T.Component })
    end)
    -- กันกรณีที่ hold click แล้วออก
    btn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            -- ตรวจว่าเมาส์ยังอยู่บน button ไหม
            local abs = btn.AbsolutePosition
            local sz  = btn.AbsoluteSize
            local mx, my = Mouse.X, Mouse.Y
            if mx < abs.X or mx > abs.X + sz.X or my < abs.Y or my > abs.Y + sz.Y then
                Tween(btn, .15, { BackgroundColor3 = normalColor or T.Component })
            end
        end
    end)
end

-- ============================================================
--  BUILD COMPONENT ROW BASE
-- ============================================================
local function MakeRow(parent, height)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1, 0, 0, height or 44)
    row.BackgroundColor3 = T.Component
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false  -- FIX: ปิด auto color ของ Roblox
    MakeCorner(row, 6)
    MakePadding(row, 0, 0, 14, 14)
    AddHover(row, T.Component, T.Hover)
    return row
end

local function MakeLabel(parent, text, size, color, bold, xalign)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.TextSize = size or 14
    l.TextColor3 = color or T.Title
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    return l
end

local function MakeTitleDesc(row, title, desc)
    -- Title label
    local tl = MakeLabel(row, title, 15, T.Title, true)
    tl.Size = UDim2.new(1, -80, 0, 18)
    tl.Position = UDim2.new(0, 14, 0, 8)

    -- Description label
    local dl = MakeLabel(row, desc, 12, T.Subtitle, false)
    dl.Size = UDim2.new(1, -80, 0, 14)
    dl.Position = UDim2.new(0, 14, 0, 26)

    return tl, dl
end

-- ============================================================
--  NOTIFICATION
-- ============================================================
local function ShowNotif(title, desc, duration, ntype)
    local accent = (ntype == "error" and T.Danger)
                or (ntype == "success" and T.Success)
                or (ntype == "warning" and T.Warning)
                or T.Accent

    local card = Instance.new("Frame", NotifHolder)
    card.Name = "Notif"
    card.Size = UDim2.new(1, 0, 0, 64)
    card.BackgroundColor3 = T.Secondary
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    MakeCorner(card, 8)
    MakeStroke(card, T.Outline, 1)

    -- accent bar
    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    MakeCorner(bar, 3)

    local tl = MakeLabel(card, title, 14, T.Title, true)
    tl.Size = UDim2.new(1, -20, 0, 18)
    tl.Position = UDim2.new(0, 14, 0, 10)

    local dl = MakeLabel(card, desc, 12, T.Subtitle)
    dl.Size = UDim2.new(1, -20, 0, 14)
    dl.Position = UDim2.new(0, 14, 0, 30)

    -- timer
    local timer = Instance.new("Frame", card)
    timer.Size = UDim2.new(1, 0, 0, 2)
    timer.AnchorPoint = Vector2.new(0, 1)
    timer.Position = UDim2.new(0, 0, 1, 0)
    timer.BackgroundColor3 = accent
    timer.BorderSizePixel = 0

    -- animate in
    card.GroupTransparency = 1
    Tween(card, .2, { GroupTransparency = 0 })
    Tween(timer, duration or 3, { Size = UDim2.new(0, 0, 0, 2) })

    task.delay(duration or 3, function()
        Tween(card, .2, { GroupTransparency = 1 })
        task.wait(.25)
        card:Destroy()
    end)
end

-- ============================================================
--  THEME PICKER POPUP
-- ============================================================
local function MakeThemePicker(window, onApply)
    local overlay = Instance.new("Frame", window)
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 50

    local popup = Instance.new("Frame", overlay)
    popup.Size = UDim2.new(0, 320, 0, 280)
    popup.AnchorPoint = Vector2.new(0.5, 0.5)
    popup.Position = UDim2.new(0.5, 0, 0.5, 0)
    popup.BackgroundColor3 = T.Secondary
    popup.BorderSizePixel = 0
    popup.ZIndex = 51
    MakeCorner(popup, 10)
    MakeStroke(popup, T.Outline, 1)

    local hdr = MakeLabel(popup, "🎨  Choose Theme", 16, T.Title, true)
    hdr.Size = UDim2.new(1, -20, 0, 24)
    hdr.Position = UDim2.new(0, 14, 0, 12)

    local closeBtn = Instance.new("TextButton", popup)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = T.Subtitle
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.ZIndex = 52
    closeBtn.MouseButton1Click:Connect(function() overlay:Destroy() end)

    local scroll = Instance.new("ScrollingFrame", popup)
    scroll.Size = UDim2.new(1, -20, 1, -56)
    scroll.Position = UDim2.new(0, 10, 0, 46)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = T.Outline
    scroll.BorderSizePixel = 0
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ZIndex = 52
    MakeList(scroll, Enum.FillDirection.Vertical, 8)

    local previewColors = {
        Dark     = Color3.fromRGB(130, 100, 255),
        Midnight = Color3.fromRGB(90, 130, 255),
        Rose     = Color3.fromRGB(230, 80, 120),
        Nord     = Color3.fromRGB(136, 192, 208),
    }

    for name, preset in next, Presets do
        local row = Instance.new("TextButton", scroll)
        row.Size = UDim2.new(1, 0, 0, 48)
        row.BackgroundColor3 = T.Component
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false
        row.ZIndex = 53
        MakeCorner(row, 6)
        AddHover(row, T.Component, T.Hover)

        local swatch = Instance.new("Frame", row)
        swatch.Size = UDim2.new(0, 28, 0, 28)
        swatch.AnchorPoint = Vector2.new(0, 0.5)
        swatch.Position = UDim2.new(0, 10, 0.5, 0)
        swatch.BackgroundColor3 = previewColors[name] or preset.Accent
        swatch.BorderSizePixel = 0
        swatch.ZIndex = 54
        MakeCorner(swatch, 6)

        local nl = MakeLabel(row, name, 14, T.Title, true)
        nl.Size = UDim2.new(1, -60, 0, 18)
        nl.Position = UDim2.new(0, 48, 0.5, -9)
        nl.ZIndex = 54

        row.MouseButton1Click:Connect(function()
            T = preset
            onApply(preset)
            overlay:Destroy()
            ShowNotif("Theme Changed", "Applied: " .. name, 2, "success")
        end)
    end
end

-- ============================================================
--  CREATE WINDOW
-- ============================================================
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local winTitle     = cfg.Title or "PulseUI"
    local winSize      = cfg.Size or UDim2.new(0, 560, 0, 380)
    local winTransp    = cfg.Transparency or 0
    local startTheme   = cfg.Theme or "Dark"
    local toggleKey    = cfg.MinimizeKeybind or Enum.KeyCode.RightShift

    -- Apply theme preset if string given
    if type(startTheme) == "string" and Presets[startTheme] then
        T = Presets[startTheme]
    elseif type(startTheme) == "table" then
        T = startTheme
    end

    -- ── Window frame ──────────────────────────────────────────
    local window = Instance.new("Frame", ScreenGui)
    window.Name = "Window"
    window.Size = winSize
    window.AnchorPoint = Vector2.new(0.5, 0.5)
    window.Position = UDim2.new(0.5, 0, 0.5, 0)
    window.BackgroundColor3 = T.Primary
    window.BorderSizePixel = 0
    window.ClipsDescendants = false
    MakeCorner(window, 10)
    MakeStroke(window, T.Outline, 1)

    -- drop shadow illusion
    local shadow = Instance.new("ImageLabel", window)
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, 10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = -1
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)

    -- ── Titlebar ─────────────────────────────────────────────
    local titlebar = Instance.new("Frame", window)
    titlebar.Name = "Titlebar"
    titlebar.Size = UDim2.new(1, 0, 0, 42)
    titlebar.BackgroundColor3 = T.Secondary
    titlebar.BorderSizePixel = 0
    MakeCorner(titlebar, 10)

    -- fix bottom corners of titlebar
    local tbfix = Instance.new("Frame", titlebar)
    tbfix.Size = UDim2.new(1, 0, 0.5, 0)
    tbfix.Position = UDim2.new(0, 0, 0.5, 0)
    tbfix.BackgroundColor3 = T.Secondary
    tbfix.BorderSizePixel = 0

    MakeDraggable(titlebar, window)

    -- traffic lights
    local lights = Instance.new("Frame", titlebar)
    lights.Size = UDim2.new(0, 60, 0, 16)
    lights.Position = UDim2.new(0, 14, 0.5, -8)
    lights.BackgroundTransparency = 1
    MakeList(lights, Enum.FillDirection.Horizontal, 8)

    local function MakeLight(color, parent)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 13, 0, 13)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        MakeCorner(btn, 99)
        return btn
    end

    local redBtn    = MakeLight(Color3.fromRGB(255, 95,  87),  lights)
    local yellowBtn = MakeLight(Color3.fromRGB(255, 189, 46),  lights)
    local greenBtn  = MakeLight(Color3.fromRGB(39,  201, 63),  lights)

    -- title text
    local titleLabel = MakeLabel(titlebar, winTitle, 15, T.Title, true, Enum.TextXAlignment.Center)
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)

    -- keybind hint bottom left
    local keybindHint = Instance.new("Frame", window)
    keybindHint.Size = UDim2.new(1, 0, 0, 28)
    keybindHint.AnchorPoint = Vector2.new(0, 1)
    keybindHint.Position = UDim2.new(0, 0, 1, 0)
    keybindHint.BackgroundColor3 = T.Secondary
    keybindHint.BorderSizePixel = 0
    MakeCorner(keybindHint, 10)
    local khfix = Instance.new("Frame", keybindHint)
    khfix.Size = UDim2.new(1, 0, 0.5, 0)
    khfix.Position = UDim2.new(0, 0, 0, 0)
    khfix.BackgroundColor3 = T.Secondary
    khfix.BorderSizePixel = 0

    local dot = Instance.new("Frame", keybindHint)
    dot.Size = UDim2.new(0, 7, 0, 7)
    dot.Position = UDim2.new(0, 12, 0.5, -3)
    dot.BackgroundColor3 = T.Accent
    dot.BorderSizePixel = 0
    MakeCorner(dot, 99)

    local khLabel = MakeLabel(keybindHint,
        tostring(toggleKey):gsub("Enum.KeyCode.", "") .. "  ·  Toggle visibility",
        11, T.Muted)
    khLabel.Size = UDim2.new(1, -30, 1, 0)
    khLabel.Position = UDim2.new(0, 24, 0, 0)

    -- ── Sidebar ───────────────────────────────────────────────
    local sidebar = Instance.new("Frame", window)
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 170, 1, -42)
    sidebar.Position = UDim2.new(0, 0, 0, 42)
    sidebar.BackgroundColor3 = T.Sidebar
    sidebar.BorderSizePixel = 0

    -- search box in sidebar
    local searchBox = Instance.new("Frame", sidebar)
    searchBox.Size = UDim2.new(1, -20, 0, 32)
    searchBox.Position = UDim2.new(0, 10, 0, 10)
    searchBox.BackgroundColor3 = T.Component
    searchBox.BorderSizePixel = 0
    MakeCorner(searchBox, 6)

    local searchIcon = MakeLabel(searchBox, "⌕", 14, T.Muted, false, Enum.TextXAlignment.Left)
    searchIcon.Size = UDim2.new(0, 20, 1, 0)
    searchIcon.Position = UDim2.new(0, 8, 0, 0)

    local searchInput = Instance.new("TextBox", searchBox)
    searchInput.Size = UDim2.new(1, -32, 1, 0)
    searchInput.Position = UDim2.new(0, 28, 0, 0)
    searchInput.BackgroundTransparency = 1
    searchInput.PlaceholderText = "Search controls..."
    searchInput.PlaceholderColor3 = T.Muted
    searchInput.Text = ""
    searchInput.TextColor3 = T.Title
    searchInput.Font = Enum.Font.Gotham
    searchInput.TextSize = 12
    searchInput.ClearTextOnFocus = false

    -- sidebar tab list
    local tabList = Instance.new("ScrollingFrame", sidebar)
    tabList.Name = "TabList"
    tabList.Size = UDim2.new(1, 0, 1, -60)
    tabList.Position = UDim2.new(0, 0, 0, 52)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.BorderSizePixel = 0
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    MakeList(tabList, Enum.FillDirection.Vertical, 2)
    MakePadding(tabList, 4, 4, 8, 8)

    -- ── Content area ──────────────────────────────────────────
    local contentArea = Instance.new("Frame", window)
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, -170, 1, -42)
    contentArea.Position = UDim2.new(0, 170, 0, 42)
    contentArea.BackgroundColor3 = T.Primary
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    MakeCorner(contentArea, 10)
    local cafix = Instance.new("Frame", contentArea)
    cafix.Size = UDim2.new(0.5, 0, 1, 0)
    cafix.Position = UDim2.new(0, 0, 0, 0)
    cafix.BackgroundColor3 = T.Primary
    cafix.BorderSizePixel = 0

    -- divider
    local divider = Instance.new("Frame", window)
    divider.Size = UDim2.new(0, 1, 1, -42)
    divider.Position = UDim2.new(0, 170, 0, 42)
    divider.BackgroundColor3 = T.Outline
    divider.BorderSizePixel = 0

    -- ── State ─────────────────────────────────────────────────
    local Options     = {}
    local tabs        = {}       -- { name = { btn, scroll } }
    local activeTab   = nil
    local visible     = true
    local minimized   = false
    local maximized   = false
    local savedSize   = winSize
    local savedPos    = window.Position

    MakeResizable(window, 380, 260)

    -- ── Traffic light actions ─────────────────────────────────
    -- RED: ปิด UI ทิ้งไปเลย
    redBtn.MouseButton1Click:Connect(function()
        Tween(window, .2, { GroupTransparency = 1 })
        task.wait(.22)
        window:Destroy()
        ScreenGui:Destroy()
    end)

    -- YELLOW: พับ (ย่อเหลือแค่ titlebar)
    yellowBtn.MouseButton1Click:Connect(function()
        if minimized then
            minimized = false
            sidebar.Visible = true
            contentArea.Visible = true
            divider.Visible = true
            keybindHint.Visible = true
            Tween(window, .25, { Size = savedSize })
        else
            minimized = true
            savedSize = window.Size
            sidebar.Visible = false
            contentArea.Visible = false
            divider.Visible = false
            keybindHint.Visible = false
            Tween(window, .25, { Size = UDim2.new(0, window.AbsoluteSize.X, 0, 42) })
        end
    end)

    -- GREEN: ขยายเต็มจอ / กลับ
    greenBtn.MouseButton1Click:Connect(function()
        if maximized then
            maximized = false
            Tween(window, .25, { Size = savedSize, Position = savedPos })
        else
            maximized = true
            savedSize = window.Size
            savedPos  = window.Position
            Tween(window, .25, {
                Size = UDim2.new(0, workspace.CurrentCamera.ViewportSize.X - 40,
                                 0, workspace.CurrentCamera.ViewportSize.Y - 40),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
        end
    end)

    -- Keybind toggle visibility
    UIS.InputBegan:Connect(function(inp, focused)
        if not focused and inp.KeyCode == toggleKey then
            visible = not visible
            window.Visible = visible
        end
    end)

    -- ── Tab helpers ───────────────────────────────────────────
    local function SetActiveTab(name)
        for n, data in next, tabs do
            local isActive = (n == name)
            -- sidebar button
            if isActive then
                Tween(data.btn, .2, { BackgroundColor3 = T.Active })
                data.btn.label.TextColor3 = T.Title
                data.btn.dot.BackgroundColor3 = T.Accent
                data.btn.dot.Visible = true
            else
                Tween(data.btn, .2, { BackgroundColor3 = Color3.fromRGB(0,0,0) })
                data.btn.BackgroundTransparency = 1
                data.btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
                Tween(data.btn, .2, { BackgroundColor3 = T.Sidebar })
                data.btn.label.TextColor3 = T.Subtitle
                data.btn.dot.Visible = false
            end
            -- content
            data.scroll.Visible = isActive
        end
        activeTab = name
    end

    -- ── AddTab ────────────────────────────────────────────────
    function Options:AddTab(cfg2)
        local name = cfg2.Title or "Tab"
        local icon = cfg2.Icon or ""

        -- sidebar button
        local btn = Instance.new("TextButton", tabList)
        btn.Name = name
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = T.Sidebar
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        MakeCorner(btn, 6)

        -- active dot
        local dot = Instance.new("Frame", btn)
        dot.Name = "dot"
        dot.Size = UDim2.new(0, 3, 0.6, 0)
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.Position = UDim2.new(0, 0, 0.5, 0)
        dot.BackgroundColor3 = T.Accent
        dot.BorderSizePixel = 0
        dot.Visible = false
        MakeCorner(dot, 3)
        btn.dot = dot

        -- icon
        if icon ~= "" then
            local ico = Instance.new("ImageLabel", btn)
            ico.Size = UDim2.new(0, 18, 0, 18)
            ico.AnchorPoint = Vector2.new(0, 0.5)
            ico.Position = UDim2.new(0, 12, 0.5, 0)
            ico.BackgroundTransparency = 1
            ico.Image = icon
            ico.ImageColor3 = T.Subtitle
        end

        local lbl = MakeLabel(btn, name, 14, T.Subtitle, true)
        lbl.Name = "label"
        lbl.Size = UDim2.new(1, -40, 1, 0)
        lbl.Position = UDim2.new(0, (icon ~= "" and 36 or 14), 0, 0)
        btn.label = lbl

        -- hover (not active)
        btn.MouseEnter:Connect(function()
            if activeTab ~= name then
                Tween(btn, .15, { BackgroundColor3 = T.Component })
            end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= name then
                Tween(btn, .15, { BackgroundColor3 = T.Sidebar })
            end
        end)

        -- content scroll
        local scroll = Instance.new("ScrollingFrame", contentArea)
        scroll.Name = name
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = T.Outline
        scroll.BorderSizePixel = 0
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.Visible = false
        MakeList(scroll, Enum.FillDirection.Vertical, 6)
        MakePadding(scroll, 10, 10, 10, 10)

        tabs[name] = { btn = btn, scroll = scroll }

        btn.MouseButton1Click:Connect(function()
            SetActiveTab(name)
        end)

        -- activate first tab automatically
        if not activeTab then SetActiveTab(name) end

        -- search filter
        searchInput:GetPropertyChangedSignal("Text"):Connect(function()
            local q = searchInput.Text:lower()
            if q == "" then
                btn.Visible = true
                return
            end
            btn.Visible = name:lower():find(q, 1, true) ~= nil
        end)

        return scroll
    end

    -- ── AddSection ────────────────────────────────────────────
    function Options:AddSection(cfg2)
        local lbl = MakeLabel(cfg2.Tab, cfg2.Name, 11, T.Muted, true)
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.LayoutOrder = 0
        MakePadding(lbl, 4, 0, 4, 0)
    end

    -- ── AddButton ─────────────────────────────────────────────
    function Options:AddButton(cfg2)
        local row = MakeRow(cfg2.Tab, 52)

        local tl, dl = MakeTitleDesc(row, cfg2.Title, cfg2.Description)

        local arrow = MakeLabel(row, "›", 20, T.Muted, true, Enum.TextXAlignment.Right)
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -30, 0, 0)

        row.MouseButton1Click:Connect(function()
            Tween(row, .08, { BackgroundColor3 = T.Active })
            task.delay(.1, function() Tween(row, .15, { BackgroundColor3 = T.Component }) end)
            cfg2.Callback()
        end)
    end

    -- ── AddToggle ─────────────────────────────────────────────
    function Options:AddToggle(cfg2)
        local row = MakeRow(cfg2.Tab, 52)
        local value = cfg2.Default or false
        SavedConfig[cfg2.Title] = value

        MakeTitleDesc(row, cfg2.Title, cfg2.Description)

        -- pill toggle
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0, 40, 0, 22)
        pill.AnchorPoint = Vector2.new(1, 0.5)
        pill.Position = UDim2.new(1, -14, 0.5, 0)
        pill.BackgroundColor3 = T.Component
        pill.BorderSizePixel = 0
        MakeCorner(pill, 99)

        local circle = Instance.new("Frame", pill)
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.Position = UDim2.new(0, 11, 0.5, 0)
        circle.BackgroundColor3 = T.Muted
        circle.BorderSizePixel = 0
        MakeCorner(circle, 99)

        local function SetVal(v)
            value = v
            SavedConfig[cfg2.Title] = v
            if v then
                Tween(pill,   .2, { BackgroundColor3 = T.Accent })
                Tween(circle, .2, { Position = UDim2.new(1, -11, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255,255,255) })
            else
                Tween(pill,   .2, { BackgroundColor3 = T.Component })
                Tween(circle, .2, { Position = UDim2.new(0, 11, 0.5, 0), BackgroundColor3 = T.Muted })
            end
        end

        SetVal(value)
        row.MouseButton1Click:Connect(function()
            SetVal(not value)
            cfg2.Callback(value)
        end)

        return { Set = SetVal, Get = function() return value end }
    end

    -- ── AddSlider ─────────────────────────────────────────────
    function Options:AddSlider(cfg2)
        local row = MakeRow(cfg2.Tab, 64)
        local minVal = cfg2.MinValue or 0
        local maxVal = cfg2.MaxValue or 100
        local value  = cfg2.Default or minVal
        SavedConfig[cfg2.Title] = value

        local tl = MakeLabel(row, cfg2.Title, 15, T.Title, true)
        tl.Size = UDim2.new(1, -70, 0, 18)
        tl.Position = UDim2.new(0, 14, 0, 8)

        local dl = MakeLabel(row, cfg2.Description or "", 12, T.Subtitle)
        dl.Size = UDim2.new(1, -70, 0, 14)
        dl.Position = UDim2.new(0, 14, 0, 26)

        -- value box
        local valBox = Instance.new("TextBox", row)
        valBox.Size = UDim2.new(0, 46, 0, 22)
        valBox.AnchorPoint = Vector2.new(1, 0)
        valBox.Position = UDim2.new(1, -14, 0, 10)
        valBox.BackgroundColor3 = T.Component
        valBox.BorderSizePixel = 0
        valBox.Text = tostring(value)
        valBox.TextColor3 = T.Title
        valBox.Font = Enum.Font.GothamBold
        valBox.TextSize = 12
        valBox.TextXAlignment = Enum.TextXAlignment.Center
        MakeCorner(valBox, 4)

        -- track
        local track = Instance.new("Frame", row)
        track.Size = UDim2.new(1, -28, 0, 6)
        track.Position = UDim2.new(0, 14, 0, 50)
        track.BackgroundColor3 = T.Outline
        track.BorderSizePixel = 0
        MakeCorner(track, 99)

        local fill = Instance.new("Frame", track)
        fill.BackgroundColor3 = T.Accent
        fill.BorderSizePixel = 0
        fill.Size = UDim2.fromScale(math.clamp((value - minVal) / (maxVal - minVal), 0, 1), 1)
        MakeCorner(fill, 99)

        local thumb = Instance.new("Frame", fill)
        thumb.Size = UDim2.new(0, 14, 0, 14)
        thumb.AnchorPoint = Vector2.new(1, 0.5)
        thumb.Position = UDim2.new(1, 0, 0.5, 0)
        thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
        thumb.BorderSizePixel = 0
        MakeCorner(thumb, 99)
        MakeStroke(thumb, T.Accent, 2)

        local function SetVal(v)
            if cfg2.AllowDecimals then
                local p = 10^(cfg2.DecimalAmount or 2)
                v = math.floor(v * p + 0.5) / p
            else
                v = math.round(v)
            end
            v = math.clamp(v, minVal, maxVal)
            value = v
            SavedConfig[cfg2.Title] = v
            local scale = (v - minVal) / (maxVal - minVal)
            fill.Size = UDim2.fromScale(scale, 1)
            valBox.Text = tostring(v)
            cfg2.Callback(v)
        end

        local dragging = false
        local function UpdateFromMouse()
            local scale = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            SetVal(minVal + scale * (maxVal - minVal))
        end

        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; UpdateFromMouse()
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateFromMouse()
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        valBox.FocusLost:Connect(function()
            SetVal(tonumber(valBox.Text) or value)
        end)

        SetVal(value)
        return { Set = SetVal, Get = function() return value end }
    end

    -- ── AddDropdown ───────────────────────────────────────────
    function Options:AddDropdown(cfg2)
        local row = MakeRow(cfg2.Tab, 52)
        local selected = cfg2.Default

        MakeTitleDesc(row, cfg2.Title, cfg2.Description)

        local selLabel = MakeLabel(row, selected or "Select...", 12, T.Subtitle, false, Enum.TextXAlignment.Right)
        selLabel.Size = UDim2.new(0, 100, 1, 0)
        selLabel.Position = UDim2.new(1, -120, 0, 0)

        local arrow = MakeLabel(row, "⌄", 14, T.Muted, true, Enum.TextXAlignment.Right)
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -22, 0, 0)

        row.MouseButton1Click:Connect(function()
            -- popup
            local popup = Instance.new("Frame", window)
            popup.Size = UDim2.new(0, 200, 0, 0)
            popup.Position = UDim2.new(0, row.AbsolutePosition.X - window.AbsolutePosition.X,
                                       0, row.AbsolutePosition.Y - window.AbsolutePosition.Y + 52)
            popup.BackgroundColor3 = T.Secondary
            popup.BorderSizePixel = 0
            popup.ZIndex = 30
            popup.ClipsDescendants = true
            MakeCorner(popup, 8)
            MakeStroke(popup, T.Outline, 1)

            local scroll = Instance.new("ScrollingFrame", popup)
            scroll.Size = UDim2.new(1, 0, 1, 0)
            scroll.BackgroundTransparency = 1
            scroll.ScrollBarThickness = 3
            scroll.ScrollBarImageColor3 = T.Outline
            scroll.BorderSizePixel = 0
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.CanvasSize = UDim2.new(0,0,0,0)
            scroll.ZIndex = 31
            MakeList(scroll, Enum.FillDirection.Vertical, 2)
            MakePadding(scroll, 4, 4, 4, 4)

            local totalH = 8
            for _, opt in ipairs(cfg2.Options) do
                local optBtn = Instance.new("TextButton", scroll)
                optBtn.Size = UDim2.new(1, 0, 0, 32)
                optBtn.BackgroundColor3 = (opt == selected) and T.Active or T.Component
                optBtn.BorderSizePixel = 0
                optBtn.Text = ""
                optBtn.AutoButtonColor = false
                optBtn.ZIndex = 32
                MakeCorner(optBtn, 4)
                AddHover(optBtn, (opt == selected) and T.Active or T.Component, T.Hover)

                local ol = MakeLabel(optBtn, opt, 13, T.Title, (opt == selected))
                ol.Size = UDim2.new(1, -12, 1, 0)
                ol.Position = UDim2.new(0, 10, 0, 0)
                ol.ZIndex = 33

                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selLabel.Text = opt
                    cfg2.Callback(opt)
                    popup:Destroy()
                end)
                totalH = totalH + 34
            end

            local finalH = math.min(totalH, 180)
            Tween(popup, .2, { Size = UDim2.new(0, 200, 0, finalH) })

            -- close on outside click
            local closeConn
            closeConn = UIS.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local abs = popup.AbsolutePosition
                    local sz  = popup.AbsoluteSize
                    if Mouse.X < abs.X or Mouse.X > abs.X+sz.X or Mouse.Y < abs.Y or Mouse.Y > abs.Y+sz.Y then
                        popup:Destroy()
                        closeConn:Disconnect()
                    end
                end
            end)
        end)
    end

    -- ── AddMultiDropdown ──────────────────────────────────────
    function Options:AddMultiDropdown(cfg2)
        local row = MakeRow(cfg2.Tab, 52)
        local selected = {}
        SavedConfig[cfg2.Title] = selected

        MakeTitleDesc(row, cfg2.Title, cfg2.Description)

        local selLabel = MakeLabel(row, "None", 12, T.Subtitle, false, Enum.TextXAlignment.Right)
        selLabel.Size = UDim2.new(0, 110, 1, 0)
        selLabel.Position = UDim2.new(1, -130, 0, 0)
        selLabel.TextTruncate = Enum.TextTruncate.AtEnd

        local arrow = MakeLabel(row, "⌄", 14, T.Muted, true, Enum.TextXAlignment.Right)
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -22, 0, 0)

        local function UpdateLabel()
            local keys = {}
            for k in next, selected do table.insert(keys, k) end
            selLabel.Text = #keys == 0 and "None" or table.concat(keys, ", ")
        end

        row.MouseButton1Click:Connect(function()
            local popup = Instance.new("Frame", window)
            popup.Size = UDim2.new(0, 220, 0, 0)
            popup.Position = UDim2.new(0, row.AbsolutePosition.X - window.AbsolutePosition.X,
                                       0, row.AbsolutePosition.Y - window.AbsolutePosition.Y + 52)
            popup.BackgroundColor3 = T.Secondary
            popup.BorderSizePixel = 0
            popup.ZIndex = 30
            popup.ClipsDescendants = true
            MakeCorner(popup, 8)
            MakeStroke(popup, T.Outline, 1)

            local scroll = Instance.new("ScrollingFrame", popup)
            scroll.Size = UDim2.new(1, 0, 1, 0)
            scroll.BackgroundTransparency = 1
            scroll.ScrollBarThickness = 3
            scroll.ScrollBarImageColor3 = T.Outline
            scroll.BorderSizePixel = 0
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.CanvasSize = UDim2.new(0,0,0,0)
            scroll.ZIndex = 31
            MakeList(scroll, Enum.FillDirection.Vertical, 2)
            MakePadding(scroll, 4, 4, 4, 4)

            local totalH = 8
            for _, opt in ipairs(cfg2.Options) do
                local optBtn = Instance.new("TextButton", scroll)
                optBtn.Size = UDim2.new(1, 0, 0, 32)
                optBtn.BackgroundColor3 = selected[opt] and T.Active or T.Component
                optBtn.BorderSizePixel = 0
                optBtn.Text = ""
                optBtn.AutoButtonColor = false
                optBtn.ZIndex = 32
                MakeCorner(optBtn, 4)

                local checkBox = Instance.new("Frame", optBtn)
                checkBox.Size = UDim2.new(0, 16, 0, 16)
                checkBox.AnchorPoint = Vector2.new(0, 0.5)
                checkBox.Position = UDim2.new(0, 8, 0.5, 0)
                checkBox.BackgroundColor3 = selected[opt] and T.Accent or T.Outline
                checkBox.BorderSizePixel = 0
                checkBox.ZIndex = 33
                MakeCorner(checkBox, 4)

                local checkMark = MakeLabel(checkBox, "✓", 11, Color3.fromRGB(255,255,255), true, Enum.TextXAlignment.Center)
                checkMark.Size = UDim2.new(1, 0, 1, 0)
                checkMark.Visible = selected[opt] ~= nil
                checkMark.ZIndex = 34

                local ol = MakeLabel(optBtn, opt, 13, T.Title, selected[opt] ~= nil)
                ol.Size = UDim2.new(1, -36, 1, 0)
                ol.Position = UDim2.new(0, 32, 0, 0)
                ol.ZIndex = 33

                optBtn.MouseButton1Click:Connect(function()
                    if selected[opt] then
                        selected[opt] = nil
                        Tween(optBtn, .15, { BackgroundColor3 = T.Component })
                        Tween(checkBox, .15, { BackgroundColor3 = T.Outline })
                        checkMark.Visible = false
                        ol.Font = Enum.Font.Gotham
                    else
                        selected[opt] = true
                        Tween(optBtn, .15, { BackgroundColor3 = T.Active })
                        Tween(checkBox, .15, { BackgroundColor3 = T.Accent })
                        checkMark.Visible = true
                        ol.Font = Enum.Font.GothamBold
                    end
                    UpdateLabel()
                    local vals = {}
                    for k in next, selected do table.insert(vals, k) end
                    cfg2.Callback(vals)
                    SavedConfig[cfg2.Title] = selected
                end)

                totalH = totalH + 34
            end

            local finalH = math.min(totalH, 200)
            Tween(popup, .2, { Size = UDim2.new(0, 220, 0, finalH) })

            local closeConn
            closeConn = UIS.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local abs = popup.AbsolutePosition
                    local sz  = popup.AbsoluteSize
                    if Mouse.X < abs.X or Mouse.X > abs.X+sz.X or Mouse.Y < abs.Y or Mouse.Y > abs.Y+sz.Y then
                        popup:Destroy()
                        closeConn:Disconnect()
                    end
                end
            end)
        end)

        return { Get = function() return selected end, SetLabel = UpdateLabel }
    end

    -- ── AddInput ──────────────────────────────────────────────
    function Options:AddInput(cfg2)
        local row = MakeRow(cfg2.Tab, 64)

        local tl = MakeLabel(row, cfg2.Title, 15, T.Title, true)
        tl.Size = UDim2.new(1, -28, 0, 18)
        tl.Position = UDim2.new(0, 14, 0, 8)

        local dl = MakeLabel(row, cfg2.Description or "", 12, T.Subtitle)
        dl.Size = UDim2.new(1, -28, 0, 14)
        dl.Position = UDim2.new(0, 14, 0, 26)

        local inputFrame = Instance.new("Frame", row)
        inputFrame.Size = UDim2.new(1, -28, 0, 26)
        inputFrame.Position = UDim2.new(0, 14, 0, 36)
        inputFrame.BackgroundColor3 = T.Component
        inputFrame.BorderSizePixel = 0
        MakeCorner(inputFrame, 4)
        MakeStroke(inputFrame, T.Outline, 1)

        local tb = Instance.new("TextBox", inputFrame)
        tb.Size = UDim2.new(1, -16, 1, 0)
        tb.Position = UDim2.new(0, 8, 0, 0)
        tb.BackgroundTransparency = 1
        tb.PlaceholderText = cfg2.Placeholder or "Type here..."
        tb.PlaceholderColor3 = T.Muted
        tb.Text = ""
        tb.TextColor3 = T.Title
        tb.Font = Enum.Font.Gotham
        tb.TextSize = 13
        tb.ClearTextOnFocus = false

        tb.Focused:Connect(function() MakeStroke(inputFrame, T.Accent, 1) end)
        tb.FocusLost:Connect(function()
            MakeStroke(inputFrame, T.Outline, 1)
            if cfg2.Callback then cfg2.Callback(tb.Text) end
        end)

        row.MouseButton1Click:Connect(function() tb:CaptureFocus() end)
    end

    -- ── AddKeybind ────────────────────────────────────────────
    function Options:AddKeybind(cfg2)
        local row = MakeRow(cfg2.Tab, 52)
        MakeTitleDesc(row, cfg2.Title, cfg2.Description)

        local bindLabel = MakeLabel(row, "None", 12, T.Accent, true, Enum.TextXAlignment.Right)
        bindLabel.Size = UDim2.new(0, 80, 1, 0)
        bindLabel.Position = UDim2.new(1, -90, 0, 0)

        local listening = false

        row.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            bindLabel.Text = "..."
            bindLabel.TextColor3 = T.Warning

            local conn
            conn = UIS.InputBegan:Connect(function(inp, focused)
                if focused then return end
                conn:Disconnect()  -- disconnect ngay
                listening = false

                local text
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    text = tostring(inp.KeyCode):gsub("Enum.KeyCode.", "")
                    SavedBinds[cfg2.Title] = inp.KeyCode
                else
                    text = tostring(inp.UserInputType):gsub("Enum.UserInputType.MouseButton", "MB")
                    SavedBinds[cfg2.Title] = inp.UserInputType
                end
                bindLabel.Text = text
                bindLabel.TextColor3 = T.Accent
                cfg2.Callback(inp)
            end)
        end)
    end

    -- ── AddSearchBar ──────────────────────────────────────────
    function Options:AddSearchBar(cfg2)
        local row = MakeRow(cfg2.Tab, 64)

        local tl = MakeLabel(row, cfg2.Title or "Search", 15, T.Title, true)
        tl.Size = UDim2.new(1, -28, 0, 18)
        tl.Position = UDim2.new(0, 14, 0, 8)

        local inputFrame = Instance.new("Frame", row)
        inputFrame.Size = UDim2.new(1, -28, 0, 26)
        inputFrame.Position = UDim2.new(0, 14, 0, 30)
        inputFrame.BackgroundColor3 = T.Component
        inputFrame.BorderSizePixel = 0
        MakeCorner(inputFrame, 4)
        MakeStroke(inputFrame, T.Outline, 1)

        local icon = MakeLabel(inputFrame, "⌕", 14, T.Muted)
        icon.Size = UDim2.new(0, 20, 1, 0)
        icon.Position = UDim2.new(0, 4, 0, 0)

        local tb = Instance.new("TextBox", inputFrame)
        tb.Size = UDim2.new(1, -30, 1, 0)
        tb.Position = UDim2.new(0, 26, 0, 0)
        tb.BackgroundTransparency = 1
        tb.PlaceholderText = cfg2.Placeholder or "Search..."
        tb.PlaceholderColor3 = T.Muted
        tb.Text = ""
        tb.TextColor3 = T.Title
        tb.Font = Enum.Font.Gotham
        tb.TextSize = 12
        tb.ClearTextOnFocus = false

        tb:GetPropertyChangedSignal("Text"):Connect(function()
            cfg2.Callback(tb.Text)
        end)
        row.MouseButton1Click:Connect(function() tb:CaptureFocus() end)
    end

    -- ── AddColorPicker ────────────────────────────────────────
    function Options:AddColorPicker(cfg2)
        local row = MakeRow(cfg2.Tab, 52)
        local currentColor = cfg2.Default or Color3.fromRGB(255, 80, 80)
        SavedConfig[cfg2.Title] = currentColor

        MakeTitleDesc(row, cfg2.Title, cfg2.Description or "Click to pick")

        local swatch = Instance.new("Frame", row)
        swatch.Size = UDim2.new(0, 28, 0, 28)
        swatch.AnchorPoint = Vector2.new(1, 0.5)
        swatch.Position = UDim2.new(1, -14, 0.5, 0)
        swatch.BackgroundColor3 = currentColor
        swatch.BorderSizePixel = 0
        MakeCorner(swatch, 6)
        MakeStroke(swatch, T.Outline, 1)

        row.MouseButton1Click:Connect(function()
            -- picker popup
            local overlay = Instance.new("Frame", window)
            overlay.Size = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundTransparency = 0.6
            overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
            overlay.BorderSizePixel = 0
            overlay.ZIndex = 40

            local popup = Instance.new("Frame", overlay)
            popup.Size = UDim2.new(0, 280, 0, 310)
            popup.AnchorPoint = Vector2.new(0.5, 0.5)
            popup.Position = UDim2.new(0.5, 0, 0.5, 0)
            popup.BackgroundColor3 = T.Secondary
            popup.BorderSizePixel = 0
            popup.ZIndex = 41
            MakeCorner(popup, 10)
            MakeStroke(popup, T.Outline, 1)

            local hdr = MakeLabel(popup, "Color Picker", 15, T.Title, true)
            hdr.Size = UDim2.new(1, -20, 0, 24)
            hdr.Position = UDim2.new(0, 14, 0, 10)

            local xBtn = Instance.new("TextButton", popup)
            xBtn.Size = UDim2.new(0, 28, 0, 28)
            xBtn.Position = UDim2.new(1, -36, 0, 6)
            xBtn.BackgroundTransparency = 1
            xBtn.Text = "✕"
            xBtn.TextColor3 = T.Subtitle
            xBtn.Font = Enum.Font.GothamBold
            xBtn.TextSize = 14
            xBtn.ZIndex = 42
            xBtn.MouseButton1Click:Connect(function() overlay:Destroy() end)

            local H, S, V = Color3.toHSV(currentColor)

            -- SV box
            local svBox = Instance.new("ImageLabel", popup)
            svBox.Size = UDim2.new(0, 248, 0, 160)
            svBox.Position = UDim2.new(0.5, -124, 0, 42)
            svBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
            svBox.Image = "rbxassetid://4155801252"
            svBox.BorderSizePixel = 0
            svBox.ZIndex = 42
            MakeCorner(svBox, 6)

            local blackOverlay = Instance.new("ImageLabel", svBox)
            blackOverlay.Size = UDim2.new(1,0,1,0)
            blackOverlay.Image = "rbxassetid://4155801252"
            blackOverlay.ImageColor3 = Color3.fromRGB(0,0,0)
            blackOverlay.Rotation = 90
            blackOverlay.BackgroundTransparency = 1
            blackOverlay.ZIndex = 43

            local svCursor = Instance.new("Frame", svBox)
            svCursor.Size = UDim2.new(0, 12, 0, 12)
            svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            svCursor.Position = UDim2.new(S, 0, 1-V, 0)
            svCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
            svCursor.BorderSizePixel = 0
            svCursor.ZIndex = 44
            MakeCorner(svCursor, 99)
            MakeStroke(svCursor, Color3.fromRGB(0,0,0), 1, 0.5)

            -- hue bar
            local hueBar = Instance.new("ImageLabel", popup)
            hueBar.Size = UDim2.new(0, 248, 0, 14)
            hueBar.Position = UDim2.new(0.5, -124, 0, 210)
            hueBar.Image = "rbxassetid://698052001"
            hueBar.BorderSizePixel = 0
            hueBar.ZIndex = 42
            MakeCorner(hueBar, 4)

            local hueCursor = Instance.new("Frame", hueBar)
            hueCursor.Size = UDim2.new(0, 5, 1, 4)
            hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            hueCursor.Position = UDim2.new(H, 0, 0.5, 0)
            hueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255)
            hueCursor.BorderSizePixel = 0
            hueCursor.ZIndex = 43
            MakeCorner(hueCursor, 3)

            -- hex input
            local hexFrame = Instance.new("Frame", popup)
            hexFrame.Size = UDim2.new(0, 140, 0, 28)
            hexFrame.Position = UDim2.new(0, 16, 0, 234)
            hexFrame.BackgroundColor3 = T.Component
            hexFrame.BorderSizePixel = 0
            hexFrame.ZIndex = 42
            MakeCorner(hexFrame, 4)
            MakeStroke(hexFrame, T.Outline, 1)

            local hexBox = Instance.new("TextBox", hexFrame)
            hexBox.Size = UDim2.new(1, -10, 1, 0)
            hexBox.Position = UDim2.new(0, 8, 0, 0)
            hexBox.BackgroundTransparency = 1
            hexBox.Text = string.format("#%02X%02X%02X",
                math.round(currentColor.R*255),
                math.round(currentColor.G*255),
                math.round(currentColor.B*255))
            hexBox.TextColor3 = T.Title
            hexBox.Font = Enum.Font.GothamMono
            hexBox.TextSize = 12
            hexBox.ZIndex = 43

            -- preview
            local preview = Instance.new("Frame", popup)
            preview.Size = UDim2.new(0, 80, 0, 28)
            preview.Position = UDim2.new(1, -96, 0, 234)
            preview.BackgroundColor3 = currentColor
            preview.BorderSizePixel = 0
            preview.ZIndex = 42
            MakeCorner(preview, 4)

            -- apply
            local applyBtn = Instance.new("TextButton", popup)
            applyBtn.Size = UDim2.new(1, -32, 0, 32)
            applyBtn.Position = UDim2.new(0, 16, 0, 270)
            applyBtn.BackgroundColor3 = T.Accent
            applyBtn.BorderSizePixel = 0
            applyBtn.Text = "Apply"
            applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
            applyBtn.Font = Enum.Font.GothamBold
            applyBtn.TextSize = 13
            applyBtn.ZIndex = 42
            MakeCorner(applyBtn, 6)

            local function UpdateColor()
                local c = Color3.fromHSV(H, S, V)
                currentColor = c
                svBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                svCursor.Position = UDim2.new(S, 0, 1-V, 0)
                hueCursor.Position = UDim2.new(H, 0, 0.5, 0)
                preview.BackgroundColor3 = c
                hexBox.Text = string.format("#%02X%02X%02X",
                    math.round(c.R*255), math.round(c.G*255), math.round(c.B*255))
            end

            local dragHue, dragSV = false, false
            hueBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragHue = true end
            end)
            svBox.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = true end
            end)
            UIS.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragHue = false; dragSV = false
                end
            end)
            UIS.InputChanged:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if dragHue then
                    H = math.clamp((Mouse.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    UpdateColor()
                elseif dragSV then
                    S = math.clamp((Mouse.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
                    V = 1 - math.clamp((Mouse.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
                    UpdateColor()
                end
            end)
            hexBox.FocusLost:Connect(function()
                local hex = hexBox.Text:gsub("#","")
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2),16) or 0
                    local g = tonumber(hex:sub(3,4),16) or 0
                    local b = tonumber(hex:sub(5,6),16) or 0
                    H, S, V = Color3.toHSV(Color3.fromRGB(r,g,b))
                    UpdateColor()
                end
            end)
            applyBtn.MouseButton1Click:Connect(function()
                cfg2.Callback(currentColor)
                swatch.BackgroundColor3 = currentColor
                SavedConfig[cfg2.Title] = currentColor
                overlay:Destroy()
            end)
        end)

        return { Get = function() return currentColor end, Set = function(c) currentColor = c; swatch.BackgroundColor3 = c end }
    end

    -- ── AddParagraph ──────────────────────────────────────────
    function Options:AddParagraph(cfg2)
        local row = Instance.new("Frame", cfg2.Tab)
        row.Size = UDim2.new(1, 0, 0, 56)
        row.BackgroundColor3 = T.Component
        row.BorderSizePixel = 0
        MakeCorner(row, 6)
        MakePadding(row, 8, 8, 14, 14)

        local tl = MakeLabel(row, cfg2.Title, 14, T.Title, true)
        tl.Size = UDim2.new(1, 0, 0, 18)
        tl.Position = UDim2.new(0, 14, 0, 8)

        local dl = MakeLabel(row, cfg2.Description, 12, T.Subtitle)
        dl.Size = UDim2.new(1, 0, 0, 14)
        dl.Position = UDim2.new(0, 14, 0, 28)
        dl.TextWrapped = true
    end

    -- ── AddValueDisplay ───────────────────────────────────────
    function Options:AddValueDisplay(cfg2)
        local row = Instance.new("Frame", cfg2.Tab)
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundColor3 = T.Component
        row.BorderSizePixel = 0
        MakeCorner(row, 6)

        local tl = MakeLabel(row, cfg2.Title, 13, T.Subtitle, false)
        tl.Size = UDim2.new(0.5, 0, 1, 0)
        tl.Position = UDim2.new(0, 14, 0, 0)

        local vl = MakeLabel(row, tostring(cfg2.Default or "—"), 16, T.Title, true, Enum.TextXAlignment.Right)
        vl.Size = UDim2.new(0.5, -14, 1, 0)
        vl.Position = UDim2.new(0.5, 0, 0, 0)

        return { Set = function(v) vl.Text = tostring(v) end }
    end

    -- ── AddNestedTabs ─────────────────────────────────────────
    function Options:AddNestedTabs(cfg2)
        local container = Instance.new("Frame", cfg2.Tab)
        container.Size = UDim2.new(1, 0, 0, 0)
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.BackgroundTransparency = 1

        local tabBar = Instance.new("Frame", container)
        tabBar.Size = UDim2.new(1, 0, 0, 32)
        tabBar.BackgroundColor3 = T.Component
        tabBar.BorderSizePixel = 0
        MakeCorner(tabBar, 6)
        MakeList(tabBar, Enum.FillDirection.Horizontal, 2)
        MakePadding(tabBar, 4, 4, 4, 4)

        local content = Instance.new("Frame", container)
        content.Size = UDim2.new(1, 0, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Position = UDim2.new(0, 0, 0, 38)
        content.BackgroundTransparency = 1

        local subFrames, subBtns = {}, {}
        local activeSub = nil

        local function SetSub(name)
            for n, f in next, subFrames do f.Visible = (n == name) end
            for n, b in next, subBtns do
                if n == name then
                    Tween(b, .15, { BackgroundColor3 = T.Accent })
                    b.label.TextColor3 = Color3.fromRGB(255,255,255)
                else
                    Tween(b, .15, { BackgroundColor3 = Color3.fromRGB(0,0,0) })
                    task.delay(.01, function() b.BackgroundTransparency = 1 end)
                    b.label.TextColor3 = T.Subtitle
                end
            end
            activeSub = name
        end

        local subScrolls = {}
        for i, name in ipairs(cfg2.Tabs) do
            local btn = Instance.new("TextButton", tabBar)
            btn.Size = UDim2.new(0, 80, 1, 0)
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.LayoutOrder = i
            MakeCorner(btn, 4)

            local lbl = MakeLabel(btn, name, 12, T.Subtitle, true, Enum.TextXAlignment.Center)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            btn.label = lbl

            local subScroll = Instance.new("ScrollingFrame", content)
            subScroll.Size = UDim2.new(1, 0, 0, 0)
            subScroll.AutomaticSize = Enum.AutomaticSize.Y
            subScroll.BackgroundTransparency = 1
            subScroll.ScrollBarThickness = 0
            subScroll.BorderSizePixel = 0
            subScroll.Visible = false
            MakeList(subScroll, Enum.FillDirection.Vertical, 4)

            subFrames[name] = subScroll
            subScrolls[name] = subScroll
            subBtns[name] = btn

            btn.MouseButton1Click:Connect(function() SetSub(name) end)
        end

        if #cfg2.Tabs > 0 then SetSub(cfg2.Tabs[1]) end
        return subScrolls
    end

    -- ── AddPlayerList ─────────────────────────────────────────
    function Options:AddPlayerList(cfg2)
        local row = MakeRow(cfg2.Tab, 52)
        MakeTitleDesc(row, cfg2.Title or "Player List", cfg2.Description or "Click to select")

        local arrow = MakeLabel(row, "›", 20, T.Muted, true, Enum.TextXAlignment.Right)
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -30, 0, 0)

        row.MouseButton1Click:Connect(function()
            local overlay = Instance.new("Frame", window)
            overlay.Size = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundTransparency = 0.5
            overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
            overlay.BorderSizePixel = 0
            overlay.ZIndex = 40

            local popup = Instance.new("Frame", overlay)
            popup.Size = UDim2.new(0, 260, 0, 320)
            popup.AnchorPoint = Vector2.new(0.5, 0.5)
            popup.Position = UDim2.new(0.5, 0, 0.5, 0)
            popup.BackgroundColor3 = T.Secondary
            popup.BorderSizePixel = 0
            popup.ZIndex = 41
            MakeCorner(popup, 10)
            MakeStroke(popup, T.Outline, 1)

            local hdr = MakeLabel(popup, "Players", 15, T.Title, true)
            hdr.Size = UDim2.new(1,-20,0,24)
            hdr.Position = UDim2.new(0,14,0,10)

            local xBtn = Instance.new("TextButton", popup)
            xBtn.Size = UDim2.new(0,28,0,28)
            xBtn.Position = UDim2.new(1,-36,0,6)
            xBtn.BackgroundTransparency = 1
            xBtn.Text = "✕"
            xBtn.TextColor3 = T.Subtitle
            xBtn.Font = Enum.Font.GothamBold
            xBtn.TextSize = 14
            xBtn.ZIndex = 42
            xBtn.MouseButton1Click:Connect(function() overlay:Destroy() end)

            local scroll = Instance.new("ScrollingFrame", popup)
            scroll.Size = UDim2.new(1,-10,1,-46)
            scroll.Position = UDim2.new(0,5,0,42)
            scroll.BackgroundTransparency = 1
            scroll.ScrollBarThickness = 3
            scroll.ScrollBarImageColor3 = T.Outline
            scroll.BorderSizePixel = 0
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.CanvasSize = UDim2.new(0,0,0,0)
            scroll.ZIndex = 42
            MakeList(scroll, Enum.FillDirection.Vertical, 4)

            local function AddPlayerRow(p)
                local pRow = Instance.new("TextButton", scroll)
                pRow.Name = p.Name
                pRow.Size = UDim2.new(1,0,0,36)
                pRow.BackgroundColor3 = T.Component
                pRow.BorderSizePixel = 0
                pRow.Text = ""
                pRow.AutoButtonColor = false
                pRow.ZIndex = 43
                MakeCorner(pRow, 6)
                AddHover(pRow, T.Component, T.Hover)

                local ico = Instance.new("ImageLabel", pRow)
                ico.Size = UDim2.new(0,26,0,26)
                ico.AnchorPoint = Vector2.new(0,0.5)
                ico.Position = UDim2.new(0,6,0.5,0)
                ico.BackgroundColor3 = T.Outline
                ico.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
                ico.ZIndex = 44
                MakeCorner(ico, 99)

                local nl = MakeLabel(pRow, p.Name, 13, T.Title, true)
                nl.Size = UDim2.new(1,-44,1,0)
                nl.Position = UDim2.new(0,38,0,0)
                nl.ZIndex = 44

                pRow.MouseButton1Click:Connect(function()
                    cfg2.Callback(p)
                    overlay:Destroy()
                end)
            end

            for _, p in ipairs(Players:GetPlayers()) do AddPlayerRow(p) end
            Players.PlayerAdded:Connect(function(p) AddPlayerRow(p) end)
            Players.PlayerRemoving:Connect(function(p)
                local r = scroll:FindFirstChild(p.Name)
                if r then r:Destroy() end
            end)
        end)
    end

    -- ── AddBindManager ────────────────────────────────────────
    function Options:AddBindManager(cfg2)
        local row = MakeRow(cfg2.Tab, 52)
        MakeTitleDesc(row, cfg2.Title or "Bind Manager", cfg2.Description or "View all keybinds")

        local arrow = MakeLabel(row, "›", 20, T.Muted, true, Enum.TextXAlignment.Right)
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -30, 0, 0)

        row.MouseButton1Click:Connect(function()
            local overlay = Instance.new("Frame", window)
            overlay.Size = UDim2.new(1,0,1,0)
            overlay.BackgroundTransparency = 0.5
            overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
            overlay.BorderSizePixel = 0
            overlay.ZIndex = 40

            local popup = Instance.new("Frame", overlay)
            popup.Size = UDim2.new(0,300,0,360)
            popup.AnchorPoint = Vector2.new(0.5,0.5)
            popup.Position = UDim2.new(0.5,0,0.5,0)
            popup.BackgroundColor3 = T.Secondary
            popup.BorderSizePixel = 0
            popup.ZIndex = 41
            MakeCorner(popup, 10)
            MakeStroke(popup, T.Outline, 1)

            local hdr = MakeLabel(popup, "Bind Manager", 15, T.Title, true)
            hdr.Size = UDim2.new(1,-20,0,24)
            hdr.Position = UDim2.new(0,14,0,10)

            local xBtn = Instance.new("TextButton", popup)
            xBtn.Size = UDim2.new(0,28,0,28)
            xBtn.Position = UDim2.new(1,-36,0,6)
            xBtn.BackgroundTransparency = 1
            xBtn.Text = "✕"
            xBtn.TextColor3 = T.Subtitle
            xBtn.Font = Enum.Font.GothamBold
            xBtn.TextSize = 14
            xBtn.ZIndex = 42
            xBtn.MouseButton1Click:Connect(function() overlay:Destroy() end)

            local scroll = Instance.new("ScrollingFrame", popup)
            scroll.Size = UDim2.new(1,-10,1,-46)
            scroll.Position = UDim2.new(0,5,0,42)
            scroll.BackgroundTransparency = 1
            scroll.ScrollBarThickness = 3
            scroll.ScrollBarImageColor3 = T.Outline
            scroll.BorderSizePixel = 0
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.CanvasSize = UDim2.new(0,0,0,0)
            scroll.ZIndex = 42
            MakeList(scroll, Enum.FillDirection.Vertical, 4)

            local count = 0
            for k, v in next, SavedBinds do
                count = count + 1
                local bRow = Instance.new("Frame", scroll)
                bRow.Size = UDim2.new(1,0,0,36)
                bRow.BackgroundColor3 = T.Component
                bRow.BorderSizePixel = 0
                bRow.ZIndex = 43
                MakeCorner(bRow, 6)

                local nl = MakeLabel(bRow, k, 13, T.Title, true)
                nl.Size = UDim2.new(0.6,0,1,0)
                nl.Position = UDim2.new(0,12,0,0)
                nl.ZIndex = 44

                local bl = MakeLabel(bRow, tostring(v):gsub("Enum.KeyCode.",""):gsub("Enum.UserInputType.MouseButton","MB"),
                    13, T.Accent, true, Enum.TextXAlignment.Right)
                bl.Size = UDim2.new(0.4,-12,1,0)
                bl.Position = UDim2.new(0.6,0,0,0)
                bl.ZIndex = 44
            end

            if count == 0 then
                local el = MakeLabel(scroll, "No keybinds set.", 13, T.Muted, false, Enum.TextXAlignment.Center)
                el.Size = UDim2.new(1,0,0,40)
            end
        end)
    end

    -- ── AddThemePicker ────────────────────────────────────────
    function Options:AddThemePicker(cfg2)
        local row = MakeRow(cfg2.Tab, 52)
        MakeTitleDesc(row, cfg2.Title or "Theme", "Choose a color theme")

        local dot = Instance.new("Frame", row)
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.AnchorPoint = Vector2.new(1, 0.5)
        dot.Position = UDim2.new(1, -14, 0.5, 0)
        dot.BackgroundColor3 = T.Accent
        dot.BorderSizePixel = 0
        MakeCorner(dot, 99)

        row.MouseButton1Click:Connect(function()
            MakeThemePicker(window, function(preset)
                T = preset
                dot.BackgroundColor3 = T.Accent
                -- recolor window
                window.BackgroundColor3 = T.Primary
                titlebar.BackgroundColor3 = T.Secondary
                tbfix.BackgroundColor3 = T.Secondary
                sidebar.BackgroundColor3 = T.Sidebar
                contentArea.BackgroundColor3 = T.Primary
                cafix.BackgroundColor3 = T.Primary
                divider.BackgroundColor3 = T.Outline
                keybindHint.BackgroundColor3 = T.Secondary
                khfix.BackgroundColor3 = T.Secondary
                khLabel.TextColor3 = T.Muted
                titleLabel.TextColor3 = T.Title
                searchBox.BackgroundColor3 = T.Component
                searchIcon.TextColor3 = T.Muted
                searchInput.TextColor3 = T.Title
                searchInput.PlaceholderColor3 = T.Muted
            end)
        end)
    end

    -- ── Config Save/Load ──────────────────────────────────────
    function Options:SaveConfig(name)
        if not writefile then
            ShowNotif("Error", "writefile not available", 3, "error"); return
        end
        local data = {}
        for k, v in next, SavedConfig do
            if typeof(v) == "Color3" then
                data[k] = { t = "Color3", r = v.R, g = v.G, b = v.B }
            elseif typeof(v) == "boolean" or typeof(v) == "number" or typeof(v) == "string" then
                data[k] = { t = typeof(v), v = v }
            end
        end
        local ok, err = pcall(writefile, (name or "PulseConfig") .. ".json", HttpService:JSONEncode(data))
        if ok then
            ShowNotif("Config Saved", (name or "PulseConfig") .. ".json", 2, "success")
        else
            ShowNotif("Save Error", tostring(err), 3, "error")
        end
    end

    function Options:LoadConfig(name, callbacks)
        if not readfile then
            ShowNotif("Error", "readfile not available", 3, "error"); return
        end
        local ok, raw = pcall(readfile, (name or "PulseConfig") .. ".json")
        if not ok then
            ShowNotif("Load Error", "File not found", 3, "error"); return
        end
        local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok2 then
            ShowNotif("Parse Error", "Invalid config file", 3, "error"); return
        end
        for k, entry in next, data do
            local v
            if entry.t == "Color3" then
                v = Color3.fromRGB(entry.r*255, entry.g*255, entry.b*255)
            else
                v = entry.v
            end
            SavedConfig[k] = v
            if callbacks and callbacks[k] then callbacks[k](v) end
        end
        ShowNotif("Config Loaded", (name or "PulseConfig") .. ".json", 2, "success")
    end

    -- ── Notify ────────────────────────────────────────────────
    function Options:Notify(cfg2)
        ShowNotif(cfg2.Title, cfg2.Description, cfg2.Duration, cfg2.Type)
    end

    -- Final
    window.GroupTransparency = 1
    Tween(window, .3, { GroupTransparency = winTransp })

    return Options
end

return Library
