--[[
	UI Library — iOS/macOS Style
	Redesigned by Claude (based on original by Torch)
	
	Features:
	- iOS Settings + macOS dark mode aesthetic
	- Smooth spring animations
	- Accent color system
	- Notification toasts with timer bar
	- Drag & resize support
	- All original components redesigned
	
	Usage:
	local UI = loadstring(...)()
	local Window = UI:CreateWindow({
		Title = "My Script",
		Size = UDim2.fromOffset(560, 420),
		Accent = Color3.fromRGB(110, 107, 255), -- optional
	})
	local Tab = Window:AddTab({ Title = "Player", Icon = "rbxassetid://..." })
	Tab:AddToggle({ Title = "God Mode", Description = "Infinite health", Default = false, Callback = function(v) end })
	Tab:AddSlider({ Title = "Speed", Min = 16, Max = 200, Default = 50, Callback = function(v) end })
]]

-- ─── Services ────────────────────────────────────────────────────────────────

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")

local LocalPlayer    = Players.LocalPlayer
local Mouse          = LocalPlayer:GetMouse()

-- ─── Theme ───────────────────────────────────────────────────────────────────

local Theme = {
	-- Backgrounds (layered dark)
	BG          = Color3.fromRGB(17, 17, 19),    -- outermost
	BG2         = Color3.fromRGB(24, 24, 27),    -- window bg
	BG3         = Color3.fromRGB(28, 28, 31),    -- content area
	BG4         = Color3.fromRGB(34, 34, 38),    -- group bg

	Surface     = Color3.fromRGB(38, 38, 43),    -- component surface
	Surface2    = Color3.fromRGB(46, 46, 52),    -- hover surface

	-- Borders (subtle)
	Border      = Color3.fromRGB(255, 255, 255), -- use at low transparency
	BorderAlpha = 0.07,
	BorderAlpha2 = 0.13,

	-- Text
	TextPrimary   = Color3.fromRGB(240, 240, 240),
	TextSecondary = Color3.fromRGB(154, 154, 159),
	TextTertiary  = Color3.fromRGB(90, 90, 98),
	TextDisabled  = Color3.fromRGB(60, 60, 66),

	-- Accent (overridable)
	Accent      = Color3.fromRGB(110, 107, 255),
	AccentDark  = Color3.fromRGB(90, 87, 224),

	-- Semantic
	Green       = Color3.fromRGB(52, 201, 122),
	Red         = Color3.fromRGB(255, 69, 58),
	Amber       = Color3.fromRGB(255, 159, 10),
	Blue        = Color3.fromRGB(10, 132, 255),

	-- Dimensions
	Radius      = 10,   -- window / group corners
	RadiusInner = 6,    -- component inner radius
	ComponentH  = 36,   -- standard component height
	RowH        = 42,   -- settings row height
	Padding     = 12,   -- standard padding
	SidebarW    = 148,  -- sidebar width
	TitlebarH   = 36,   -- title bar height
}

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function Tween(obj, t, props, style, dir)
	local info = TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	TweenService:Create(obj, info, props):Play()
end

local function SpringTween(obj, t, props)
	Tween(obj, t, props, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function Set(obj, props)
	for k, v in pairs(props) do obj[k] = v end
	return obj
end

local function MakeInstance(class, props, parent)
	local obj = Instance.new(class)
	Set(obj, props)
	if parent then obj.Parent = parent end
	return obj
end

-- Darken/Brighten a Color3
local function Shade(c, amount)
	return Color3.fromRGB(
		math.clamp(c.R * 255 + amount, 0, 255),
		math.clamp(c.G * 255 + amount, 0, 255),
		math.clamp(c.B * 255 + amount, 0, 255)
	)
end

-- ─── Make Draggable ──────────────────────────────────────────────────────────

local function MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ─── Make Resizable (4-corner) ───────────────────────────────────────────────

local function MakeResizable(frame, minSize, maxSize)
	minSize = minSize or Vector2.new(380, 260)
	maxSize = maxSize or Vector2.new(900, 700)

	local corners = {
		TopLeft     = { x = -1, y = -1 },
		TopRight    = { x =  1, y = -1 },
		BottomLeft  = { x = -1, y =  1 },
		BottomRight = { x =  1, y =  1 },
	}

	local resizing, activeCorner, startMouse, startSize, startPos

	local resizeFrame = MakeInstance("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 100,
	}, frame)

	for name, dir in pairs(corners) do
		local handle = MakeInstance("Frame", {
			Name = name,
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			ZIndex = 101,
		}, resizeFrame)

		-- Position each handle at the corner
		if name == "TopLeft"     then handle.Position = UDim2.fromOffset(-4, -4) end
		if name == "TopRight"    then handle.Position = UDim2.new(1, -10, 0, -4) end
		if name == "BottomLeft"  then handle.Position = UDim2.new(0, -4, 1, -10) end
		if name == "BottomRight" then handle.Position = UDim2.new(1, -10, 1, -10) end

		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = true
				activeCorner = dir
				startMouse = Vector2.new(Mouse.X, Mouse.Y)
				startSize = Vector2.new(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
				startPos = frame.Position
			end
		end)

		handle.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = false
			end
		end)
	end

	RunService.RenderStepped:Connect(function()
		if not resizing then return end
		local delta = Vector2.new(Mouse.X, Mouse.Y) - startMouse
		local newW = math.clamp(startSize.X + delta.X * activeCorner.x, minSize.X, maxSize.X)
		local newH = math.clamp(startSize.Y + delta.Y * activeCorner.y, minSize.Y, maxSize.Y)
		local offsetX = (newW - startSize.X) * (activeCorner.x == -1 and -1 or 0)
		local offsetY = (newH - startSize.Y) * (activeCorner.y == -1 and -1 or 0)

		frame.Size = UDim2.fromOffset(newW, newH)
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + offsetX,
			startPos.Y.Scale, startPos.Y.Offset + offsetY
		)
	end)
