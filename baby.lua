--[[
	UI Library — Card Style
	API compatible กับ Torch เดิม
	ไม่ต้องพึ่ง rbxassetid — ทำงานได้ทุก executor

	── Window ────────────────────────────────────────────
	local Window = Library:CreateWindow({
		Title             = "My Script",
		Size              = UDim2.fromOffset(660, 480),
		Transparency      = 0,
		Theme             = "Dark",        -- "Dark" | "Light"
		MinimizeKeybind   = Enum.KeyCode.LeftControl,
		Accent            = Color3.fromRGB(48, 130, 255),  -- optional
	})

	── Tabs ──────────────────────────────────────────────
	Window:AddTabSection({ Name = "Main",     Order = 1 })
	Window:AddTabSection({ Name = "Settings", Order = 2 })

	local Tab = Window:AddTab({ Title = "Player", Section = "Main" })

	── Components ────────────────────────────────────────
	Window:AddSection({ Name = "Combat",  Tab = Tab })
	Window:AddButton  ({ Title = "...", Description = "...", Tab = Tab, Callback = function() end })
	Window:AddToggle  ({ Title = "...", Description = "...", Default = false, Tab = Tab, Callback = function(v) end })
	Window:AddSlider  ({ Title = "...", MaxValue = 100, AllowDecimals = false, Tab = Tab, Callback = function(v) end })
	Window:AddInput   ({ Title = "...", Description = "...", Tab = Tab, Callback = function(text) end })
	Window:AddDropdown({ Title = "...", Options = {"A","B"}, Tab = Tab, Callback = function(v) end })
	Window:AddMultiSelect({ Title = "...", Options = {"A","B"}, Tab = Tab, Callback = function(list) end })
	Window:AddListbox ({ Title = "...", Options = {"A","B"}, Tab = Tab, Callback = function(v) end })
	Window:AddKeybind ({ Title = "...", Description = "...", Tab = Tab, Callback = function(key) end })
	Window:AddParagraph({ Title = "...", Description = "...", Tab = Tab })
	Window:Notify     ({ Title = "...", Description = "...", Duration = 3 })
	Window:SetSetting ("Theme", { ... })
]]

-- ── Services ──────────────────────────────────────────────────────────────────

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

-- ── Theme ─────────────────────────────────────────────────────────────────────

local T = {
	-- backgrounds
	BG       = Color3.fromRGB(12, 14, 20),
	BG2      = Color3.fromRGB(16, 19, 28),
	BG3      = Color3.fromRGB(19, 23, 34),
	BG4      = Color3.fromRGB(23, 28, 42),
	Surface  = Color3.fromRGB(28, 34, 52),
	Surface2 = Color3.fromRGB(34, 42, 64),
	-- text
	TP  = Color3.fromRGB(228, 236, 255),
	TS  = Color3.fromRGB(120, 148, 205),
	TT  = Color3.fromRGB(60, 82, 128),
	-- accent
	Accent   = Color3.fromRGB(48, 130, 255),
	Green    = Color3.fromRGB(52, 201, 122),
	Red      = Color3.fromRGB(255, 69, 58),
	Amber    = Color3.fromRGB(255, 159, 10),
	-- dims
	Radius = 13, RowH = 62, SideW = 192, TitleH = 42,
}

