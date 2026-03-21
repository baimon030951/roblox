--[[
	UI Library — iOS/macOS Style  v3.0
	Made by Torch, redesigned by Claude

	CreateWindow({
		Title   = "My Script",
		Size    = UDim2.fromOffset(560, 420),
		Theme   = "Dark Blue",   -- Dark Red / Dark Blue / Dark Green / Light Red / Light Green / Light Blue
		Keybind = Enum.KeyCode.LeftControl,
	})

	Dot buttons:
		Red    = Destroy UI
		Yellow = Minimize / Restore
		Green  = Maximize / Restore
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

-- ── Theme presets ─────────────────────────────────────────────────────────────

local ThemePresets = {
	["Dark Red"] = {
		BG=Color3.fromRGB(13,10,10), BG2=Color3.fromRGB(20,14,14),
		BG3=Color3.fromRGB(25,17,17), BG4=Color3.fromRGB(32,22,22),
		Surface=Color3.fromRGB(42,26,26), Surface2=Color3.fromRGB(54,30,30),
		TextPrimary=Color3.fromRGB(245,235,235), TextSecondary=Color3.fromRGB(180,145,145),
		TextTertiary=Color3.fromRGB(100,72,72),
		Accent=Color3.fromRGB(220,55,55), AccentDark=Color3.fromRGB(170,35,35),
		Green=Color3.fromRGB(52,201,122), Red=Color3.fromRGB(255,69,58),
		Amber=Color3.fromRGB(255,159,10), Blue=Color3.fromRGB(10,132,255),
	},
	["Dark Blue"] = {
		BG=Color3.fromRGB(10,12,18), BG2=Color3.fromRGB(14,18,28),
		BG3=Color3.fromRGB(17,22,34), BG4=Color3.fromRGB(22,28,44),
		Surface=Color3.fromRGB(28,36,58), Surface2=Color3.fromRGB(35,46,74),
		TextPrimary=Color3.fromRGB(230,238,255), TextSecondary=Color3.fromRGB(140,165,210),
		TextTertiary=Color3.fromRGB(70,92,130),
		Accent=Color3.fromRGB(48,130,255), AccentDark=Color3.fromRGB(24,90,200),
		Green=Color3.fromRGB(52,201,122), Red=Color3.fromRGB(255,69,58),
		Amber=Color3.fromRGB(255,159,10), Blue=Color3.fromRGB(10,132,255),
	},
	["Dark Green"] = {
		BG=Color3.fromRGB(8,14,10), BG2=Color3.fromRGB(12,20,14),
		BG3=Color3.fromRGB(15,25,17), BG4=Color3.fromRGB(20,33,22),
		Surface=Color3.fromRGB(26,44,28), Surface2=Color3.fromRGB(32,56,35),
		TextPrimary=Color3.fromRGB(225,245,230), TextSecondary=Color3.fromRGB(130,185,145),
		TextTertiary=Color3.fromRGB(65,105,75),
		Accent=Color3.fromRGB(40,200,90), AccentDark=Color3.fromRGB(22,150,60),
		Green=Color3.fromRGB(52,201,122), Red=Color3.fromRGB(255,69,58),
		Amber=Color3.fromRGB(255,159,10), Blue=Color3.fromRGB(10,132,255),
	},
	["Light Red"] = {
		BG=Color3.fromRGB(235,228,228), BG2=Color3.fromRGB(248,244,244),
		BG3=Color3.fromRGB(255,252,252), BG4=Color3.fromRGB(245,240,240),
		Surface=Color3.fromRGB(235,228,228), Surface2=Color3.fromRGB(225,214,214),
		TextPrimary=Color3.fromRGB(35,18,18), TextSecondary=Color3.fromRGB(110,70,70),
		TextTertiary=Color3.fromRGB(170,130,130),
		Accent=Color3.fromRGB(200,30,30), AccentDark=Color3.fromRGB(155,18,18),
		Green=Color3.fromRGB(30,160,80), Red=Color3.fromRGB(200,40,30),
		Amber=Color3.fromRGB(190,110,0), Blue=Color3.fromRGB(0,100,210),
	},
	["Light Green"] = {
		BG=Color3.fromRGB(228,238,230), BG2=Color3.fromRGB(244,250,246),
		BG3=Color3.fromRGB(252,255,253), BG4=Color3.fromRGB(238,246,240),
		Surface=Color3.fromRGB(220,236,224), Surface2=Color3.fromRGB(205,226,210),
		TextPrimary=Color3.fromRGB(15,35,20), TextSecondary=Color3.fromRGB(55,105,65),
		TextTertiary=Color3.fromRGB(120,165,130),
		Accent=Color3.fromRGB(22,155,68), AccentDark=Color3.fromRGB(12,110,46),
		Green=Color3.fromRGB(22,155,68), Red=Color3.fromRGB(200,40,30),
		Amber=Color3.fromRGB(190,110,0), Blue=Color3.fromRGB(0,100,210),
	},
	["Light Blue"] = {
		BG=Color3.fromRGB(225,234,248), BG2=Color3.fromRGB(242,247,255),
		BG3=Color3.fromRGB(252,254,255), BG4=Color3.fromRGB(234,242,255),
		Surface=Color3.fromRGB(218,232,252), Surface2=Color3.fromRGB(200,220,248),
		TextPrimary=Color3.fromRGB(12,24,50), TextSecondary=Color3.fromRGB(50,90,155),
		TextTertiary=Color3.fromRGB(115,148,200),
		Accent=Color3.fromRGB(14,100,230), AccentDark=Color3.fromRGB(8,70,175),
		Green=Color3.fromRGB(22,155,68), Red=Color3.fromRGB(200,40,30),
		Amber=Color3.fromRGB(190,110,0), Blue=Color3.fromRGB(14,100,230),
	},
}

-- ── Default theme ─────────────────────────────────────────────────────────────

local Theme = {
	BG=Color3.fromRGB(17,17,19), BG2=Color3.fromRGB(24,24,27),
	BG3=Color3.fromRGB(28,28,31), BG4=Color3.fromRGB(34,34,38),
	Surface=Color3.fromRGB(38,38,43), Surface2=Color3.fromRGB(46,46,52),
	Border=Color3.fromRGB(255,255,255), BorderAlpha=0.07, BorderAlpha2=0.13,
	TextPrimary=Color3.fromRGB(240,240,240), TextSecondary=Color3.fromRGB(154,154,159),
	TextTertiary=Color3.fromRGB(90,90,98),
	Accent=Color3.fromRGB(110,107,255), AccentDark=Color3.fromRGB(90,87,224),
	Green=Color3.fromRGB(52,201,122), Red=Color3.fromRGB(255,69,58),
	Amber=Color3.fromRGB(255,159,10), Blue=Color3.fromRGB(10,132,255),
	Radius=10, RowH=42, SidebarW=148, TitlebarH=36,
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function Tween(obj, t, props, style, dir)
	TweenService:Create(obj,
		TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
		props):Play()
end

local function SpringTween(obj, t, props)
	Tween(obj, t, props, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function New(class, props, parent)
	local obj
	local ok = pcall(function() obj = Instance.new(class) end)
	if not ok or not obj then return nil end
	for k, v in pairs(props) do
		pcall(function() obj[k] = v end)
	end
	if parent then obj.Parent = parent end
	return obj
end

local function Shade(c, a)
	return Color3.fromRGB(
		math.clamp(c.R*255+a,0,255),
		math.clamp(c.G*255+a,0,255),
		math.clamp(c.B*255+a,0,255))
end

local function AddBorder(p, alpha, thickness)
	return New("UIStroke", {
		Color=Theme.Border,
		Transparency=1-(alpha or Theme.BorderAlpha),
		Thickness=thickness or 1,
		ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
	}, p)
end

local function AddHover(obj, n, h)
	obj.MouseEnter:Connect(function() Tween(obj,.12,{BackgroundColor3=h}) end)
	obj.MouseLeave:Connect(function() Tween(obj,.12,{BackgroundColor3=n}) end)
end

-- ── Drag ─────────────────────────────────────────────────────────────────────

local function MakeDraggable(frame, handle)
	handle = handle or frame
	local drag, ds, sp
	handle.InputBegan:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		drag=true; ds=i.Position; sp=frame.Position
		i.Changed:Connect(function()
			if i.UserInputState==Enum.UserInputState.End then drag=false end
		end)
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not drag or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
		local d=i.Position-ds
		frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
	end)
end

-- ── Resize ────────────────────────────────────────────────────────────────────

local function MakeResizable(frame, mn, mx)
	mn = mn or Vector2.new(380,260)
	mx = mx or Vector2.new(900,700)
	local dirs={TopLeft={x=-1,y=-1},TopRight={x=1,y=-1},BottomLeft={x=-1,y=1},BottomRight={x=1,y=1}}
	local resizing, corner, ms, ss, ps
	local rf = New("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=100},frame)
	for name, dir in pairs(dirs) do
		local h = New("Frame",{Name=name,Size=UDim2.fromOffset(14,14),BackgroundTransparency=1,ZIndex=101},rf)
		if name=="TopLeft"     then h.Position=UDim2.fromOffset(-4,-4) end
		if name=="TopRight"    then h.Position=UDim2.new(1,-10,0,-4) end
		if name=="BottomLeft"  then h.Position=UDim2.new(0,-4,1,-10) end
		if name=="BottomRight" then h.Position=UDim2.new(1,-10,1,-10) end
		h.InputBegan:Connect(function(i)
			if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
			resizing=true; corner=dir
			ms=Vector2.new(Mouse.X,Mouse.Y); ss=frame.AbsoluteSize; ps=frame.Position
		end)
		h.InputEnded:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 then resizing=false end
		end)
	end
	RunService.RenderStepped:Connect(function()
		if not resizing then return end
		local d=Vector2.new(Mouse.X,Mouse.Y)-ms
		local nw=math.clamp(ss.X+d.X*corner.x,mn.X,mx.X)
		local nh=math.clamp(ss.Y+d.Y*corner.y,mn.Y,mx.Y)
		local ox=(nw-ss.X)*(corner.x==-1 and -1 or 0)
		local oy=(nh-ss.Y)*(corner.y==-1 and -1 or 0)
		frame.Size=UDim2.fromOffset(nw,nh)
		frame.Position=UDim2.new(ps.X.Scale,ps.X.Offset+ox,ps.Y.Scale,ps.Y.Offset+oy)
	end)
end

-- ── Notification ──────────────────────────────────────────────────────────────

local NotifHolder = nil
local notifN = 0

local function FireNotif(title, desc, ntype, duration)
	if not NotifHolder then return end
	duration = duration or 2.5
	ntype    = ntype or "info"
	notifN   = notifN + 1

	local accentMap = {success=Theme.Green,info=Theme.Blue,warning=Theme.Amber,error=Theme.Red}
	local iconMap   = {success="✓",info="i",warning="!",error="×"}
	local ac = accentMap[ntype] or Theme.Blue

	local card = New("Frame",{
		Name="N"..notifN, Size=UDim2.new(1,0,0,0),
		AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundColor3=Theme.BG3, BorderSizePixel=0,
		ClipsDescendants=true, LayoutOrder=notifN,
		Position=UDim2.new(1,20,0,0),
	}, NotifHolder)
	New("UICorner",{CornerRadius=UDim.new(0,Theme.Radius)},card)
	AddBorder(card, Theme.BorderAlpha2)
	New("UIListLayout",{
		FillDirection=Enum.FillDirection.Horizontal,
		Padding=UDim.new(0,10), VerticalAlignment=Enum.VerticalAlignment.Top,
	},card)
	New("UIPadding",{
		PaddingTop=UDim.new(0,11),PaddingBottom=UDim.new(0,11),
		PaddingLeft=UDim.new(0,11),PaddingRight=UDim.new(0,11),
	},card)

	local ib=New("Frame",{Size=UDim2.fromOffset(28,28),BackgroundColor3=ac,BackgroundTransparency=0.8,BorderSizePixel=0},card)
	New("UICorner",{CornerRadius=UDim.new(0,7)},ib)
	New("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=iconMap[ntype] or "i",TextColor3=ac,TextSize=12,Font=Enum.Font.GothamBold},ib)

	local col=New("Frame",{Size=UDim2.new(1,-50,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0},card)
	New("UIListLayout",{Padding=UDim.new(0,3)},col)
	New("TextLabel",{Size=UDim2.new(1,0,0,17),BackgroundTransparency=1,Text=title,TextColor3=Theme.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},col)
	New("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=desc,TextColor3=ac,TextTransparency=0.3,TextSize=11.5,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left},col)

	local tr=New("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=Theme.Surface2,BorderSizePixel=0},col)
	New("UICorner",{CornerRadius=UDim.new(0,1)},tr)
	local bar=New("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=ac,BorderSizePixel=0},tr)
	New("UICorner",{CornerRadius=UDim.new(0,1)},bar)

	card.BackgroundTransparency=1
	task.spawn(function()
		Tween(card,.28,{BackgroundTransparency=0,Position=UDim2.fromScale(0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		Tween(bar,duration,{Size=UDim2.fromScale(0,1)},Enum.EasingStyle.Linear)
		task.wait(duration)
		Tween(card,.22,{BackgroundTransparency=1,Position=UDim2.new(1,20,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
		task.wait(.25)
		card:Destroy()
	end)
end

-- ── Library ───────────────────────────────────────────────────────────────────

local Library = {}

function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local title        = cfg.Title   or "UI Library"
	local size         = cfg.Size    or UDim2.fromOffset(560,420)
	local keybind      = cfg.Keybind or Enum.KeyCode.LeftControl
	local transparency = cfg.Transparency or 0

	if cfg.Theme and ThemePresets[cfg.Theme] then
		for k,v in pairs(ThemePresets[cfg.Theme]) do Theme[k]=v end
	end
	if cfg.Accent then
		Theme.Accent=cfg.Accent; Theme.AccentDark=Shade(cfg.Accent,-18)
	end

	-- ScreenGui
	local gui=Instance.new("ScreenGui")
	gui.Name="UILib_"..title
	gui.ResetOnSpawn=false
	gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset=true
	if not pcall(function() gui.Parent=game:GetService("CoreGui") end) or not gui.Parent then
		gui.Parent=LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Window (CanvasGroup with Frame fallback)
	local isCanvas=true
	local win
	if not pcall(function() win=Instance.new("CanvasGroup") end) or not win then
		win=Instance.new("Frame"); isCanvas=false
	end
	win.Name="Window"; win.Size=size
	win.Position=UDim2.fromScale(0.5,0.5); win.AnchorPoint=Vector2.new(0.5,0.5)
	win.BackgroundColor3=Theme.BG2; win.BorderSizePixel=0
	if isCanvas then win.GroupTransparency=transparency else win.BackgroundTransparency=transparency end
	win.Parent=gui
	New("UICorner",{CornerRadius=UDim.new(0,14)},win)
	AddBorder(win,0.15,1)

	local function SetAlpha(a)
		if isCanvas then win.GroupTransparency=a else win.BackgroundTransparency=a end
	end

	-- Titlebar
	local titlebar=New("Frame",{Size=UDim2.new(1,0,0,Theme.TitlebarH),BackgroundColor3=Theme.BG,BorderSizePixel=0,ZIndex=2},win)
	New("UICorner",{CornerRadius=UDim.new(0,14)},titlebar)
	New("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=Theme.BG,BorderSizePixel=0},titlebar)
	New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=Theme.Border,BackgroundTransparency=1-Theme.BorderAlpha,BorderSizePixel=0},titlebar)

	local dh=New("Frame",{Size=UDim2.fromOffset(60,Theme.TitlebarH),BackgroundTransparency=1,ZIndex=3},titlebar)
	New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,7),VerticalAlignment=Enum.VerticalAlignment.Center},dh)
	New("UIPadding",{PaddingLeft=UDim.new(0,13)},dh)

	local dotDefs={
		{Color3.fromRGB(255,95,87),Color3.fromRGB(200,50,40),"×"},
		{Color3.fromRGB(254,188,46),Color3.fromRGB(200,140,10),"−"},
		{Color3.fromRGB(40,200,64),Color3.fromRGB(20,160,40),"+"},
	}
	local dots={}
	for i,c in ipairs(dotDefs) do
		local dot=New("Frame",{Size=UDim2.fromOffset(12,12),BackgroundColor3=c[1],BorderSizePixel=0,ZIndex=4},dh)
		New("UICorner",{CornerRadius=UDim.new(0.5,0)},dot)
		local sym=New("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=c[3],TextColor3=Color3.fromRGB(60,15,5),TextSize=9,Font=Enum.Font.GothamBold,Visible=false,ZIndex=5},dot)
		dots[i]={frame=dot,sym=sym}
		dot.MouseEnter:Connect(function() Tween(dot,.1,{BackgroundColor3=c[2]}); sym.Visible=true end)
		dot.MouseLeave:Connect(function() Tween(dot,.1,{BackgroundColor3=c[1]}); sym.Visible=false end)
	end

	New("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=title,TextColor3=Theme.TextSecondary,TextSize=13,Font=Enum.Font.GothamBold,ZIndex=3},titlebar)

	-- Sidebar
	local sidebar=New("Frame",{Name="Sidebar",Size=UDim2.new(0,Theme.SidebarW,1,-Theme.TitlebarH),Position=UDim2.fromOffset(0,Theme.TitlebarH),BackgroundColor3=Theme.BG,BorderSizePixel=0,ClipsDescendants=true},win)
	New("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.fromOffset(0,0),BackgroundColor3=Theme.Accent,BackgroundTransparency=0.4,BorderSizePixel=0,ZIndex=5},sidebar)
	New("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=Theme.Border,BackgroundTransparency=1-Theme.BorderAlpha,BorderSizePixel=0},sidebar)
	New("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(0,0),BackgroundColor3=Theme.BG,BorderSizePixel=0,ZIndex=2},sidebar)

	local sideList=New("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0},sidebar)
	New("UIListLayout",{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder},sideList)
	New("UIPadding",{PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10)},sideList)

	-- Content
	local content=New("Frame",{Name="Content",Size=UDim2.new(1,-Theme.SidebarW,1,-Theme.TitlebarH),Position=UDim2.new(0,Theme.SidebarW,0,Theme.TitlebarH),BackgroundColor3=Theme.BG3,BorderSizePixel=0,ClipsDescendants=true},win)

	-- Notif holder (on gui, not win)
	NotifHolder=New("Frame",{Name="Notifs",Size=UDim2.new(0,260,1,0),Position=UDim2.new(1,-276,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9999,ClipsDescendants=false},gui)
	New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right},NotifHolder)
	New("UIPadding",{PaddingBottom=UDim.new(0,20)},NotifHolder)

	-- Open / Close
	local visible=true; local maximized=false; local preMaxSz, preMaxPos

	local function OpenWin()
		win.Visible=true; SetAlpha(1)
		win.Size=UDim2.new(size.X.Scale,size.X.Offset*.95,size.Y.Scale,size.Y.Offset*.95)
		Tween(win,.22,{Size=size})
		if isCanvas then Tween(win,.22,{GroupTransparency=transparency}) else Tween(win,.22,{BackgroundTransparency=transparency}) end
		visible=true
	end

	local function CloseWin()
		local s=UDim2.new(size.X.Scale,size.X.Offset*.95,size.Y.Scale,size.Y.Offset*.95)
		Tween(win,.18,{Size=s})
		if isCanvas then Tween(win,.18,{GroupTransparency=1}) else Tween(win,.18,{BackgroundTransparency=1}) end
		task.delay(.2,function() win.Visible=false; win.Size=size end)
		visible=false
	end

	-- Dot actions
	dots[1].frame.InputBegan:Connect(function(i)
		if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
		Tween(win,.15,{Size=UDim2.new(size.X.Scale,size.X.Offset*.9,size.Y.Scale,size.Y.Offset*.9)})
		SetAlpha(1); task.delay(.18,function() gui:Destroy() end)
	end)
	dots[2].frame.InputBegan:Connect(function(i)
		if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
		if visible then CloseWin() else OpenWin() end
	end)
	dots[3].frame.InputBegan:Connect(function(i)
		if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
		if not maximized then
			preMaxSz=win.Size; preMaxPos=win.Position; maximized=true
			Tween(win,.2,{Size=UDim2.fromScale(1,1),Position=UDim2.fromScale(0.5,0.5)})
		else
			maximized=false; Tween(win,.2,{Size=preMaxSz,Position=preMaxPos})
		end
	end)

	UserInputService.InputBegan:Connect(function(inp,gpe)
		if gpe then return end
		if inp.KeyCode==keybind then if visible then CloseWin() else OpenWin() end end
	end)

	MakeDraggable(win, titlebar)
	MakeResizable(win, Vector2.new(380,260), Vector2.new(900,700))
	OpenWin()

	-- ── Win API ──────────────────────────────────────────────────────────────

	local Win={};  local tabBtns={};  local tabPages={};  local activeTab=nil;  local sideOrder=0

	local function SideSection(text)
		sideOrder=sideOrder+1
		local wrap=New("Frame",{Size=UDim2.new(1,0,0,34),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=sideOrder},sideList)
		New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.fromOffset(10,0),BackgroundColor3=Theme.Accent,BackgroundTransparency=0.75,BorderSizePixel=0},wrap)
		New("TextLabel",{Size=UDim2.new(1,-24,1,-4),Position=UDim2.fromOffset(12,6),BackgroundTransparency=1,Text=text:upper(),TextColor3=Theme.Accent,TextTransparency=0.2,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},wrap)
		return wrap
	end

	function Win:SetTab(name)
		for n,b in pairs(tabBtns) do
			local on=(n==name)
			Tween(b.frame,.15,{BackgroundColor3=on and Theme.Surface2 or Color3.fromRGB(0,0,0),BackgroundTransparency=on and 0 or 1})
			Tween(b.label,.15,{TextColor3=on and Theme.TextPrimary or Theme.TextSecondary})
			b.label.Font=on and Enum.Font.GothamBold or Enum.Font.Gotham
			if b.bar then Tween(b.bar,.15,{BackgroundTransparency=on and 0 or 1}) end
		end
		for n,pg in pairs(tabPages) do
			if n==name then
				pg.Visible=true
				pcall(function() pg.GroupTransparency=1 end)
				pcall(function() Tween(pg,.18,{GroupTransparency=0}) end)
			elseif pg.Visible then
				pcall(function() Tween(pg,.12,{GroupTransparency=1}) end)
				task.delay(.14,function() pg.Visible=false end)
			end
		end
		activeTab=name
	end

	function Win:AddSection(name) SideSection(name) end

	function Win:AddTab(cfg2)
		cfg2=cfg2 or {}
		local tabTitle=cfg2.Title or "Tab"
		sideOrder=sideOrder+1

		local btn=New("TextButton",{Name=tabTitle,Size=UDim2.new(1,-12,0,30),Position=UDim2.fromOffset(6,0),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=sideOrder},sideList)
		New("UICorner",{CornerRadius=UDim.new(0,5)},btn)
		local row=New("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0},btn)
		New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,7),VerticalAlignment=Enum.VerticalAlignment.Center},row)
		New("UIPadding",{PaddingLeft=UDim.new(0,10)},row)
		if cfg2.Icon then New("ImageLabel",{Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,Image=cfg2.Icon,ImageColor3=Theme.TextSecondary},row) end
		local lbl=New("TextLabel",{Size=UDim2.new(1,-10,1,0),BackgroundTransparency=1,Text=tabTitle,TextColor3=Theme.TextSecondary,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},row)
		local bar=New("Frame",{Size=UDim2.new(0,3,0.6,0),Position=UDim2.new(0,0,0.2,0),BackgroundColor3=Theme.Accent,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5},btn)
		New("UICorner",{CornerRadius=UDim.new(0,2)},bar)
		tabBtns[tabTitle]={frame=btn,label=lbl,bar=bar}

		-- Page (CanvasGroup or Frame)
		local page=nil
		if not pcall(function()
			page=Instance.new("CanvasGroup")
			page.Name=tabTitle.."_Page"; page.Size=UDim2.fromScale(1,1)
			page.BackgroundTransparency=1; page.BorderSizePixel=0
			page.Visible=false; page.GroupTransparency=1
			page.Parent=content
		end) or not page then
			page=New("Frame",{Name=tabTitle.."_Page",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Visible=false},content)
		end

		local scroll=New("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Theme.Surface2,CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},page)
		New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
		New("UIPadding",{PaddingTop=UDim.new(0,12),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),PaddingBottom=UDim.new(0,12)},scroll)
		tabPages[tabTitle]=page

		btn.MouseButton1Click:Connect(function() Win:SetTab(tabTitle) end)
		btn.MouseEnter:Connect(function()
			if activeTab~=tabTitle then Tween(btn,.12,{BackgroundColor3=Theme.Surface,BackgroundTransparency=0}) end
		end)
		btn.MouseLeave:Connect(function()
			if activeTab~=tabTitle then Tween(btn,.12,{BackgroundTransparency=1}) end
		end)
		if not activeTab then Win:SetTab(tabTitle) end

		-- Tab object
		local Tab={}; local tOrder=0
		local function NO() tOrder=tOrder+1; return tOrder end

		local function MG()
			local g=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Theme.BG4,BorderSizePixel=0,LayoutOrder=NO()},scroll)
			New("UICorner",{CornerRadius=UDim.new(0,Theme.Radius)},g); AddBorder(g,Theme.BorderAlpha)
			New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},g); return g
		end

		local function MR(parent, order)
			local r=New("Frame",{Size=UDim2.new(1,0,0,Theme.RowH),BackgroundColor3=Theme.BG4,BorderSizePixel=0,LayoutOrder=order or 0,ClipsDescendants=true},parent)
			New("Frame",{Size=UDim2.new(1,-12,0,1),Position=UDim2.new(0,12,1,-1),BackgroundColor3=Theme.Border,BackgroundTransparency=1-Theme.BorderAlpha,BorderSizePixel=0,ZIndex=2},r)
			AddHover(r,Theme.BG4,Theme.Surface)
			local lc=New("Frame",{Size=UDim2.new(0.55,-13,1,0),Position=UDim2.fromOffset(13,0),BackgroundTransparency=1,BorderSizePixel=0},r)
			New("UIListLayout",{VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,2)},lc)
			local rc=New("Frame",{Size=UDim2.new(0.45,-13,1,0),Position=UDim2.new(0.55,0,0,0),BackgroundTransparency=1,BorderSizePixel=0},r)
			New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,6)},rc)
			New("UIPadding",{PaddingRight=UDim.new(0,13)},rc)
			return r, lc, rc
		end

		local function LT(text, parent)
			return New("TextLabel",{Size=UDim2.new(1,0,0,17),BackgroundTransparency=1,Text=text,TextColor3=Theme.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left},parent)
		end
		local function DT(text, parent)
			return New("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=text,TextColor3=Theme.TextSecondary,TextSize=11.5,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},parent)
		end

		function Tab:AddSection(text)
			local w=New("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=NO()},scroll)
			New("Frame",{Size=UDim2.new(0,2,0,14),Position=UDim2.fromOffset(0,5),BackgroundColor3=Theme.Accent,BackgroundTransparency=0.3,BorderSizePixel=0},w)
			New("TextLabel",{Size=UDim2.new(1,-10,1,0),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,Text=text:upper(),TextColor3=Theme.Accent,TextTransparency=0.3,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},w)
		end

		function Tab:AddButton(cfg3)
			cfg3=cfg3 or {}
			local g=MG(); local r,lc,rc=MR(g,0)
			LT(cfg3.Title or "Button",lc)
			if cfg3.Description then DT(cfg3.Description,lc) end
			New("TextLabel",{Size=UDim2.fromOffset(12,12),BackgroundTransparency=1,Text="›",TextColor3=Theme.TextTertiary,TextSize=16,Font=Enum.Font.Gotham},rc)
			local b=New("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},r)
			b.MouseButton1Click:Connect(function()
				Tween(r,.08,{BackgroundColor3=Theme.Surface2,BackgroundTransparency=0})
				task.delay(.15,function() Tween(r,.12,{BackgroundTransparency=1}) end)
				if cfg3.Callback then cfg3.Callback() end
			end)
		end

		function Tab:AddToggle(cfg3)
			cfg3=cfg3 or {}
			local state=cfg3.Default or false
			local g=MG(); local r,lc,rc=MR(g,0)
			LT(cfg3.Title or "Toggle",lc)
			if cfg3.Description then DT(cfg3.Description,lc) end
			local track=New("Frame",{Size=UDim2.fromOffset(38,22),BackgroundColor3=state and Theme.Green or Theme.Surface2,BorderSizePixel=0},rc)
			New("UICorner",{CornerRadius=UDim.new(0,11)},track); AddBorder(track,Theme.BorderAlpha2)
			local thumb=New("Frame",{Size=UDim2.fromOffset(18,18),Position=state and UDim2.fromOffset(18,2) or UDim2.fromOffset(2,2),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0},track)
			New("UICorner",{CornerRadius=UDim.new(0.5,0)},thumb)
			local cb=New("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},r)
			local function SV(v)
				state=v
				SpringTween(thumb,.22,{Position=v and UDim2.fromOffset(18,2) or UDim2.fromOffset(2,2)})
				Tween(track,.18,{BackgroundColor3=v and Theme.Green or Theme.Surface2})
				if cfg3.Callback then cfg3.Callback(v) end
			end
			cb.MouseButton1Click:Connect(function() SV(not state) end)
			return {SetValue=SV, GetValue=function() return state end}
		end

		function Tab:AddSlider(cfg3)
			cfg3=cfg3 or {}
			local mn=cfg3.Min or 0; local mx=cfg3.Max or 100
			local cur=math.clamp(cfg3.Default or mn,mn,mx); local decs=cfg3.Decimals or 0
			local g=MG()
			local r=New("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=Theme.BG4,BorderSizePixel=0,LayoutOrder=0,ClipsDescendants=true},g)
			AddHover(r,Theme.BG4,Theme.Surface)
			New("Frame",{Size=UDim2.new(1,-12,0,1),Position=UDim2.new(0,12,1,-1),BackgroundColor3=Theme.Border,BackgroundTransparency=1-Theme.BorderAlpha,BorderSizePixel=0,ZIndex=2},r)
			local top=New("Frame",{Size=UDim2.new(1,-26,0,22),Position=UDim2.fromOffset(13,8),BackgroundTransparency=1,BorderSizePixel=0},r)
			LT(cfg3.Title or "Slider",top)
			local function fmt(v) if decs>0 then return string.format("%."..decs.."f",v) end; return tostring(math.round(v)) end
			local vl=New("TextLabel",{Size=UDim2.fromOffset(50,22),Position=UDim2.new(1,-50,0,0),BackgroundTransparency=1,Text=fmt(cur),TextColor3=Theme.Accent,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right},top)
			local tbg=New("Frame",{Size=UDim2.new(1,-26,0,3),Position=UDim2.fromOffset(13,38),BackgroundColor3=Theme.Surface2,BorderSizePixel=0},r)
			New("UICorner",{CornerRadius=UDim.new(0,2)},tbg)
			local fill=New("Frame",{Size=UDim2.fromScale((cur-mn)/(mx-mn),1),BackgroundColor3=Theme.Accent,BorderSizePixel=0},tbg)
			New("UICorner",{CornerRadius=UDim.new(0,2)},fill)
			local ts=New("Frame",{Size=UDim2.fromOffset(16,16),Position=UDim2.new((cur-mn)/(mx-mn),-8,0.5,-8),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=3},tbg)
			New("UICorner",{CornerRadius=UDim.new(0.5,0)},ts)
			local hit=New("TextButton",{Size=UDim2.new(1,0,0,22),Position=UDim2.fromOffset(0,-9),BackgroundTransparency=1,Text="",ZIndex=10},tbg)
			local drag=false
			local function Upd(mx2)
				local s=math.clamp((mx2-tbg.AbsolutePosition.X)/tbg.AbsoluteSize.X,0,1)
				local v=mn+s*(mx-mn); if decs==0 then v=math.round(v) end; cur=v
				local sc=(v-mn)/(mx-mn)
				Tween(fill,.05,{Size=UDim2.fromScale(sc,1)}); Tween(ts,.05,{Position=UDim2.new(sc,-8,0.5,-8)})
				vl.Text=fmt(v); if cfg3.Callback then cfg3.Callback(v) end
			end
			hit.MouseButton1Down:Connect(function() drag=true; Upd(Mouse.X) end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
			RunService.RenderStepped:Connect(function() if drag then Upd(Mouse.X) end end)
			return {SetValue=function(v) cur=math.clamp(v,mn,mx); Upd(tbg.AbsolutePosition.X+(cur-mn)/(mx-mn)*tbg.AbsoluteSize.X) end, GetValue=function() return cur end}
		end

		function Tab:AddInput(cfg3)
			cfg3=cfg3 or {}
			local g=MG(); local r,lc,rc=MR(g,0)
			LT(cfg3.Title or "Input",lc)
			if cfg3.Description then DT(cfg3.Description,lc) end
			local box=New("TextBox",{Size=UDim2.fromOffset(120,24),BackgroundColor3=Theme.Surface,BorderSizePixel=0,Text=cfg3.Default or "",PlaceholderText=cfg3.Placeholder or "Type here...",TextColor3=Theme.TextPrimary,PlaceholderColor3=Theme.TextTertiary,TextSize=12,Font=Enum.Font.Gotham,ClearTextOnFocus=false},rc)
			New("UICorner",{CornerRadius=UDim.new(0,5)},box)
			local st=AddBorder(box,Theme.BorderAlpha2)
			New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},box)
			box.Focused:Connect(function() if st then Tween(st,.15,{Color=Theme.Accent,Transparency=0.3}) end end)
			box.FocusLost:Connect(function()
				if st then Tween(st,.15,{Color=Theme.Border,Transparency=1-Theme.BorderAlpha2}) end
				if cfg3.Callback then cfg3.Callback(box.Text) end
			end)
			return {GetValue=function() return box.Text end, SetValue=function(v) box.Text=v end}
		end

		function Tab:AddDropdown(cfg3)
			cfg3=cfg3 or {}
			local opts=cfg3.Options or {}; local sel=cfg3.Default or (opts[1] or "")
			local g=MG(); local r,lc,rc=MR(g,0)
			LT(cfg3.Title or "Dropdown",lc)
			if cfg3.Description then DT(cfg3.Description,lc) end
			local sl=New("TextLabel",{Size=UDim2.fromOffset(90,20),BackgroundTransparency=1,Text=sel,TextColor3=Theme.TextSecondary,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right},rc)
			New("TextLabel",{Size=UDim2.fromOffset(10,20),BackgroundTransparency=1,Text="›",TextColor3=Theme.TextTertiary,TextSize=14,Font=Enum.Font.Gotham},rc)
			local function OD()
				local menu=New("Frame",{Size=UDim2.new(0,160,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(1,-170,1,4),BackgroundColor3=Theme.BG3,BorderSizePixel=0,ZIndex=50},r)
				New("UICorner",{CornerRadius=UDim.new(0,Theme.Radius)},menu); AddBorder(menu,Theme.BorderAlpha2); New("UIListLayout",{},menu)
				for _,opt in ipairs(opts) do
					local ob=New("TextButton",{Size=UDim2.new(1,0,0,32),BackgroundColor3=Theme.BG3,BorderSizePixel=0,Text=opt,TextColor3=opt==sel and Theme.Accent or Theme.TextPrimary,TextSize=12.5,Font=Enum.Font.Gotham,AutoButtonColor=false,ZIndex=51},menu)
					New("UIPadding",{PaddingLeft=UDim.new(0,12)},ob); AddHover(ob,Theme.BG3,Theme.Surface)
					ob.MouseButton1Click:Connect(function() sel=opt; sl.Text=opt; if cfg3.Callback then cfg3.Callback(opt) end; menu:Destroy() end)
				end
				local conn; conn=UserInputService.InputBegan:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseButton1 then
						task.delay(.05,function() if menu and menu.Parent then menu:Destroy() end end); conn:Disconnect()
					end
				end)
			end
			local cb=New("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},r)
			cb.MouseButton1Click:Connect(OD)
			return {GetValue=function() return sel end, SetValue=function(v) sel=v; sl.Text=v end}
		end

		function Tab:AddKeybind(cfg3)
			cfg3=cfg3 or {}
			local ck=cfg3.Default; local ls=false
			local g=MG(); local r,lc,rc=MR(g,0)
			LT(cfg3.Title or "Keybind",lc)
			if cfg3.Description then DT(cfg3.Description,lc) end
			local function KN(k)
				if not k then return "None" end
				local s=tostring(k.KeyCode or k.UserInputType)
				return s:gsub("Enum%.KeyCode%.",""):gsub("Enum%.UserInputType%.",""):gsub("MouseButton","MB")
			end
			local badge=New("TextButton",{Size=UDim2.fromOffset(60,22),BackgroundColor3=Theme.Surface2,BorderSizePixel=0,Text=ck and KN(ck) or "None",TextColor3=Theme.TextPrimary,TextSize=11,Font=Enum.Font.GothamMedium,AutoButtonColor=false},rc)
			New("UICorner",{CornerRadius=UDim.new(0,4)},badge); AddBorder(badge,Theme.BorderAlpha2)
			badge.MouseButton1Click:Connect(function()
				if ls then return end; ls=true; badge.Text="..."; Tween(badge,.15,{BackgroundColor3=Theme.Accent})
				local conn; conn=UserInputService.InputBegan:Connect(function(inp,gpe)
					if gpe then return end; ls=false; ck=inp; badge.Text=KN(inp)
					Tween(badge,.15,{BackgroundColor3=Theme.Surface2}); if cfg3.Callback then cfg3.Callback(inp) end; conn:Disconnect()
				end)
			end)
			return {GetValue=function() return ck end}
		end

		function Tab:AddParagraph(cfg3)
			cfg3=cfg3 or {}
			local g=MG()
			local con=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=0},g)
			New("UIListLayout",{Padding=UDim.new(0,4)},con)
			New("UIPadding",{PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),PaddingLeft=UDim.new(0,13),PaddingRight=UDim.new(0,13)},con)
			if cfg3.Title then New("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=cfg3.Title,TextColor3=Theme.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},con) end
			if cfg3.Description then New("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=cfg3.Description,TextColor3=Theme.TextSecondary,TextSize=12,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},con) end
		end

		return Tab
	end

	function Win:Notify(cfg2)
		cfg2=cfg2 or {}
		FireNotif(cfg2.Title or "Notice", cfg2.Description or "", cfg2.Type or "info", cfg2.Duration or 2.5)
	end

	function Win:SetAccent(color)
		Theme.Accent=color; Theme.AccentDark=Shade(color,-18)
	end

	function Win:SetTheme(name)
		local p=ThemePresets[name]; if not p then return end
		for k,v in pairs(p) do Theme[k]=v end
		win.BackgroundColor3=Theme.BG2; titlebar.BackgroundColor3=Theme.BG
		sidebar.BackgroundColor3=Theme.BG; content.BackgroundColor3=Theme.BG3
		FireNotif("Theme",name,"info",2)
	end

	function Win:SetKeybind(key) keybind=key end

	return Win
end

return Library