end

-- ─── Hover Effect ────────────────────────────────────────────────────────────

local function AddHover(obj, normalColor, hoverColor, tweenTime)
	tweenTime = tweenTime or 0.12
	obj.MouseEnter:Connect(function()
		Tween(obj, tweenTime, { BackgroundColor3 = hoverColor })
	end)
	obj.MouseLeave:Connect(function()
		Tween(obj, tweenTime, { BackgroundColor3 = normalColor })
	end)
end

-- ─── Border via UIStroke ──────────────────────────────────────────────────────

local function AddBorder(parent, alpha, thickness)
	return MakeInstance("UIStroke", {
		Color = Theme.Border,
		Transparency = 1 - (alpha or Theme.BorderAlpha),
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

-- ─── Section Label ────────────────────────────────────────────────────────────

local function MakeSectionLabel(text, parent, layoutOrder)
	local wrapper = MakeInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder or 0,
	}, parent)
	MakeInstance("TextLabel", {
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		BackgroundTransparency = 1,
		Text = text:upper(),
		TextColor3 = Theme.Accent,
		TextTransparency = 0.45,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, wrapper)
	return wrapper
end

-- ─── Notification Toast ───────────────────────────────────────────────────────

local NotifHolder -- will be set when window created
local notifCount = 0

local function FireNotification(title, description, notifType, duration)
	if not NotifHolder then return end
	duration = duration or 2.5
	notifType = notifType or "info"

	notifCount = notifCount + 1

	local iconColors = {
		success = Theme.Green,
		info    = Theme.Blue,
		warning = Theme.Amber,
		error   = Theme.Red,
	}
	local iconText = {
		success = "✓",
		info    = "i",
		warning = "!",
		error   = "×",
	}

	local accent = iconColors[notifType] or Theme.Blue

	-- Container
	local notif = MakeInstance("Frame", {
		Name             = "Notif_" .. notifCount,
		Size             = UDim2.new(1, 0, 0, 0),
		AutomaticSize    = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.BG3,
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		LayoutOrder      = notifCount,
		-- เริ่มจากนอกจอขวา แล้วค่อย slide เข้ามา
		Position         = UDim2.new(1, 20, 0, 0),
	}, NotifHolder)
	MakeInstance("UICorner", { CornerRadius = UDim.new(0, Theme.Radius) }, notif)
	AddBorder(notif, Theme.BorderAlpha2)

	-- Layout
	local layout = MakeInstance("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 10),
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, notif)
	MakeInstance("UIPadding", {
		PaddingTop = UDim.new(0, 11),
		PaddingBottom = UDim.new(0, 11),
		PaddingLeft = UDim.new(0, 11),
		PaddingRight = UDim.new(0, 11),
	}, notif)

	-- Icon circle
	local iconBG = MakeInstance("Frame", {
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
	}, notif)
	MakeInstance("UICorner", { CornerRadius = UDim.new(0, 7) }, iconBG)
	MakeInstance("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = iconText[notifType] or "i",
		TextColor3 = accent,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
	}, iconBG)

	-- Text column
	local textCol = MakeInstance("Frame", {
		Size = UDim2.new(1, -60, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, notif)
	MakeInstance("UIListLayout", {
		Padding = UDim.new(0, 2),
	}, textCol)

	MakeInstance("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.TextPrimary,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, textCol)

	MakeInstance("TextLabel", {
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		Text = description,
		TextColor3 = accent,
		TextTransparency = 0.35,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, textCol)

	-- Timer bar
	local timerTrack = MakeInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
	}, textCol)
	MakeInstance("UICorner", { CornerRadius = UDim.new(0, 1) }, timerTrack)

	local timerBar = MakeInstance("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
	}, timerTrack)
	MakeInstance("UICorner", { CornerRadius = UDim.new(0, 1) }, timerBar)

	-- Slide in จากขวา
	notif.BackgroundTransparency = 1
	task.spawn(function()
		-- slide เข้ามาพร้อม fade in
		Tween(notif, 0.28, {
			BackgroundTransparency = 0,
			Position = UDim2.fromScale(0, 0),
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		Tween(timerBar, duration, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear)
		task.wait(duration)
		-- slide ออกขวา + fade
		Tween(notif, 0.22, {
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 20, 0, 0),
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.wait(0.24)
		notif:Destroy()
	end)
end

-- ─── Library ──────────────────────────────────────────────────────────────────

local Library = {}

function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local title       = cfg.Title or "UI Library"
	local size        = cfg.Size or UDim2.fromOffset(560, 420)
	local keybind     = cfg.Keybind or Enum.KeyCode.LeftControl
	local transparency = cfg.Transparency or 0
	local accentColor  = cfg.Accent

	if accentColor then
		Theme.Accent = accentColor
		Theme.AccentDark = Shade(accentColor, -18)
	end

	-- ── Root ScreenGui ────────────────────────────────────────────────────────
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UILibrary_" .. title
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
	if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	-- ── Window ────────────────────────────────────────────────────────────────
	local window = MakeInstance("CanvasGroup", {
		Name = "Window",
		Size = size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.BG2,
		BorderSizePixel = 0,
		GroupTransparency = transparency,
	}, screenGui)
	MakeInstance("UICorner", { CornerRadius = UDim.new(0, 14) }, window)
	AddBorder(window, 0.15, 1)

	-- ── Title bar ─────────────────────────────────────────────────────────────
	local titlebar = MakeInstance("Frame", {
		Size = UDim2.new(1, 0, 0, Theme.TitlebarH),
		BackgroundColor3 = Theme.BG,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, window)
	MakeInstance("UICorner", { CornerRadius = UDim.new(0, 14) }, titlebar)

	-- Flat bottom to square off the lower corners of titlebar
	MakeInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, -14),
		BackgroundColor3 = Theme.BG,
		BorderSizePixel = 0,
	}, titlebar)

	MakeInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 1 - Theme.BorderAlpha,
		BorderSizePixel = 0,
	}, titlebar)

	-- Traffic-light dots
	local dotHolder = MakeInstance("Frame", {
		Size = UDim2.fromOffset(60, Theme.TitlebarH),
		BackgroundTransparency = 1,
		ZIndex = 3,
	}, titlebar)
	MakeInstance("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 7),
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, dotHolder)
	MakeInstance("UIPadding", { PaddingLeft = UDim.new(0, 13) }, dotHolder)

	-- dot[1]=red(destroy) dot[2]=yellow(minimize/fold) dot[3]=green(maximize)
	local dotDefs = {
		{ Color3.fromRGB(255, 95, 87),  Color3.fromRGB(200, 50, 40),  "×" },
		{ Color3.fromRGB(254, 188, 46), Color3.fromRGB(200, 140, 10), "−" },
		{ Color3.fromRGB(40, 200, 64),  Color3.fromRGB(20, 160, 40),  "+" },
	}
	local dots = {}
	for i, c in ipairs(dotDefs) do
		local dot = MakeInstance("Frame", {
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = c[1],
			BorderSizePixel = 0,
			ZIndex = 4,
		}, dotHolder)
		MakeInstance("UICorner", { CornerRadius = UDim.new(0.5, 0) }, dot)
		-- Symbol label (hidden by default, shows on titlebar hover)
		local sym = MakeInstance("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = c[3],
			TextColor3 = Color3.fromRGB(80, 20, 10),
			TextSize = 9,
			Font = Enum.Font.GothamBold,
			Visible = false,
			ZIndex = 5,
		}, dot)
		dots[i] = { frame = dot, sym = sym, normal = c[1], hover = c[2] }
		dot.MouseEnter:Connect(function()
			Tween(dot, 0.1, { BackgroundColor3 = c[2] })
			sym.Visible = true
		end)
		dot.MouseLeave:Connect(function()
			Tween(dot, 0.1, { BackgroundColor3 = c[1] })
			sym.Visible = false
		end)
	end

	-- Window title
	MakeInstance("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Theme.TextSecondary,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		ZIndex = 3,
	}, titlebar)

	-- ── Sidebar ───────────────────────────────────────────────────────────────
	local sidebar = MakeInstance("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, Theme.SidebarW, 1, -Theme.TitlebarH),
		Position = UDim2.fromOffset(0, Theme.TitlebarH),
		BackgroundColor3 = Theme.BG,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, window)

	-- Accent color bar ด้านบน sidebar (เส้นบางๆ สีสด)
	MakeInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, sidebar)

	-- Right border line on sidebar
	MakeInstance("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 1 - Theme.BorderAlpha,
		BorderSizePixel = 0,
	}, sidebar)

	-- Flat corners (square the top-left corner of sidebar)
	MakeInstance("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Theme.BG,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, sidebar)

	local sidebarList = MakeInstance("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, sidebar)
	MakeInstance("UIListLayout", {
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, sidebarList)
	MakeInstance("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
	}, sidebarList)

	-- ── Content holder ────────────────────────────────────────────────────────
	local contentHolder = MakeInstance("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -Theme.SidebarW, 1, -Theme.TitlebarH),
		Position = UDim2.new(0, Theme.SidebarW, 0, Theme.TitlebarH),
		BackgroundColor3 = Theme.BG3,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, window)

	-- ── Notification holder — ลอยบนจอ Roblox ทั้งหน้าจอ ──────────────────────
	NotifHolder = MakeInstance("Frame", {
		Name            = "Notifications",
		Size            = UDim2.new(0, 260, 1, 0),
		Position        = UDim2.new(1, -276, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex          = 9999,
		ClipsDescendants = false,
	}, screenGui)   -- <-- parent = screenGui ไม่ใช่ contentHolder
	MakeInstance("UIListLayout", {
		Padding             = UDim.new(0, 8),
		SortOrder           = Enum.SortOrder.LayoutOrder,
		VerticalAlignment   = Enum.VerticalAlignment.Bottom,  -- stack ล่างขึ้นบน
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	}, NotifHolder)
	MakeInstance("UIPadding", {
		PaddingBottom = UDim.new(0, 20),
	}, NotifHolder)

	-- ── Open/Close animation ──────────────────────────────────────────────────
	local visible = true

	local function OpenWindow()
		window.Visible = true
		window.GroupTransparency = 1
		window.Size = UDim2.new(
			size.X.Scale, size.X.Offset * 0.95,
			size.Y.Scale, size.Y.Offset * 0.95
		)
		Tween(window, 0.22, { GroupTransparency = transparency, Size = size })
		visible = true
	end

	local function CloseWindow()
		Tween(window, 0.18, {
			GroupTransparency = 1,
			Size = UDim2.new(
				size.X.Scale, size.X.Offset * 0.95,
				size.Y.Scale, size.Y.Offset * 0.95
			)
		})
		task.delay(0.2, function() window.Visible = false end)
		visible = false
	end

	-- ── Dot click actions ─────────────────────────────────────────────────────
	local maximized = false
	local preMaxSize, preMaxPos

	-- RED — ลบ UI ออกจากเกมเลย
	dots[1].frame.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		Tween(window, 0.15, {
			GroupTransparency = 1,
			Size = UDim2.new(size.X.Scale, size.X.Offset * 0.9, size.Y.Scale, size.Y.Offset * 0.9)
		})
		task.delay(0.18, function() screenGui:Destroy() end)
	end)

	-- YELLOW — พับ/ซ่อน window (minimize toggle)
	dots[2].frame.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if visible then CloseWindow() else OpenWindow() end
	end)

	-- GREEN — ขยายเต็มจอ / กลับขนาดเดิม
	dots[3].frame.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not maximized then
			preMaxSize = window.Size
			preMaxPos  = window.Position
			maximized  = true
			Tween(window, 0.2, {
				Size     = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
			})
		else
			maximized = false
			Tween(window, 0.2, { Size = preMaxSize, Position = preMaxPos })
		end
	end)

	-- Keybind toggle
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == keybind then
			if visible then CloseWindow() else OpenWindow() end
		end
	end)

	-- ── Drag & Resize ─────────────────────────────────────────────────────────
	MakeDraggable(window, titlebar)
	MakeResizable(window, Vector2.new(380, 260), Vector2.new(900, 700))

	-- Open on spawn
	OpenWindow()

	-- ─── Window API ───────────────────────────────────────────────────────────
	local Win = {}
	local tabButtons = {}
	local tabPages   = {}
	local activeTab  = nil

	-- ── Switch to tab ─────────────────────────────────────────────────────────
	function Win:SetTab(name)
		for tabName, btn in pairs(tabButtons) do
			local isActive = (tabName == name)
			local targetBG    = isActive and Theme.Surface2 or Color3.fromRGB(0,0,0)
			local targetAlpha = isActive and 0 or 1
			local targetColor = isActive and Theme.TextPrimary or Theme.TextSecondary
			local barAlpha    = isActive and 0 or 1
			Tween(btn.frame, 0.15, { BackgroundColor3 = targetBG, BackgroundTransparency = targetAlpha })
			Tween(btn.label, 0.15, { TextColor3 = targetColor })
			if btn.bar then
				Tween(btn.bar, 0.15, { BackgroundTransparency = barAlpha })
			end
		end
		for tabName, page in pairs(tabPages) do
			if tabName == name then
				page.Visible = true
				page.GroupTransparency = 1
				Tween(page, 0.18, { GroupTransparency = 0 })
			elseif page.Visible then
				Tween(page, 0.12, { GroupTransparency = 1 })
				task.delay(0.13, function() page.Visible = false end)
			end
		end
		activeTab = name
	end

	-- ── Add sidebar section label ──────────────────────────────────────────────
	function Win:AddSection(sectionName, order)
		MakeSectionLabel(sectionName, sidebarList, order or 0)
	end

	-- ── Add tab ───────────────────────────────────────────────────────────────
	function Win:AddTab(cfg2)
		cfg2 = cfg2 or {}
		local tabTitle = cfg2.Title or "Tab"
		local tabIcon  = cfg2.Icon

		-- Sidebar button
		local btn = MakeInstance("TextButton", {
			Name = tabTitle,
			Size = UDim2.new(1, -12, 0, 30),
			Position = UDim2.fromOffset(6, 0),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		}, sidebarList)
		MakeInstance("UICorner", { CornerRadius = UDim.new(0, 5) }, btn)

		-- Row layout
		local rowLayout = MakeInstance("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, btn)
		MakeInstance("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 7),
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}, rowLayout)
		MakeInstance("UIPadding", { PaddingLeft = UDim.new(0, 10) }, rowLayout)

		-- Icon (if provided)
		if tabIcon then
			local ico = MakeInstance("ImageLabel", {
				Size = UDim2.fromOffset(16, 16),
				BackgroundTransparency = 1,
				Image = tabIcon,
				ImageColor3 = Theme.TextSecondary,
			}, rowLayout)
		end

		-- Label
		local lbl = MakeInstance("TextLabel", {
			Size = UDim2.new(1, tabIcon and -30 or -10, 1, 0),
			BackgroundTransparency = 1,
			Text = tabTitle,
			TextColor3 = Theme.TextSecondary,
			TextSize = 12.5,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, rowLayout)

		-- Accent left-bar indicator (แสดงตอน active)
		local accentBar = MakeInstance("Frame", {
			Size = UDim2.new(0, 3, 0.6, 0),
			Position = UDim2.new(0, 0, 0.2, 0),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 5,
		}, btn)
		MakeInstance("UICorner", { CornerRadius = UDim.new(0, 2) }, accentBar)

		tabButtons[tabTitle] = { frame = btn, label = lbl, bar = accentBar }

		-- Page (CanvasGroup for fade)
		local page = MakeInstance("CanvasGroup", {
			Name = tabTitle .. "_Page",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			GroupTransparency = 1,
		}, contentHolder)

		local scroll = MakeInstance("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Surface2,
			CanvasSize = UDim2.fromScale(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, page)
		MakeInstance("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, scroll)
		MakeInstance("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 12),
		}, scroll)

		tabPages[tabTitle] = page

		btn.MouseButton1Click:Connect(function()
			Win:SetTab(tabTitle)
		end)
		btn.MouseEnter:Connect(function()
			if activeTab ~= tabTitle then
				Tween(btn, 0.12, { BackgroundColor3 = Theme.Surface, BackgroundTransparency = 0 })
			end
		end)
		btn.MouseLeave:Connect(function()
			if activeTab ~= tabTitle then
				Tween(btn, 0.12, { BackgroundTransparency = 1 })
			end
		end)

		-- Auto-switch to first tab
		if not activeTab then
			Win:SetTab(tabTitle)
		end

		-- ── Tab Component API ──────────────────────────────────────────────────
		local Tab = {}
		local layoutOrder = 0

		local function nextOrder()
			layoutOrder = layoutOrder + 1
			return layoutOrder
		end

		-- Helper: make a group card
		local function MakeGroup(parent)
			local grp = MakeInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.BG4,
				BorderSizePixel = 0,
				LayoutOrder = nextOrder(),
			}, parent)
			MakeInstance("UICorner", { CornerRadius = UDim.new(0, Theme.Radius) }, grp)
			AddBorder(grp, Theme.BorderAlpha)
			MakeInstance("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, grp)
			return grp
		end

		-- Helper: make a standard row inside a group
		local function MakeRow(parent, rowOrder)
			local row = MakeInstance("Frame", {
				Size = UDim2.new(1, 0, 0, Theme.RowH),
				BackgroundColor3 = Theme.BG4,
				BorderSizePixel = 0,
				LayoutOrder = rowOrder or 0,
				ClipsDescendants = true,
			}, parent)
			-- Bottom separator (hidden on last child by convention — Roblox doesn't have :last-child)
			MakeInstance("Frame", {
				Size = UDim2.new(1, -12, 0, 1),
				Position = UDim2.new(0, 12, 1, -1),
				BackgroundColor3 = Theme.Border,
				BackgroundTransparency = 1 - Theme.BorderAlpha,
				BorderSizePixel = 0,
				ZIndex = 2,
			}, row)
			AddHover(row, Theme.BG4, Theme.Surface)

			-- Left label area
			local labelCol = MakeInstance("Frame", {
				Size = UDim2.new(0.55, -13, 1, 0),
				Position = UDim2.fromOffset(13, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, row)
			MakeInstance("UIListLayout", {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 2),
			}, labelCol)

			-- Right control area
			local rightCol = MakeInstance("Frame", {
				Size = UDim2.new(0.45, -13, 1, 0),
				Position = UDim2.new(0.55, 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, row)
			MakeInstance("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 6),
			}, rightCol)
			MakeInstance("UIPadding", { PaddingRight = UDim.new(0, 13) }, rightCol)

			return row, labelCol, rightCol
		end

		local function MakeLabel(text, parent)
			return MakeInstance("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.TextPrimary,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, parent)
		end

		local function MakeDescription(text, parent)
			return MakeInstance("TextLabel", {
				Size = UDim2.new(1, 0, 0, 13),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.TextSecondary,
				TextSize = 11,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, parent)
		end

		-- ── Section divider ────────────────────────────────────────────────────
		function Tab:AddSection(sectionTitle)
			local wrapper = MakeInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = nextOrder(),
			}, scroll)
			-- accent left line
			MakeInstance("Frame", {
				Size = UDim2.new(0, 2, 0, 14),
				Position = UDim2.fromOffset(0, 5),
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 0.3,
				BorderSizePixel = 0,
			}, wrapper)
			MakeInstance("TextLabel", {
				Size = UDim2.new(1, -10, 1, 0),
				Position = UDim2.fromOffset(8, 0),
				BackgroundTransparency = 1,
				Text = sectionTitle:upper(),
				TextColor3 = Theme.Accent,
				TextTransparency = 0.3,
				TextSize = 10,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, wrapper)
		end

		-- ── Button ────────────────────────────────────────────────────────────
		function Tab:AddButton(cfg3)
			cfg3 = cfg3 or {}
			local grp = MakeGroup(scroll)
			local row, labelCol, rightCol = MakeRow(grp, 0)
			row.Size = UDim2.new(1, 0, 0, Theme.RowH)
			row.BackgroundTransparency = 1

			MakeLabel(cfg3.Title or "Button", labelCol)
			if cfg3.Description then MakeDescription(cfg3.Description, labelCol) end

			-- Chevron arrow
			MakeInstance("TextLabel", {
				Size = UDim2.fromOffset(12, 12),
				BackgroundTransparency = 1,
				Text = "›",
				TextColor3 = Theme.TextTertiary,
				TextSize = 16,
				Font = Enum.Font.Gotham,
			}, rightCol)

			local btn = MakeInstance("TextButton", {
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 5,
			}, row)

			btn.MouseButton1Click:Connect(function()
				Tween(row, 0.08, { BackgroundColor3 = Theme.Surface2, BackgroundTransparency = 0 })
				task.delay(0.15, function()
					Tween(row, 0.12, { BackgroundTransparency = 1 })
				end)
				if cfg3.Callback then cfg3.Callback() end
			end)
		end

		-- ── Toggle ────────────────────────────────────────────────────────────
		function Tab:AddToggle(cfg3)
			cfg3 = cfg3 or {}
			local state = cfg3.Default or false
			local grp = MakeGroup(scroll)
			local row, labelCol, rightCol = MakeRow(grp, 0)

			MakeLabel(cfg3.Title or "Toggle", labelCol)
			if cfg3.Description then MakeDescription(cfg3.Description, labelCol) end

			-- Track
			local track = MakeInstance("Frame", {
				Size = UDim2.fromOffset(38, 22),
				BackgroundColor3 = state and Theme.Green or Theme.Surface2,
				BorderSizePixel = 0,
			}, rightCol)
			MakeInstance("UICorner", { CornerRadius = UDim.new(0, 11) }, track)
			AddBorder(track, Theme.BorderAlpha2)

			-- Thumb
			local thumb = MakeInstance("Frame", {
				Size = UDim2.fromOffset(18, 18),
				Position = state
					and UDim2.fromOffset(18, 2)
					or  UDim2.fromOffset(2, 2),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
			}, track)
			MakeInstance("UICorner", { CornerRadius = UDim.new(0.5, 0) }, thumb)

			local clickBtn = MakeInstance("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 5,
			}, row)

			local function SetToggle(v)
				state = v
				SpringTween(thumb, 0.22, {
					Position = v and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)
				})
				Tween(track, 0.18, {
					BackgroundColor3 = v and Theme.Green or Theme.Surface2
				})
				if cfg3.Callback then cfg3.Callback(v) end
			end

			clickBtn.MouseButton1Click:Connect(function()
				SetToggle(not state)
			end)

			return { SetValue = SetToggle, GetValue = function() return state end }
		end

		-- ── Slider ────────────────────────────────────────────────────────────
		function Tab:AddSlider(cfg3)
			cfg3 = cfg3 or {}
			local minVal  = cfg3.Min or 0
			local maxVal  = cfg3.Max or 100
			local current = cfg3.Default or minVal
			local decimals = cfg3.Decimals or 0
			local grp = MakeGroup(scroll)

			-- Taller row for slider
			local row = MakeInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 52),
				BackgroundColor3 = Theme.BG4,
				BorderSizePixel = 0,
				LayoutOrder = 0,
				ClipsDescendants = true,
			}, grp)
			AddHover(row, Theme.BG4, Theme.Surface)
			MakeInstance("Frame", {
				Size = UDim2.new(1, -12, 0, 1),
				Position = UDim2.new(0, 12, 1, -1),
				BackgroundColor3 = Theme.Border,
				BackgroundTransparency = 1 - Theme.BorderAlpha,
				BorderSizePixel = 0,
				ZIndex = 2,
			}, row)

			-- Top row: label + value
			local topRow = MakeInstance("Frame", {
				Size = UDim2.new(1, -26, 0, 22),
				Position = UDim2.fromOffset(13, 8),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, row)
			MakeLabel(cfg3.Title or "Slider", topRow)

			local function fmt(v)
				if decimals > 0 then
					return string.format("%." .. decimals .. "f", v)
				end
				return tostring(math.round(v))
			end

			local valLabel = MakeInstance("TextLabel", {
				Size = UDim2.fromOffset(50, 22),
				Position = UDim2.new(1, -50, 0, 0),
				BackgroundTransparency = 1,
				Text = fmt(current),
				TextColor3 = Theme.Accent,
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Right,
			}, topRow)

			-- Slider track
			local trackBG = MakeInstance("Frame", {
				Size = UDim2.new(1, -26, 0, 3),
				Position = UDim2.fromOffset(13, 38),
				BackgroundColor3 = Theme.Surface2,
				BorderSizePixel = 0,
			}, row)
			MakeInstance("UICorner", { CornerRadius = UDim.new(0, 2) }, trackBG)

			local fill = MakeInstance("Frame", {
				Size = UDim2.fromScale((current - minVal) / (maxVal - minVal), 1),
				BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0,
			}, trackBG)
			MakeInstance("UICorner", { CornerRadius = UDim.new(0, 2) }, fill)

			-- Thumb circle
			local thumbSlider = MakeInstance("Frame", {
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new((current - minVal) / (maxVal - minVal), -8, 0.5, -8),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				ZIndex = 3,
			}, trackBG)
			MakeInstance("UICorner", { CornerRadius = UDim.new(0.5, 0) }, thumbSlider)

			-- Hit area
			local hitArea = MakeInstance("TextButton", {
				Size = UDim2.new(1, 0, 0, 22),
				Position = UDim2.fromOffset(0, -9),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 10,
			}, trackBG)

			local draggingSlider = false

			local function UpdateSlider(mouseX)
				local abs = trackBG.AbsolutePosition.X
				local sz  = trackBG.AbsoluteSize.X
				local scale = math.clamp((mouseX - abs) / sz, 0, 1)
				local val = minVal + scale * (maxVal - minVal)
				if decimals == 0 then val = math.round(val) end
				current = val
				local s = (val - minVal) / (maxVal - minVal)
				Tween(fill, 0.05, { Size = UDim2.fromScale(s, 1) })
				Tween(thumbSlider, 0.05, { Position = UDim2.new(s, -8, 0.5, -8) })
				valLabel.Text = fmt(val)
				if cfg3.Callback then cfg3.Callback(val) end
			end

			hitArea.MouseButton1Down:Connect(function()
				draggingSlider = true
				UpdateSlider(Mouse.X)
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					draggingSlider = false
				end
			end)
			RunService.RenderStepped:Connect(function()
				if draggingSlider then UpdateSlider(Mouse.X) end
			end)

			return {
				SetValue = function(v)
					current = math.clamp(v, minVal, maxVal)
					UpdateSlider(trackBG.AbsolutePosition.X + (current - minVal) / (maxVal - minVal) * trackBG.AbsoluteSize.X)
				end,
				GetValue = function() return current end,
			}
		end

		-- ── Input ─────────────────────────────────────────────────────────────
		function Tab:AddInput(cfg3)
			cfg3 = cfg3 or {}
			local grp = MakeGroup(scroll)
			local row, labelCol, rightCol = MakeRow(grp, 0)
			row.Size = UDim2.new(1, 0, 0, Theme.RowH)

			MakeLabel(cfg3.Title or "Input", labelCol)
			if cfg3.Description then MakeDescription(cfg3.Description, labelCol) end

			local inputBox = MakeInstance("TextBox", {
				Size = UDim2.fromOffset(120, 24),
				BackgroundColor3 = Theme.Surface,
				BorderSizePixel = 0,
				Text = cfg3.Default or "",
				PlaceholderText = cfg3.Placeholder or "Type here...",
				TextColor3 = Theme.TextPrimary,
				PlaceholderColor3 = Theme.TextTertiary,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				ClearTextOnFocus = false,
			}, rightCol)
			MakeInstance("UICorner", { CornerRadius = UDim.new(0, 5) }, inputBox)
			AddBorder(inputBox, Theme.BorderAlpha2)
			MakeInstance("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}, inputBox)

			inputBox.Focused:Connect(function()
				Tween(inputBox:FindFirstChildOfClass("UIStroke"), 0.15, {
					Color = Theme.Accent, Transparency = 0.3
				})
			end)
			inputBox.FocusLost:Connect(function()
				Tween(inputBox:FindFirstChildOfClass("UIStroke"), 0.15, {
					Color = Theme.Border, Transparency = 1 - Theme.BorderAlpha2
				})
				if cfg3.Callback then cfg3.Callback(inputBox.Text) end
			end)

			return {
				GetValue = function() return inputBox.Text end,
				SetValue = function(v) inputBox.Text = v end,
			}
		end

		-- ── Dropdown ──────────────────────────────────────────────────────────
		function Tab:AddDropdown(cfg3)
			cfg3 = cfg3 or {}
			local options = cfg3.Options or {}
			local selected = cfg3.Default or (options[1] or "")
			local grp = MakeGroup(scroll)
			local row, labelCol, rightCol = MakeRow(grp, 0)

			MakeLabel(cfg3.Title or "Dropdown", labelCol)
			if cfg3.Description then MakeDescription(cfg3.Description, labelCol) end

			local selLabel = MakeInstance("TextLabel", {
				Size = UDim2.fromOffset(90, 20),
				BackgroundTransparency = 1,
				Text = selected,
				TextColor3 = Theme.TextSecondary,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Right,
			}, rightCol)

			MakeInstance("TextLabel", {
				Size = UDim2.fromOffset(10, 20),
				BackgroundTransparency = 1,
				Text = "›",
				TextColor3 = Theme.TextTertiary,
				TextSize = 14,
				Font = Enum.Font.Gotham,
			}, rightCol)

			-- Dropdown menu
			local function OpenDropdown()
				local menu = MakeInstance("Frame", {
					Size = UDim2.new(0, 160, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Position = UDim2.new(1, -170, 1, 4),
					BackgroundColor3 = Theme.BG3,
					BorderSizePixel = 0,
					ZIndex = 50,
					ClipsDescendants = true,
				}, row)
				MakeInstance("UICorner", { CornerRadius = UDim.new(0, Theme.Radius) }, menu)
				AddBorder(menu, Theme.BorderAlpha2)
				MakeInstance("UIListLayout", {}, menu)

				for _, opt in ipairs(options) do
					local optBtn = MakeInstance("TextButton", {
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundColor3 = Theme.BG3,
						BorderSizePixel = 0,
						Text = opt,
						TextColor3 = opt == selected and Theme.Accent or Theme.TextPrimary,
						TextSize = 12.5,
						Font = Enum.Font.Gotham,
						AutoButtonColor = false,
						ZIndex = 51,
					}, menu)
					MakeInstance("UIPadding", { PaddingLeft = UDim.new(0, 12) }, optBtn)
					AddHover(optBtn, Theme.BG3, Theme.Surface)

					optBtn.MouseButton1Click:Connect(function()
						selected = opt
						selLabel.Text = opt
						if cfg3.Callback then cfg3.Callback(opt) end
						menu:Destroy()
					end)
				end

				-- Close if clicking outside
				local conn
				conn = UserInputService.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						task.delay(0.05, function()
							if menu and menu.Parent then menu:Destroy() end
						end)
						conn:Disconnect()
					end
				end)
			end

			local clickBtn = MakeInstance("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 5,
			}, row)
			clickBtn.MouseButton1Click:Connect(OpenDropdown)

			return {
				GetValue = function() return selected end,
				SetValue = function(v)
					selected = v
					selLabel.Text = v
				end,
			}
		end

		-- ── Keybind ───────────────────────────────────────────────────────────
		function Tab:AddKeybind(cfg3)
			cfg3 = cfg3 or {}
			local currentKey = cfg3.Default
			local listening = false
			local grp = MakeGroup(scroll)
			local row, labelCol, rightCol = MakeRow(grp, 0)

			MakeLabel(cfg3.Title or "Keybind", labelCol)
			if cfg3.Description then MakeDescription(cfg3.Description, labelCol) end

			local function KeyName(key)
				if key == nil then return "None" end
				local s = tostring(key.KeyCode or key.UserInputType)
				s = s:gsub("Enum%.KeyCode%.", ""):gsub("Enum%.UserInputType%.", "")
				s = s:gsub("MouseButton", "MB")
				return s
			end

			local badge = MakeInstance("TextButton", {
				Size = UDim2.fromOffset(60, 22),
				BackgroundColor3 = Theme.Surface2,
				BorderSizePixel = 0,
				Text = currentKey and KeyName(currentKey) or "None",
				TextColor3 = Theme.TextPrimary,
				TextSize = 11,
				Font = Enum.Font.GothamMedium,
				AutoButtonColor = false,
			}, rightCol)
			MakeInstance("UICorner", { CornerRadius = UDim.new(0, 4) }, badge)
			AddBorder(badge, Theme.BorderAlpha2)

			badge.MouseButton1Click:Connect(function()
				if listening then return end
				listening = true
				badge.Text = "..."
				Tween(badge, 0.15, { BackgroundColor3 = Theme.Accent })

				local conn
				conn = UserInputService.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					listening = false
					currentKey = input
					badge.Text = KeyName(input)
					Tween(badge, 0.15, { BackgroundColor3 = Theme.Surface2 })
					if cfg3.Callback then cfg3.Callback(input) end
					conn:Disconnect()
				end)
			end)

			return {
				GetValue = function() return currentKey end,
			}
		end

		-- ── Paragraph ─────────────────────────────────────────────────────────
		function Tab:AddParagraph(cfg3)
			cfg3 = cfg3 or {}
			local grp = MakeGroup(scroll)

			local container = MakeInstance("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 0,
			}, grp)
			MakeInstance("UIListLayout", { Padding = UDim.new(0, 4) }, container)
			MakeInstance("UIPadding", {
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 13),
				PaddingRight = UDim.new(0, 13),
			}, container)

			if cfg3.Title then
				MakeInstance("TextLabel", {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Text = cfg3.Title,
					TextColor3 = Theme.TextPrimary,
					TextSize = 13,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
				}, container)
			end

			if cfg3.Description then
				MakeInstance("TextLabel", {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Text = cfg3.Description,
					TextColor3 = Theme.TextSecondary,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
				}, container)
			end
		end

		return Tab
	end -- AddTab

	-- ── Notification shortcut ────────────────────────────────────────────────
	function Win:Notify(cfg2)
		cfg2 = cfg2 or {}
		FireNotification(
			cfg2.Title or "Notice",
			cfg2.Description or "",
			cfg2.Type or "info",
			cfg2.Duration or 2.5
		)
	end

	-- ── Change accent color ───────────────────────────────────────────────────
	function Win:SetAccent(color)
		Theme.Accent = color
		Theme.AccentDark = Shade(color, -18)
	end

	-- ── Update keybind ────────────────────────────────────────────────────────
	function Win:SetKeybind(key)
		keybind = key
	end

	return Win