local LightT = {
	BG       = Color3.fromRGB(225, 234, 248),
	BG2      = Color3.fromRGB(240, 246, 255),
	BG3      = Color3.fromRGB(250, 253, 255),
	BG4      = Color3.fromRGB(232, 241, 255),
	Surface  = Color3.fromRGB(216, 230, 252),
	Surface2 = Color3.fromRGB(198, 218, 248),
	TP  = Color3.fromRGB(12, 24, 50),
	TS  = Color3.fromRGB(50, 90, 155),
	TT  = Color3.fromRGB(115, 148, 200),
	Accent   = Color3.fromRGB(14, 100, 230),
	Green    = Color3.fromRGB(22, 155, 68),
	Red      = Color3.fromRGB(200, 40, 30),
	Amber    = Color3.fromRGB(190, 110, 0),
	Radius = 13, RowH = 62, SideW = 192, TitleH = 42,
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function Tw(obj, t, props, style, dir)
	if not obj or not obj.Parent then return end
	TweenService:Create(obj,
		TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
		props):Play()
end

local function Spring(obj, t, props)
	Tw(obj, t, props, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function New(cls, props, parent)
	local ok, obj = pcall(Instance.new, cls)
	if not ok or not obj then return nil end
	for k, v in pairs(props) do pcall(function() obj[k] = v end) end
	if parent then obj.Parent = parent end
	return obj
end

local function Shade(c, a)
	return Color3.fromRGB(
		math.clamp(c.R*255+a, 0, 255),
		math.clamp(c.G*255+a, 0, 255),
		math.clamp(c.B*255+a, 0, 255))
end

local function Stroke(p, alpha, thick)
	return New("UIStroke", {
		Color = Color3.fromRGB(255,255,255),
		Transparency = 1-(alpha or 0.08),
		Thickness = thick or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, p)
end

local function Hover(obj, n, h)
	obj.MouseEnter:Connect(function() Tw(obj, .1, {BackgroundColor3=h}) end)
	obj.MouseLeave:Connect(function() Tw(obj, .1, {BackgroundColor3=n}) end)
end

-- ── Drag ─────────────────────────────────────────────────────────────────────

local function MakeDraggable(frame, handle)
	handle = handle or frame
	local drag, ds, sp
	handle.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		drag=true; ds=i.Position; sp=frame.Position
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then drag=false end
		end)
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not drag or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local d = i.Position - ds
		frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
	end)
end

-- ── Resize ────────────────────────────────────────────────────────────────────

local function MakeResizable(frame, mn, mx)
	mn = mn or Vector2.new(420, 300)
	mx = mx or Vector2.new(950, 750)
	local dirs = {
		TopLeft={x=-1,y=-1}, TopRight={x=1,y=-1},
		BottomLeft={x=-1,y=1}, BottomRight={x=1,y=1},
	}
	local resizing, corner, ms, ss, ps
	local rf = New("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, ZIndex=100}, frame)
	for name, dir in pairs(dirs) do
		local h = New("Frame", {Name=name, Size=UDim2.fromOffset(16,16), BackgroundTransparency=1, ZIndex=101}, rf)
		if name=="TopLeft"     then h.Position=UDim2.fromOffset(-5,-5) end
		if name=="TopRight"    then h.Position=UDim2.new(1,-11,0,-5) end
		if name=="BottomLeft"  then h.Position=UDim2.new(0,-5,1,-11) end
		if name=="BottomRight" then h.Position=UDim2.new(1,-11,1,-11) end
		h.InputBegan:Connect(function(i)
			if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			resizing=true; corner=dir
			ms=Vector2.new(Mouse.X,Mouse.Y); ss=frame.AbsoluteSize; ps=frame.Position
		end)
		h.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing=false end
		end)
	end
	RunService.RenderStepped:Connect(function()
		if not resizing then return end
		local d = Vector2.new(Mouse.X,Mouse.Y) - ms
		local nw = math.clamp(ss.X+d.X*corner.x, mn.X, mx.X)
		local nh = math.clamp(ss.Y+d.Y*corner.y, mn.Y, mx.Y)
		local ox = (nw-ss.X) * (corner.x==-1 and -1 or 0)
		local oy = (nh-ss.Y) * (corner.y==-1 and -1 or 0)
		frame.Size = UDim2.fromOffset(nw, nh)
		frame.Position = UDim2.new(ps.X.Scale, ps.X.Offset+ox, ps.Y.Scale, ps.Y.Offset+oy)
	end)
end

-- ── Notification ──────────────────────────────────────────────────────────────

local NotifHolder = nil
local nN = 0

local function FireNotif(title, desc, ntype, dur)
	if not NotifHolder then return end
	dur=dur or 2.5; ntype=ntype or "info"; nN+=1
	local ac = {success=T.Green, info=T.Accent, warning=T.Amber, error=T.Red}
	local ic = {success="✓", info="i", warning="!", error="×"}
	local col = ac[ntype] or T.Accent

	local card = New("Frame", {
		Name="N"..nN, Size=UDim2.new(1,0,0,0),
		AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundColor3=T.BG3, BorderSizePixel=0,
		ClipsDescendants=true, LayoutOrder=nN,
		Position=UDim2.new(1,20,0,0),
	}, NotifHolder)
	New("UICorner", {CornerRadius=UDim.new(0,T.Radius)}, card)
	Stroke(card, 0.14)
	New("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,10), VerticalAlignment=Enum.VerticalAlignment.Top}, card)
	New("UIPadding", {PaddingTop=UDim.new(0,11), PaddingBottom=UDim.new(0,11), PaddingLeft=UDim.new(0,11), PaddingRight=UDim.new(0,11)}, card)

	local ib = New("Frame", {Size=UDim2.fromOffset(28,28), BackgroundColor3=col, BackgroundTransparency=0.78, BorderSizePixel=0}, card)
	New("UICorner", {CornerRadius=UDim.new(0,7)}, ib)
	New("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=ic[ntype] or "i", TextColor3=col, TextSize=12, Font=Enum.Font.GothamBold}, ib)

	local col2 = New("Frame", {Size=UDim2.new(1,-50,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, BorderSizePixel=0}, card)
	New("UIListLayout", {Padding=UDim.new(0,3)}, col2)
	New("TextLabel", {Size=UDim2.new(1,0,0,17), BackgroundTransparency=1, Text=title, TextColor3=T.TP, TextSize=13.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, col2)
	New("TextLabel", {Size=UDim2.new(1,0,0,14), BackgroundTransparency=1, Text=desc, TextColor3=col, TextTransparency=0.3, TextSize=11.5, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left}, col2)

	local tr = New("Frame", {Size=UDim2.new(1,0,0,2), BackgroundColor3=T.Surface2, BorderSizePixel=0}, col2)
	New("UICorner", {CornerRadius=UDim.new(0,1)}, tr)
	local bar = New("Frame", {Size=UDim2.fromScale(1,1), BackgroundColor3=col, BorderSizePixel=0}, tr)
	New("UICorner", {CornerRadius=UDim.new(0,1)}, bar)

	card.BackgroundTransparency = 1
	task.spawn(function()
		Tw(card, .28, {BackgroundTransparency=0, Position=UDim2.fromScale(0,0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		Tw(bar, dur, {Size=UDim2.fromScale(0,1)}, Enum.EasingStyle.Linear)
		task.wait(dur)
		Tw(card, .2, {BackgroundTransparency=1, Position=UDim2.new(1,20,0,0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.wait(.22); card:Destroy()
	end)
end

-- ── Library ───────────────────────────────────────────────────────────────────

local Library = {}

function Library:CreateWindow(Settings)
	Settings = Settings or {}
	local title        = Settings.Title or "UI Library"
	local size         = Settings.Size  or UDim2.fromOffset(660, 480)
	local keybind      = Settings.MinimizeKeybind or Enum.KeyCode.LeftControl
	local transparency = Settings.Transparency or 0

	-- Apply theme
	if Settings.Theme == "Light" then
		for k,v in pairs(LightT) do T[k]=v end
	end
	if Settings.Accent then T.Accent = Settings.Accent end

	-- ── ScreenGui ─────────────────────────────────────────────────────────────
	local gui = Instance.new("ScreenGui")
	gui.Name = "UILib_"..title
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = true
	if not pcall(function() gui.Parent = game:GetService("CoreGui") end) or not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	-- ── Window ────────────────────────────────────────────────────────────────
	local isCanvas = true
	local win
	if not pcall(function() win = Instance.new("CanvasGroup") end) or not win then
		win = Instance.new("Frame"); isCanvas = false
	end
	win.Name = "Window"; win.Size = size
	win.Position = UDim2.fromScale(0.5, 0.5); win.AnchorPoint = Vector2.new(0.5, 0.5)
	win.BackgroundColor3 = T.BG2; win.BorderSizePixel = 0
	if isCanvas then win.GroupTransparency = transparency else win.BackgroundTransparency = transparency end
	win.Parent = gui
	New("UICorner", {CornerRadius=UDim.new(0,14)}, win)
	Stroke(win, 0.12, 1)

	local function SetAlpha(a)
		if isCanvas then win.GroupTransparency = a else win.BackgroundTransparency = a end
	end

	-- ── Titlebar ──────────────────────────────────────────────────────────────
	local tb = New("Frame", {Size=UDim2.new(1,0,0,T.TitleH), BackgroundColor3=T.BG, BorderSizePixel=0, ZIndex=2}, win)
	New("UICorner", {CornerRadius=UDim.new(0,14)}, tb)
	New("Frame", {Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14), BackgroundColor3=T.BG, BorderSizePixel=0}, tb)
	New("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0.9, BorderSizePixel=0}, tb)

	-- 3 dots
	local dh = New("Frame", {Size=UDim2.fromOffset(72,T.TitleH), BackgroundTransparency=1, ZIndex=3}, tb)
	New("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,7), VerticalAlignment=Enum.VerticalAlignment.Center}, dh)
	New("UIPadding", {PaddingLeft=UDim.new(0,14)}, dh)

	local dotDefs = {
		{Color3.fromRGB(255,95,87),  Color3.fromRGB(195,45,38),  "×"},
		{Color3.fromRGB(254,188,46), Color3.fromRGB(195,138,10), "−"},
		{Color3.fromRGB(40,200,64),  Color3.fromRGB(18,155,38),  "+"},
	}
	local dots = {}
	for i, c in ipairs(dotDefs) do
		local dot = New("Frame", {Size=UDim2.fromOffset(13,13), BackgroundColor3=c[1], BorderSizePixel=0, ZIndex=4}, dh)
		New("UICorner", {CornerRadius=UDim.new(0.5,0)}, dot)
		local sym = New("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=c[3], TextColor3=Color3.fromRGB(60,15,5), TextSize=9, Font=Enum.Font.GothamBold, Visible=false, ZIndex=5}, dot)
		dots[i] = {frame=dot, sym=sym}
		dot.MouseEnter:Connect(function() Tw(dot,.1,{BackgroundColor3=c[2]}); sym.Visible=true end)
		dot.MouseLeave:Connect(function() Tw(dot,.1,{BackgroundColor3=c[1]}); sym.Visible=false end)
	end

	New("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text=title, TextColor3=T.TS, TextSize=13, Font=Enum.Font.GothamBold, ZIndex=3}, tb)

	-- ── Sidebar ───────────────────────────────────────────────────────────────
	local sb = New("Frame", {Name="Sidebar", Size=UDim2.new(0,T.SideW,1,-T.TitleH), Position=UDim2.fromOffset(0,T.TitleH), BackgroundColor3=T.BG, BorderSizePixel=0, ClipsDescendants=true}, win)
	New("Frame", {Size=UDim2.new(1,0,0,2), BackgroundColor3=T.Accent, BackgroundTransparency=0.45, BorderSizePixel=0, ZIndex=5}, sb)
	New("Frame", {Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0), BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0.9, BorderSizePixel=0}, sb)
	New("Frame", {Size=UDim2.fromOffset(14,14), BackgroundColor3=T.BG, BorderSizePixel=0, ZIndex=2}, sb)

	local sbList = New("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0}, sb)
	New("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder}, sbList)
	New("UIPadding", {PaddingTop=UDim.new(0,12), PaddingBottom=UDim.new(0,12)}, sbList)

	-- ── Content ───────────────────────────────────────────────────────────────
	local content = New("Frame", {Name="Content", Size=UDim2.new(1,-T.SideW,1,-T.TitleH), Position=UDim2.new(0,T.SideW,0,T.TitleH), BackgroundColor3=T.BG3, BorderSizePixel=0, ClipsDescendants=true}, win)

	-- ── Notif holder (floats on screen) ───────────────────────────────────────
	NotifHolder = New("Frame", {Name="Notifs", Size=UDim2.new(0,275,1,0), Position=UDim2.new(1,-291,0,0), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=9999, ClipsDescendants=false}, gui)
	New("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Bottom, HorizontalAlignment=Enum.HorizontalAlignment.Right}, NotifHolder)
	New("UIPadding", {PaddingBottom=UDim.new(0,20)}, NotifHolder)

	-- ── Open / Close ──────────────────────────────────────────────────────────
	local visible = true; local maximized = false; local preSz, prePo

	local function Open()
		win.Visible = true; SetAlpha(1)
		win.Size = UDim2.new(size.X.Scale, size.X.Offset*.94, size.Y.Scale, size.Y.Offset*.94)
		Tw(win, .22, {Size=size})
		if isCanvas then Tw(win,.22,{GroupTransparency=transparency}) else Tw(win,.22,{BackgroundTransparency=transparency}) end
		visible = true
	end

	local function Close()
		local s = UDim2.new(size.X.Scale, size.X.Offset*.94, size.Y.Scale, size.Y.Offset*.94)
		Tw(win, .18, {Size=s})
		if isCanvas then Tw(win,.18,{GroupTransparency=1}) else Tw(win,.18,{BackgroundTransparency=1}) end
		task.delay(.2, function() win.Visible=false; win.Size=size end)
		visible = false
	end

	dots[1].frame.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		Tw(win,.14,{Size=UDim2.new(size.X.Scale,size.X.Offset*.88,size.Y.Scale,size.Y.Offset*.88)})
		SetAlpha(1); task.delay(.16, function() gui:Destroy() end)
	end)
	dots[2].frame.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if visible then Close() else Open() end
	end)
	dots[3].frame.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not maximized then
			preSz=win.Size; prePo=win.Position; maximized=true
			Tw(win,.2,{Size=UDim2.fromScale(1,1), Position=UDim2.fromScale(0.5,0.5)})
		else
			maximized=false; Tw(win,.2,{Size=preSz, Position=prePo})
		end
	end)

	UserInputService.InputBegan:Connect(function(inp, gpe)
		if gpe then return end
		if inp.KeyCode == keybind then if visible then Close() else Open() end end
	end)

	MakeDraggable(win, tb)
	MakeResizable(win)
	Open()

	-- ── Options (Window API) ──────────────────────────────────────────────────
	local Options = {}
	local tabBtns  = {}
	local tabPages = {}
	local activeTab = nil
	local sOrder = 0
	local sectionOrders = {}  -- section name → order

	-- ── Sidebar section header ────────────────────────────────────────────────
	local function SideSection(text, order)
		sOrder = math.max(sOrder, order or sOrder) + (order and 0 or 1)
		local ord = order or sOrder
		local w = New("Frame", {Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, BorderSizePixel=0, LayoutOrder=ord*1000-500}, sbList)
		New("Frame", {Size=UDim2.new(1,-24,0,1), Position=UDim2.fromOffset(12,0), BackgroundColor3=T.Accent, BackgroundTransparency=0.72, BorderSizePixel=0}, w)
		New("TextLabel", {Size=UDim2.new(1,-28,1,-4), Position=UDim2.fromOffset(14,6), BackgroundTransparency=1, Text=text:upper(), TextColor3=T.Accent, TextTransparency=0.22, TextSize=10, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, w)
	end

	-- SetTab
	function Options:SetTab(name)
		for n, b in pairs(tabBtns) do
			local on = (n==name)
			Tw(b.frame, .15, {BackgroundColor3=on and T.Accent or Color3.fromRGB(0,0,0), BackgroundTransparency=on and 0 or 1})
			Tw(b.label, .15, {TextColor3=on and Color3.fromRGB(255,255,255) or T.TS})
			b.label.Font = on and Enum.Font.GothamBold or Enum.Font.Gotham
			if b.bar then Tw(b.bar,.15,{BackgroundTransparency=on and 0 or 1}) end
		end
		for n, pg in pairs(tabPages) do
			if n==name then
				pg.Visible = true
				pcall(function() pg.GroupTransparency=1; Tw(pg,.18,{GroupTransparency=0}) end)
			elseif pg.Visible then
				pcall(function() Tw(pg,.12,{GroupTransparency=1}) end)
				task.delay(.14, function() pg.Visible=false end)
			end
		end
		activeTab = name
	end

	-- AddTabSection (Torch API)
	function Options:AddTabSection(cfg)
		cfg = cfg or {}
		sectionOrders[cfg.Name or ""] = cfg.Order or 1
		SideSection(cfg.Name or "", cfg.Order)
	end

	-- AddTab (Torch API) — returns ScrollingFrame
	function Options:AddTab(cfg)
		cfg = cfg or {}
		local tabTitle  = cfg.Title or "Tab"
		local sectionName = cfg.Section
		local sectionOrd = sectionOrders[sectionName] or 1

		sOrder += 1
		local ord = sectionOrd * 1000 + sOrder

		local btn = New("TextButton", {Name=tabTitle, Size=UDim2.new(1,-16,0,38), Position=UDim2.fromOffset(8,0), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=1, BorderSizePixel=0, Text="", AutoButtonColor=false, LayoutOrder=ord}, sbList)
		New("UICorner", {CornerRadius=UDim.new(0,9)}, btn)

		local row = New("Frame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0}, btn)
		New("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,9), VerticalAlignment=Enum.VerticalAlignment.Center}, row)
		New("UIPadding", {PaddingLeft=UDim.new(0,11), PaddingRight=UDim.new(0,10)}, row)

		local icoF = New("Frame", {Size=UDim2.fromOffset(24,24), BackgroundColor3=T.Surface, BorderSizePixel=0}, row)
		New("UICorner", {CornerRadius=UDim.new(0,7)}, icoF)
		if cfg.Icon then
			New("ImageLabel", {Size=UDim2.fromOffset(15,15), Position=UDim2.fromOffset(4,4), BackgroundTransparency=1, Image=cfg.Icon, ImageColor3=T.TS}, icoF)
		end

		local lbl = New("TextLabel", {Size=UDim2.new(1,-36,1,0), BackgroundTransparency=1, Text=tabTitle, TextColor3=T.TS, TextSize=13.5, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, row)

		local bar = New("Frame", {Size=UDim2.new(0,3,0.55,0), Position=UDim2.new(0,0,0.225,0), BackgroundColor3=T.Accent, BackgroundTransparency=1, BorderSizePixel=0, ZIndex=5}, btn)
		New("UICorner", {CornerRadius=UDim.new(0,2)}, bar)

		tabBtns[tabTitle] = {frame=btn, label=lbl, bar=bar, ico=icoF}

		-- Page
		local page = nil
		pcall(function()
			page = Instance.new("CanvasGroup")
			page.Name = tabTitle.."_Page"; page.Size = UDim2.fromScale(1,1)
			page.BackgroundTransparency = 1; page.BorderSizePixel = 0
			page.Visible = false; page.GroupTransparency = 1; page.Parent = content
		end)
		if not page then
			page = New("Frame", {Name=tabTitle.."_Page", Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, Visible=false}, content)
		end

		local scroll = New("ScrollingFrame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=T.Surface2, CanvasSize=UDim2.fromScale(0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, page)
		New("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder}, scroll)
		New("UIPadding", {PaddingTop=UDim.new(0,16), PaddingLeft=UDim.new(0,16), PaddingRight=UDim.new(0,16), PaddingBottom=UDim.new(0,16)}, scroll)

		tabPages[tabTitle] = page

		btn.MouseButton1Click:Connect(function() Options:SetTab(tabTitle) end)
		btn.MouseEnter:Connect(function()
			if activeTab ~= tabTitle then Tw(btn,.1,{BackgroundColor3=T.Surface, BackgroundTransparency=0}) end
		end)
		btn.MouseLeave:Connect(function()
			if activeTab ~= tabTitle then Tw(btn,.1,{BackgroundTransparency=1}) end
		end)
		if not activeTab then Options:SetTab(tabTitle) end

		return scroll  -- ← Torch API returns ScrollingFrame
	end

	-- ── Card helpers ──────────────────────────────────────────────────────────

	local cardOrders = {}  -- scroll → counter

	local function NextOrder(scroll)
		cardOrders[scroll] = (cardOrders[scroll] or 0) + 1
		return cardOrders[scroll]
	end

	local function MakeCard(scroll, h)
		local c = New("Frame", {
			Size=UDim2.new(1,0,0,h or 66),
			BackgroundColor3=T.BG4, BorderSizePixel=0,
			LayoutOrder=NextOrder(scroll), ClipsDescendants=false,
		}, scroll)
		New("UICorner", {CornerRadius=UDim.new(0,T.Radius)}, c)
		Stroke(c, 0.07)
		return c
	end

	local function CardIcon(parent)
		local f = New("Frame", {Size=UDim2.fromOffset(44,44), Position=UDim2.fromOffset(13,11), BackgroundColor3=T.Surface, BorderSizePixel=0}, parent)
		New("UICorner", {CornerRadius=UDim.new(0,12)}, f)
		return f
	end

	local function CardTitle(parent, text)
		return New("TextLabel", {BackgroundTransparency=1, Text=text, TextColor3=T.TP, TextSize=13.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Bottom, Position=UDim2.new(0,68,0,14), Size=UDim2.new(1,-144,0,19)}, parent)
	end

	local function CardDesc(parent, text)
		if not text or text=="" then return end
		return New("TextLabel", {BackgroundTransparency=1, Text=text, TextColor3=T.TS, TextTransparency=0.1, TextSize=11.5, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, Position=UDim2.new(0,68,0,35), Size=UDim2.new(1,-144,0,17)}, parent)
	end

	-- ── AddSection (Torch API) ────────────────────────────────────────────────
	function Options:AddSection(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab
		if not scroll then return end
		local w = New("Frame", {Size=UDim2.new(1,0,0,26), BackgroundTransparency=1, BorderSizePixel=0, LayoutOrder=NextOrder(scroll)}, scroll)
		New("Frame", {Size=UDim2.new(0,3,0,16), Position=UDim2.fromOffset(0,5), BackgroundColor3=T.Accent, BackgroundTransparency=0.28, BorderSizePixel=0}, w)
		New("TextLabel", {Size=UDim2.new(1,-12,1,0), Position=UDim2.fromOffset(10,0), BackgroundTransparency=1, Text=(cfg.Name or ""):upper(), TextColor3=T.Accent, TextTransparency=0.22, TextSize=10.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, w)
	end

	-- ── AddButton ─────────────────────────────────────────────────────────────
	function Options:AddButton(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab; if not scroll then return end
		local card = MakeCard(scroll, 66)
		Hover(card, T.BG4, T.Surface)

		local icoF = CardIcon(card)
		New("TextLabel", {Size=UDim2.fromOffset(14,14), Position=UDim2.fromOffset(15,15), BackgroundTransparency=1, Text="›", TextColor3=T.TS, TextSize=20, Font=Enum.Font.Gotham}, icoF)

		CardTitle(card, cfg.Title or "Button")
		CardDesc(card, cfg.Description)
		New("TextLabel", {Size=UDim2.fromOffset(22,34), Position=UDim2.new(1,-30,0.5,-17), BackgroundTransparency=1, Text="›", TextColor3=T.TT, TextSize=20, Font=Enum.Font.Gotham}, card)

		local btn = New("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=5}, card)
		btn.MouseButton1Click:Connect(function()
			Tw(card,.07,{BackgroundColor3=T.Surface2})
			task.delay(.14, function() Tw(card,.12,{BackgroundColor3=T.BG4}) end)
			if cfg.Callback then cfg.Callback() end
		end)
	end

	-- ── AddToggle ─────────────────────────────────────────────────────────────
	function Options:AddToggle(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab; if not scroll then return end
		local state = cfg.Default or false
		local card = MakeCard(scroll, 66)
		Hover(card, T.BG4, T.Surface)

		local icoF = CardIcon(card)
		local dot = New("Frame", {Size=UDim2.fromOffset(18,18), Position=UDim2.fromOffset(13,13), BackgroundColor3=T.Accent, BorderSizePixel=0}, icoF)
		New("UICorner", {CornerRadius=UDim.new(0.5,0)}, dot)

		CardTitle(card, cfg.Title or "Toggle")
		local subLbl = New("TextLabel", {BackgroundTransparency=1, Text=state and "● Active" or "● Disabled", TextColor3=state and T.Green or T.TT, TextSize=11.5, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, Position=UDim2.new(0,68,0,35), Size=UDim2.new(1,-144,0,17)}, card)

		local track = New("Frame", {Size=UDim2.fromOffset(42,24), Position=UDim2.new(1,-56,0.5,-12), BackgroundColor3=state and T.Green or T.Surface2, BorderSizePixel=0}, card)
		New("UICorner", {CornerRadius=UDim.new(0,12)}, track); Stroke(track, 0.12)
		local thumb = New("Frame", {Size=UDim2.fromOffset(20,20), Position=state and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0}, track)
		New("UICorner", {CornerRadius=UDim.new(0.5,0)}, thumb)

		local cb = New("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=5}, card)

		local function SV(v)
			state = v
			Spring(thumb, .22, {Position=v and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)})
			Tw(track, .18, {BackgroundColor3=v and T.Green or T.Surface2})
			Tw(dot, .18, {BackgroundColor3=v and T.Accent or T.TT})
			subLbl.Text = v and "● Active" or "● Disabled"
			subLbl.TextColor3 = v and T.Green or T.TT
			if cfg.Callback then cfg.Callback(v) end
		end

		cb.MouseButton1Click:Connect(function() SV(not state) end)
		return {Set=SV, Get=function() return state end}
	end

	-- ── AddSlider ─────────────────────────────────────────────────────────────
	function Options:AddSlider(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab; if not scroll then return end
		local mn   = 0
		local mx   = cfg.MaxValue or 100
		local decs = cfg.AllowDecimals and (cfg.DecimalAmount or 1) or 0
		local cur  = 0
		local card = MakeCard(scroll, 76)

		local function fmt(v)
			if decs>0 then return string.format("%."..decs.."f",v) end
			return tostring(math.round(v))
		end

		New("TextLabel", {Size=UDim2.new(0.6,0,0,22), Position=UDim2.fromOffset(16,14), BackgroundTransparency=1, Text=cfg.Title or "Slider", TextColor3=T.TP, TextSize=13.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, card)
		if cfg.Description and cfg.Description ~= "" then
			New("TextLabel", {Size=UDim2.new(0.6,0,0,16), Position=UDim2.fromOffset(16,34), BackgroundTransparency=1, Text=cfg.Description, TextColor3=T.TS, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, card)
		end
		local vLbl = New("TextLabel", {Size=UDim2.new(0.4,-16,0,22), Position=UDim2.new(0.6,0,0,14), BackgroundTransparency=1, Text=fmt(cur), TextColor3=T.Accent, TextSize=13.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right}, card)

		local tbg = New("Frame", {Size=UDim2.new(1,-32,0,4), Position=UDim2.fromOffset(16,52), BackgroundColor3=T.Surface2, BorderSizePixel=0}, card)
		New("UICorner", {CornerRadius=UDim.new(0,2)}, tbg)
		local fill = New("Frame", {Size=UDim2.fromScale(0,1), BackgroundColor3=T.Accent, BorderSizePixel=0}, tbg)
		New("UICorner", {CornerRadius=UDim.new(0,2)}, fill)
		local thmb = New("Frame", {Size=UDim2.fromOffset(18,18), Position=UDim2.new(0,-9,0.5,-9), BackgroundColor3=Color3.fromRGB(255,255,255), BorderSizePixel=0, ZIndex=3}, tbg)
		New("UICorner", {CornerRadius=UDim.new(0.5,0)}, thmb)
		local hit = New("TextButton", {Size=UDim2.new(1,0,0,24), Position=UDim2.fromOffset(0,-10), BackgroundTransparency=1, Text="", ZIndex=10}, tbg)

		local dragging = false
		local function Upd(mouseX)
			local s = math.clamp((mouseX - tbg.AbsolutePosition.X) / tbg.AbsoluteSize.X, 0, 1)
			local v = mn + s*(mx-mn)
			if decs==0 then v=math.round(v) end
			cur = v
			local sc = (v-mn)/(mx-mn)
			Tw(fill,.05,{Size=UDim2.fromScale(sc,1)})
			Tw(thmb,.05,{Position=UDim2.new(sc,-9,0.5,-9)})
			vLbl.Text = fmt(v)
			if cfg.Callback then cfg.Callback(v) end
		end
		hit.MouseButton1Down:Connect(function() dragging=true; Upd(Mouse.X) end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
		end)
		RunService.RenderStepped:Connect(function()
			if dragging then Upd(Mouse.X) end
		end)
	end

	-- ── AddInput ──────────────────────────────────────────────────────────────
	function Options:AddInput(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab; if not scroll then return end
		local card = MakeCard(scroll, 64)

		New("TextLabel", {Size=UDim2.new(0.45,0,0,22), Position=UDim2.fromOffset(16,21), BackgroundTransparency=1, Text=cfg.Title or "Input", TextColor3=T.TP, TextSize=13.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, card)

		local box = New("TextBox", {Size=UDim2.new(0.5,-22,0,30), Position=UDim2.new(0.5,0,0,17), BackgroundColor3=T.Surface, BorderSizePixel=0, Text=cfg.Default or "", PlaceholderText=cfg.Description or "Type here...", TextColor3=T.TP, PlaceholderColor3=T.TT, TextSize=12.5, Font=Enum.Font.Gotham, ClearTextOnFocus=false}, card)
		New("UICorner", {CornerRadius=UDim.new(0,7)}, box)
		New("UIPadding", {PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8)}, box)
		local st = Stroke(box, 0.12)

		box.Focused:Connect(function() if st then Tw(st,.15,{Color=T.Accent, Transparency=0.3}) end end)
		box.FocusLost:Connect(function()
			if st then Tw(st,.15,{Color=Color3.fromRGB(255,255,255), Transparency=0.88}) end
			if cfg.Callback then cfg.Callback(box.Text) end
		end)
	end

	-- ── AddDropdown ───────────────────────────────────────────────────────────
	function Options:AddDropdown(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab; if not scroll then return end
		local opts = cfg.Options or {}
		-- รองรับทั้ง array {"A","B"} และ dict {["A"]="a", ["B"]="b"} แบบ Torch
		local optionKeys = {}
		local optionMap  = {}
		for k, v in pairs(opts) do
			if type(k) == "number" then
				table.insert(optionKeys, v)
				optionMap[v] = v
			else
				table.insert(optionKeys, k)
				optionMap[k] = v
			end
		end
		local sel = optionKeys[1] or ""

		local card = MakeCard(scroll, 66)
		Hover(card, T.BG4, T.Surface)

		New("TextLabel", {Size=UDim2.new(0.5,0,0,22), Position=UDim2.fromOffset(16,22), BackgroundTransparency=1, Text=cfg.Title or "Dropdown", TextColor3=T.TP, TextSize=13.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, card)
		local selLbl = New("TextLabel", {Size=UDim2.new(0.45,-30,0,22), Position=UDim2.new(0.5,0,0,22), BackgroundTransparency=1, Text=sel, TextColor3=T.TS, TextSize=12.5, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Right}, card)
		New("TextLabel", {Size=UDim2.fromOffset(20,32), Position=UDim2.new(1,-28,0.5,-16), BackgroundTransparency=1, Text="⌄", TextColor3=T.TT, TextSize=15, Font=Enum.Font.Gotham}, card)

		local function OD()
			local menuH = math.min(#optionKeys*38+10, 220)
			local menu = New("Frame", {Size=UDim2.new(0,200,0,menuH), Position=UDim2.new(0,0,1,6), BackgroundColor3=T.BG2, BorderSizePixel=0, ZIndex=60, ClipsDescendants=true}, card)
			New("UICorner", {CornerRadius=UDim.new(0,11)}, menu); Stroke(menu,0.15)
			local sf = New("ScrollingFrame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=T.Surface2, CanvasSize=UDim2.fromScale(0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, menu)
			New("UIListLayout", {Padding=UDim.new(0,0)}, sf)
			New("UIPadding", {PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5)}, sf)

			for _, key in ipairs(optionKeys) do
				local ob = New("Frame", {Size=UDim2.new(1,0,0,38), BackgroundColor3=key==sel and T.Surface or T.BG2, BorderSizePixel=0}, sf)
				Hover(ob, key==sel and T.Surface or T.BG2, T.Surface)
				New("TextLabel", {Size=UDim2.new(1,-40,1,0), Position=UDim2.fromOffset(14,0), BackgroundTransparency=1, Text=key, TextColor3=key==sel and T.Accent or T.TP, TextSize=13, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, ob)
				if key==sel then
					New("TextLabel", {Size=UDim2.fromOffset(22,38), Position=UDim2.new(1,-24,0,0), BackgroundTransparency=1, Text="✓", TextColor3=T.Accent, TextSize=13, Font=Enum.Font.GothamBold}, ob)
				end
				local hb = New("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=5}, ob)
				hb.MouseButton1Click:Connect(function()
					sel = key; selLbl.Text = key
					if cfg.Callback then cfg.Callback(optionMap[key]) end
					menu:Destroy()
				end)
			end

			local conn; conn = UserInputService.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 then
					task.delay(.06, function() if menu and menu.Parent then menu:Destroy() end end)
					conn:Disconnect()
				end
			end)
		end

		local cb = New("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=5}, card)
		cb.MouseButton1Click:Connect(OD)
	end

	-- ── AddMultiSelect ────────────────────────────────────────────────────────
	function Options:AddMultiSelect(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab; if not scroll then return end
		local opts = cfg.Options or {}
		local selected = {}
		if cfg.Default then for _,v in ipairs(cfg.Default) do selected[v]=true end end

		local function selList()
			local t={}; for _,o in ipairs(opts) do if selected[o] then table.insert(t,o) end end; return t
		end
		local function cntTxt()
			local n=0; for _ in pairs(selected) do n+=1 end
			return n==0 and "None" or n.." selected"
		end

		local card = MakeCard(scroll, 66)
		Hover(card, T.BG4, T.Surface)

		New("TextLabel", {Size=UDim2.new(0.5,0,0,22), Position=UDim2.fromOffset(16,22), BackgroundTransparency=1, Text=cfg.Title or "Multi-Select", TextColor3=T.TP, TextSize=13.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, card)
		local cLbl = New("TextLabel", {Size=UDim2.new(0.45,-30,0,22), Position=UDim2.new(0.5,0,0,22), BackgroundTransparency=1, Text=cntTxt(), TextColor3=T.TS, TextSize=12.5, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Right}, card)
		New("TextLabel", {Size=UDim2.fromOffset(20,32), Position=UDim2.new(1,-28,0.5,-16), BackgroundTransparency=1, Text="⌄", TextColor3=T.TT, TextSize=15, Font=Enum.Font.Gotham}, card)

		local function OM()
			local mH = math.min(#opts*40+10, 220)
			local menu = New("Frame", {Size=UDim2.new(0,220,0,mH), Position=UDim2.new(0,0,1,6), BackgroundColor3=T.BG2, BorderSizePixel=0, ZIndex=60, ClipsDescendants=true}, card)
			New("UICorner", {CornerRadius=UDim.new(0,11)}, menu); Stroke(menu,0.15)
			local sf = New("ScrollingFrame", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=T.Surface2, CanvasSize=UDim2.fromScale(0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, menu)
			New("UIListLayout", {Padding=UDim.new(0,0)}, sf)
			New("UIPadding", {PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5)}, sf)

			for _, opt in ipairs(opts) do
				local ob = New("Frame", {Size=UDim2.new(1,0,0,40), BackgroundColor3=T.BG2, BorderSizePixel=0}, sf)
				Hover(ob, T.BG2, T.Surface)
				local bx = New("Frame", {Size=UDim2.fromOffset(20,20), Position=UDim2.fromOffset(12,10), BackgroundColor3=selected[opt] and T.Accent or T.Surface2, BorderSizePixel=0}, ob)
				New("UICorner", {CornerRadius=UDim.new(0,6)}, bx); Stroke(bx,0.15)
				local chk = New("TextLabel", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="✓", TextColor3=Color3.fromRGB(255,255,255), TextSize=12, Font=Enum.Font.GothamBold, Visible=selected[opt]}, bx)
				New("TextLabel", {Size=UDim2.new(1,-44,1,0), Position=UDim2.fromOffset(40,0), BackgroundTransparency=1, Text=opt, TextColor3=T.TP, TextSize=13, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, ob)
				local hb = New("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=5}, ob)
				hb.MouseButton1Click:Connect(function()
					selected[opt] = not selected[opt]
					Tw(bx,.15,{BackgroundColor3=selected[opt] and T.Accent or T.Surface2})
					chk.Visible = selected[opt]
					cLbl.Text = cntTxt()
					if cfg.Callback then cfg.Callback(selList()) end
				end)
			end

			local conn; conn = UserInputService.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 then
					task.delay(.08, function() if menu and menu.Parent then menu:Destroy() end end)
					conn:Disconnect()
				end
			end)
		end

		local cb = New("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=5}, card)
		cb.MouseButton1Click:Connect(OM)
	end

	-- ── AddListbox ────────────────────────────────────────────────────────────
	function Options:AddListbox(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab; if not scroll then return end
		local opts = cfg.Options or {}
		local sel  = cfg.Default or (opts[1] or "")
		local vis  = math.min(cfg.MaxVisible or 5, #opts)
		local rH   = 40
		local cH   = vis*rH + 16 + 26

		local card = New("Frame", {Size=UDim2.new(1,0,0,cH), BackgroundColor3=T.BG4, BorderSizePixel=0, LayoutOrder=NextOrder(scroll), ClipsDescendants=true}, scroll)
		New("UICorner", {CornerRadius=UDim.new(0,T.Radius)}, card); Stroke(card,0.07)
		New("TextLabel", {Size=UDim2.new(1,-16,0,26), Position=UDim2.fromOffset(16,0), BackgroundTransparency=1, Text=(cfg.Title or ""):upper(), TextColor3=T.TT, TextSize=10.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, card)

		local sf = New("ScrollingFrame", {Size=UDim2.new(1,0,1,-26), Position=UDim2.fromOffset(0,26), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=3, ScrollBarImageColor3=T.Surface2, CanvasSize=UDim2.fromScale(0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y}, card)
		New("UIListLayout", {Padding=UDim.new(0,0), SortOrder=Enum.SortOrder.LayoutOrder}, sf)

		local rows = {}
		local function Refresh()
			for opt, rb in pairs(rows) do
				local on = (opt==sel)
				Tw(rb.f,.12,{BackgroundColor3=on and T.Surface or T.BG4})
				rb.l.TextColor3 = on and T.TP or T.TS
				rb.l.Font = on and Enum.Font.GothamBold or Enum.Font.Gotham
				rb.d.Visible = on; rb.c.Visible = on
			end
		end

		for i, opt in ipairs(opts) do
			local row = New("Frame", {Size=UDim2.new(1,0,0,rH), BackgroundColor3=opt==sel and T.Surface or T.BG4, BorderSizePixel=0, LayoutOrder=i}, sf)
			if i<#opts then
				New("Frame", {Size=UDim2.new(1,-16,0,1), Position=UDim2.new(0,8,1,-1), BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0.92, BorderSizePixel=0}, row)
			end
			local dot = New("Frame", {Size=UDim2.fromOffset(7,7), Position=UDim2.fromOffset(14,16), BackgroundColor3=T.Accent, BorderSizePixel=0, Visible=opt==sel}, row)
			New("UICorner", {CornerRadius=UDim.new(0.5,0)}, dot)
			local lbl = New("TextLabel", {Size=UDim2.new(1,-50,1,0), Position=UDim2.fromOffset(30,0), BackgroundTransparency=1, Text=opt, TextColor3=opt==sel and T.TP or T.TS, TextSize=13, Font=opt==sel and Enum.Font.GothamBold or Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, row)
			local chk = New("TextLabel", {Size=UDim2.fromOffset(24,rH), Position=UDim2.new(1,-28,0,0), BackgroundTransparency=1, Text="✓", TextColor3=T.Accent, TextSize=14, Font=Enum.Font.GothamBold, Visible=opt==sel}, row)
			rows[opt] = {f=row, l=lbl, d=dot, c=chk}
			Hover(row, opt==sel and T.Surface or T.BG4, T.Surface2)
			local hb = New("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", ZIndex=5}, row)
			hb.MouseButton1Click:Connect(function()
				sel=opt; Refresh()
				if cfg.Callback then cfg.Callback(opt) end
			end)
		end
	end

	-- ── AddKeybind ────────────────────────────────────────────────────────────
	function Options:AddKeybind(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab; if not scroll then return end
		local ck = nil; local ls = false
		local hasDesc = cfg.Description and cfg.Description ~= ""
		local card = MakeCard(scroll, hasDesc and 72 or 64)
		Hover(card, T.BG4, T.Surface)

		New("TextLabel", {Size=UDim2.new(0.55,0,0,22), Position=UDim2.fromOffset(16, hasDesc and 16 or 21), BackgroundTransparency=1, Text=cfg.Title or "Keybind", TextColor3=T.TP, TextSize=13.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left}, card)
		if hasDesc then
			New("TextLabel", {Size=UDim2.new(0.55,0,0,17), Position=UDim2.fromOffset(16,38), BackgroundTransparency=1, Text=cfg.Description, TextColor3=T.TT, TextSize=11.5, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left}, card)
		end

		local function KN(k)
			if not k then return "None" end
			local s = tostring(k.KeyCode or k.UserInputType)
			return s:gsub("Enum%.KeyCode%.",""):gsub("Enum%.UserInputType%.",""):gsub("MouseButton","MB")
		end

		local badge = New("TextButton", {Size=UDim2.fromOffset(74,30), Position=UDim2.new(1,-88,0.5,-15), BackgroundColor3=T.Surface2, BorderSizePixel=0, Text="None", TextColor3=T.TP, TextSize=12, Font=Enum.Font.GothamBold, AutoButtonColor=false}, card)
		New("UICorner", {CornerRadius=UDim.new(0,7)}, badge); Stroke(badge,0.12)

		badge.MouseButton1Click:Connect(function()
			if ls then return end; ls=true; badge.Text="..."; Tw(badge,.15,{BackgroundColor3=T.Accent})
			local conn; conn = UserInputService.InputBegan:Connect(function(inp, gpe)
				if gpe then return end
				ls=false; ck=inp; badge.Text=KN(inp)
				Tw(badge,.15,{BackgroundColor3=T.Surface2})
				if cfg.Callback then cfg.Callback(inp) end
				conn:Disconnect()
			end)
		end)
	end

	-- ── AddParagraph ──────────────────────────────────────────────────────────
	function Options:AddParagraph(cfg)
		cfg = cfg or {}
		local scroll = cfg.Tab; if not scroll then return end
		local card = New("Frame", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundColor3=T.BG4, BorderSizePixel=0, LayoutOrder=NextOrder(scroll), ClipsDescendants=false}, scroll)
		New("UICorner", {CornerRadius=UDim.new(0,T.Radius)}, card); Stroke(card,0.07)
		local con = New("Frame", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, BorderSizePixel=0}, card)
		New("UIListLayout", {Padding=UDim.new(0,5)}, con)
		New("UIPadding", {PaddingTop=UDim.new(0,14), PaddingBottom=UDim.new(0,14), PaddingLeft=UDim.new(0,16), PaddingRight=UDim.new(0,16)}, con)
		if cfg.Title and cfg.Title~="" then
			New("TextLabel", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Text=cfg.Title, TextColor3=T.TP, TextSize=13.5, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true}, con)
		end
		if cfg.Description and cfg.Description~="" then
			New("TextLabel", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Text=cfg.Description, TextColor3=T.TS, TextSize=12, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true}, con)
		end
	end

	-- ── Notify ────────────────────────────────────────────────────────────────
	function Options:Notify(cfg)
		cfg = cfg or {}
		FireNotif(cfg.Title or "Notice", cfg.Description or "", cfg.Type or "info", cfg.Duration or 2.5)
	end

	-- ── SetSetting (Torch API compatibility) ──────────────────────────────────
	function Options:SetSetting(setting, value)
		if setting == "Keybind" then
			keybind = value
		elseif setting == "Transparency" then
			SetAlpha(value)
		elseif setting == "Theme" and type(value) == "table" then
			for k,v in pairs(value) do T[k]=v end
		elseif setting == "Size" then
			win.Size = value; size = value
		else
			warn("[UILib] SetSetting: unknown setting '"..tostring(setting).."'")
		end
	end

	return Options
end

return Library