end

return Library

--[[
─────────────────────────────────────────────────────────
EXAMPLE USAGE:
─────────────────────────────────────────────────────────

local UI = loadstring(game:HttpGet("your_url_here"))()

local Window = UI:CreateWindow({
	Title       = "My Script v1.0",
	Size        = UDim2.fromOffset(560, 420),
	Keybind     = Enum.KeyCode.LeftControl,
	Transparency = 0,
	Accent      = Color3.fromRGB(110, 107, 255),
})

Window:AddSection("Main")

local PlayerTab = Window:AddTab({ Title = "Player" })
local VisualTab = Window:AddTab({ Title = "Visual" })

-- Player tab
PlayerTab:AddToggle({
	Title       = "God Mode",
	Description = "Infinite health",
	Default     = false,
	Callback    = function(v)
		-- do stuff
	end
})

PlayerTab:AddSlider({
	Title    = "Walk Speed",
	Min      = 16,
	Max      = 200,
	Default  = 50,
	Callback = function(v)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
	end
})

PlayerTab:AddDropdown({
	Title   = "Team",
	Options = { "Red", "Blue", "Green" },
	Default = "Red",
	Callback = function(v)
		print("Selected:", v)
	end
})

PlayerTab:AddKeybind({
	Title    = "Toggle Fly",
	Callback = function(key)
		print("Key set:", key)
	end
})

-- Notifications
Window:Notify({
	Title       = "Loaded",
	Description = "Script injected successfully",
	Type        = "success",
	Duration    = 3,
})
-- Type options: "success" | "info" | "warning" | "error"

─────────────────────────────────────────────────────────
]]
