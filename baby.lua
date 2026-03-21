--[[
	UI Library v4.0 — macOS + Card Style
	
	Window config:
		Title, Size, Theme, Keybind, Transparency, Accent

	Themes: "Dark Red" | "Dark Blue" | "Dark Green" | "Light Red" | "Light Green" | "Light Blue"

	Dot buttons:
		🔴 Red    = Destroy UI
		🟡 Yellow = Minimize / Restore toggle
		🟢 Green  = Maximize / Restore toggle

	Components (all card-based):
		Tab:AddSection(title)
		Tab:AddToggle({ Title, Description, Icon, Default, Callback })
		Tab:AddButton({ Title, Description, Icon, Callback })
		Tab:AddSlider({ Title, Min, Max, Default, Decimals, Callback })
		Tab:AddInput({ Title, Placeholder, Default, Callback })
		Tab:AddDropdown({ Title, Options, Default, Callback })          -- single select
		Tab:AddMultiSelect({ Title, Options, Default, Callback })       -- multi-select (new)
		Tab:AddListbox({ Title, Options, Default, Callback })           -- scrollable pick list (new)
		Tab:AddKeybind({ Title, Description, Callback })
		Tab:AddParagraph({ Title, Description })

	Window methods:
		Window:Notify({ Title, Description, Type, Duration })
		Window:SetTheme(name)
		Window:SetAccent(Color3)
		Window:SetKeybind(key)
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

-- ── Theme presets ─────────────────────────────────────────────────────────────

local Presets = {
	["Dark Red"] = {
		BG=Color3.fromRGB(13,10,10), BG2=Color3.fromRGB(20,14,14), BG3=Color3.fromRGB(25,17,17), BG4=Color3.fromRGB(30,20,20),
		Surface=Color3.fromRGB(40,24,24), Surface2=Color3.fromRGB(52,28,28),
		TextPrimary=Color3.fromRGB(245,235,235), TextSecondary=Color3.fromRGB(175,140,140), TextTertiary=Color3.fromRGB(100,70,70),
		Accent=Color3.fromRGB(220,55,55), Green=Color3.fromRGB(52,201,122), Red=Color3.fromRGB(255,69,58), Amber=Color3.fromRGB(255,159,10), Blue=Color3.fromRGB(10,132,255),
	},
	["Dark Blue"] = {
		BG=Color3.fromRGB(10,12,18), BG2=Color3.fromRGB(14,18,28), BG3=Color3.fromRGB(17,22,34), BG4=Color3.fromRGB(20,26,40),
		Surface=Color3.fromRGB(26,34,56), Surface2=Color3.fromRGB(32,44,70),
		TextPrimary=Color3.fromRGB(228,236,255), TextSecondary=Color3.fromRGB(130,158,210), TextTertiary=Color3.fromRGB(65,88,130),
		Accent=Color3.fromRGB(48,130,255), Green=Color3.fromRGB(52,201,122), Red=Color3.fromRGB(255,69,58), Amber=Color3.fromRGB(255,159,10), Blue=Color3.fromRGB(48,130,255),
	},
	["Dark Green"] = {
		BG=Color3.fromRGB(8,14,10), BG2=Color3.fromRGB(12,20,14), BG3=Color3.fromRGB(15,25,17), BG4=Color3.fromRGB(18,30,20),
		Surface=Color3.fromRGB(24,42,26), Surface2=Color3.fromRGB(30,54,33),
		TextPrimary=Color3.fromRGB(222,244,226), TextSecondary=Color3.fromRGB(120,180,135), TextTertiary=Color3.fromRGB(60,100,70),
		Accent=Color3.fromRGB(40,200,90), Green=Color3.fromRGB(40,200,90), Red=Color3.fromRGB(255,69,58), Amber=Color3.fromRGB(255,159,10), Blue=Color3.fromRGB(10,132,255),
	},
	["Light Red"] = {
		BG=Color3.fromRGB(235,228,228), BG2=Color3.fromRGB(248,244,244), BG3=Color3.fromRGB(255,252,252), BG4=Color3.fromRGB(242,236,236),
		Surface=Color3.fromRGB(232,222,222), Surface2=Color3.fromRGB(220,210,210),
		TextPrimary=Color3.fromRGB(35,18,18), TextSecondary=Color3.fromRGB(110,70,70), TextTertiary=Color3.fromRGB(170,130,130),
		Accent=Color3.fromRGB(200,30,30), Green=Color3.fromRGB(30,160,80), Red=Color3.fromRGB(200,40,30), Amber=Color3.fromRGB(190,110,0), Blue=Color3.fromRGB(0,100,210),
	},
	["Light Green"] = {
		BG=Color3.fromRGB(228,238,230), BG2=Color3.fromRGB(244,250,246), BG3=Color3.fromRGB(252,255,253), BG4=Color3.fromRGB(236,246,238),
		Surface=Color3.fromRGB(218,234,222), Surface2=Color3.fromRGB(204,226,208),
		TextPrimary=Color3.fromRGB(15,35,20), TextSecondary=Color3.fromRGB(55,105,65), TextTertiary=Color3.fromRGB(120,165,130),
		Accent=Color3.fromRGB(22,155,68), Green=Color3.fromRGB(22,155,68), Red=Color3.fromRGB(200,40,30), Amber=Color3.fromRGB(190,110,0), Blue=Color3.fromRGB(0,100,210),
	},
	["Light Blue"] = {
		BG=Color3.fromRGB(225,234,248), BG2=Color3.fromRGB(242,247,255), BG3=Color3.fromRGB(252,254,255), BG4=Color3.fromRGB(232,242,255),
		Surface=Color3.fromRGB(216,230,252), Surface2=Color3.fromRGB(198,218,248),
		TextPrimary=Color3.fromRGB(12,24,50), TextSecondary=Color3.fromRGB(50,90,155), TextTertiary=Color3.fromRGB(115,148,200),
		Accent=Color3.fromRGB(14,100,230), Green=Color3.fromRGB(22,155,68), Red=Color3.fromRGB(200,40,30), Amber=Color3.fromRGB(190,110,0), Blue=Color3.fromRGB(14,100,230),
	},
}

local T = {
	BG=Color3.fromRGB(17,17,19), BG2=Color3.fromRGB(22,22,26), BG3=Color3.fromRGB(27,27,32), BG4=Color3.fromRGB(32,32,38),
	Surface=Color3.fromRGB(38,38,45), Surface2=Color3.fromRGB(46,46,54),
	TextPrimary=Color3.fromRGB(240,240,242), TextSecondary=Color3.fromRGB(148,148,158), TextTertiary=Color3.fromRGB(86,86,96),
	Accent=Color3.fromRGB(48,130,255), Green=Color3.fromRGB(52,201,122), Red=Color3.fromRGB(255,69,58), Amber=Color3.fromRGB(255,159,10), Blue=Color3.fromRGB(48,130,255),
	Radius=13, RowH=62, SideW=192, TitleH=42,
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function Tw(obj, t, props, style, dir)
	TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end
local function Spring(obj, t, props) Tw(obj, t, props, Enum.EasingStyle.Back, Enum.EasingDirection.Out) end

local function New(cls, props, parent)
	local ok, obj = pcall(Instance.new, cls)
	if not ok or not obj then return nil end
	for k,v in pairs(props) do pcall(function() obj[k]=v end) end
	if parent then obj.Parent=parent end
	return obj
end

local function Shade(c, a)
	return Color3.fromRGB(math.clamp(c.R*255+a,0,255), math.clamp(c.G*255+a,0,255), math.clamp(c.B*255+a,0,255))
end

local function Stroke(p, alpha, thick)
	return New("UIStroke", {Color=Color3.fromRGB(255,255,255), Transparency=1-(alpha or 0.08), Thickness=thick or 1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}, p)
end

local function Hover(obj, n, h)
	obj.MouseEnter:Connect(function() Tw(obj,.1,{BackgroundColor3=h}) end)
	obj.MouseLeave:Connect(function() Tw(obj,.1,{BackgroundColor3=n}) end)
end

-- ── Icon helpers (returns a Frame with SVG-ish lines) ─────────────────────────
-- Uses ImageLabel with Roblox's built-in icons via rbxassetid, or simple shapes
local function MakeIconFrame(parent, size, bgColor)
	local f = New("Frame", {
		Size=UDim2.fromOffset(size or 38, size or 38),
		BackgroundColor3=bgColor or T.Surface,
		BorderSizePixel=0,
	}, parent)
	New("UICorner", {CornerRadius=UDim.new(0, math.floor((size or 38)*0.26))}, f)
	return f
end

-- ── Drag ─────────────────────────────────────────────────────────────────────

local function Drag(frame, handle)
	handle = handle or frame
	local drag, ds, sp
	handle.InputBegan:Connect(function(i)
		if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
		drag=true; ds=i.Position; sp=frame.Position
		i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not drag or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
		local d=i.Position-ds
		frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
	end)
end

-- ── Resize ────────────────────────────────────────────────────────────────────

local function Resize(frame, mn, mx)
	mn=mn or Vector2.new(400,300); mx=mx or Vector2.new(950,750)
	local dirs={TopLeft={x=-1,y=-1},TopRight={x=1,y=-1},BottomLeft={x=-1,y=1},BottomRight={x=1,y=1}}
	local resizing,corner,ms,ss,ps
	local rf=New("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=100},frame)
	for name,dir in pairs(dirs) do
		local h=New("Frame",{Name=name,Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ZIndex=101},rf)
		if name=="TopLeft"     then h.Position=UDim2.fromOffset(-5,-5) end
		if name=="TopRight"    then h.Position=UDim2.new(1,-11,0,-5) end
		if name=="BottomLeft"  then h.Position=UDim2.new(0,-5,1,-11) end
		if name=="BottomRight" then h.Position=UDim2.new(1,-11,1,-11) end
		h.InputBegan:Connect(function(i)
			if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
			resizing=true; corner=dir; ms=Vector2.new(Mouse.X,Mouse.Y); ss=frame.AbsoluteSize; ps=frame.Position
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

local NotifHolder=nil
local nCount=0

local function Notif(title, desc, ntype, dur)
	if not NotifHolder then return end
	dur=dur or 2.5; ntype=ntype or "info"; nCount+=1
	local ac={success=T.Green,info=T.Accent,warning=T.Amber,error=T.Red}
	local ic={success="✓",info="i",warning="!",error="×"}
	local col=ac[ntype] or T.Accent

	local card=New("Frame",{
		Name="N"..nCount, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
		BackgroundColor3=T.BG3, BorderSizePixel=0, ClipsDescendants=true,
		LayoutOrder=nCount, Position=UDim2.new(1,20,0,0),
	},NotifHolder)
	New("UICorner",{CornerRadius=UDim.new(0,T.Radius)},card)
	Stroke(card,0.14)
	New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10),VerticalAlignment=Enum.VerticalAlignment.Top},card)
	New("UIPadding",{PaddingTop=UDim.new(0,11),PaddingBottom=UDim.new(0,11),PaddingLeft=UDim.new(0,11),PaddingRight=UDim.new(0,11)},card)

	local ib=New("Frame",{Size=UDim2.fromOffset(28,28),BackgroundColor3=col,BackgroundTransparency=0.78,BorderSizePixel=0},card)
	New("UICorner",{CornerRadius=UDim.new(0,7)},ib)
	New("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=ic[ntype] or "i",TextColor3=col,TextSize=12,Font=Enum.Font.GothamBold},ib)

	local col2=New("Frame",{Size=UDim2.new(1,-50,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0},card)
	New("UIListLayout",{Padding=UDim.new(0,3)},col2)
	New("TextLabel",{Size=UDim2.new(1,0,0,17),BackgroundTransparency=1,Text=title,TextColor3=T.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},col2)
	New("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=desc,TextColor3=col,TextTransparency=0.3,TextSize=11.5,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left},col2)
	local tr=New("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=T.Surface2,BorderSizePixel=0},col2)
	New("UICorner",{CornerRadius=UDim.new(0,1)},tr)
	local bar=New("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=col,BorderSizePixel=0},tr)
	New("UICorner",{CornerRadius=UDim.new(0,1)},bar)

	card.BackgroundTransparency=1
	task.spawn(function()
		Tw(card,.28,{BackgroundTransparency=0,Position=UDim2.fromScale(0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		Tw(bar,dur,{Size=UDim2.fromScale(0,1)},Enum.EasingStyle.Linear)
		task.wait(dur)
		Tw(card,.2,{BackgroundTransparency=1,Position=UDim2.new(1,20,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
		task.wait(.22); card:Destroy()
	end)
end

-- ── Library ───────────────────────────────────────────────────────────────────

local Library={}

function Library:CreateWindow(cfg)
	cfg=cfg or {}
	local title=cfg.Title or "UI Library"
	local size=cfg.Size or UDim2.fromOffset(660,480)
	local keybind=cfg.Keybind or Enum.KeyCode.LeftControl
	local transparency=cfg.Transparency or 0

	if cfg.Theme and Presets[cfg.Theme] then
		for k,v in pairs(Presets[cfg.Theme]) do T[k]=v end
	end
	if cfg.Accent then T.Accent=cfg.Accent end

	-- ScreenGui
	local gui=Instance.new("ScreenGui")
	gui.Name="UILib_"..title; gui.ResetOnSpawn=false
	gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset=true
	if not pcall(function() gui.Parent=game:GetService("CoreGui") end) or not gui.Parent then
		gui.Parent=LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Window
	local isCanvas=true; local win
	if not pcall(function() win=Instance.new("CanvasGroup") end) or not win then
		win=Instance.new("Frame"); isCanvas=false
	end
	win.Name="Window"; win.Size=size
	win.Position=UDim2.fromScale(0.5,0.5); win.AnchorPoint=Vector2.new(0.5,0.5)
	win.BackgroundColor3=T.BG2; win.BorderSizePixel=0
	if isCanvas then win.GroupTransparency=transparency else win.BackgroundTransparency=transparency end
	win.Parent=gui
	New("UICorner",{CornerRadius=UDim.new(0,14)},win)
	Stroke(win,0.12,1)

	local function SetAlpha(a)
		if isCanvas then win.GroupTransparency=a else win.BackgroundTransparency=a end
	end

	-- ── Titlebar ─────────────────────────────────────────────────────────────
	local tb=New("Frame",{Size=UDim2.new(1,0,0,T.TitleH),BackgroundColor3=T.BG,BorderSizePixel=0,ZIndex=2},win)
	New("UICorner",{CornerRadius=UDim.new(0,14)},tb)
	-- square bottom half of titlebar corners
	New("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=T.BG,BorderSizePixel=0},tb)
	-- separator line
	New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.9,BorderSizePixel=0},tb)

	-- 3 dots (left side only — no right-side controls)
	local dh=New("Frame",{Size=UDim2.fromOffset(70,T.TitleH),BackgroundTransparency=1,ZIndex=3},tb)
	New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,7),VerticalAlignment=Enum.VerticalAlignment.Center},dh)
	New("UIPadding",{PaddingLeft=UDim.new(0,14)},dh)

	local dotDefs={
		{Color3.fromRGB(255,95,87),Color3.fromRGB(195,45,38),"×"},   -- red = destroy
		{Color3.fromRGB(254,188,46),Color3.fromRGB(195,138,10),"−"}, -- yellow = minimize
		{Color3.fromRGB(40,200,64),Color3.fromRGB(18,155,38),"+"},   -- green = maximize
	}
	local dots={}
	for i,c in ipairs(dotDefs) do
		local dot=New("Frame",{Size=UDim2.fromOffset(13,13),BackgroundColor3=c[1],BorderSizePixel=0,ZIndex=4},dh)
		New("UICorner",{CornerRadius=UDim.new(0.5,0)},dot)
		local sym=New("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=c[3],TextColor3=Color3.fromRGB(60,15,5),TextSize=9,Font=Enum.Font.GothamBold,Visible=false,ZIndex=5},dot)
		dots[i]={frame=dot,sym=sym,n=c[1],h=c[2]}
		dot.MouseEnter:Connect(function() Tw(dot,.1,{BackgroundColor3=c[2]}); sym.Visible=true end)
		dot.MouseLeave:Connect(function() Tw(dot,.1,{BackgroundColor3=c[1]}); sym.Visible=false end)
	end

	-- Title text (centered)
	New("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=title,TextColor3=T.TextSecondary,TextSize=13,Font=Enum.Font.GothamBold,ZIndex=3},tb)

	-- ── Sidebar ───────────────────────────────────────────────────────────────
	local sb=New("Frame",{Name="Sidebar",Size=UDim2.new(0,T.SideW,1,-T.TitleH),Position=UDim2.fromOffset(0,T.TitleH),BackgroundColor3=T.BG,BorderSizePixel=0,ClipsDescendants=true},win)
	-- accent top strip
	New("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=T.Accent,BackgroundTransparency=0.45,BorderSizePixel=0,ZIndex=5},sb)
	-- right divider
	New("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.9,BorderSizePixel=0},sb)
	-- patch top-left corner
	New("Frame",{Size=UDim2.fromOffset(14,14),BackgroundColor3=T.BG,BorderSizePixel=0,ZIndex=2},sb)

	local sbList=New("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0},sb)
	New("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},sbList)
	New("UIPadding",{PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12)},sbList)

	-- ── Content ───────────────────────────────────────────────────────────────
	local content=New("Frame",{Name="Content",Size=UDim2.new(1,-T.SideW,1,-T.TitleH),Position=UDim2.new(0,T.SideW,0,T.TitleH),BackgroundColor3=T.BG3,BorderSizePixel=0,ClipsDescendants=true},win)

	-- ── Notification holder ───────────────────────────────────────────────────
	NotifHolder=New("Frame",{Name="Notifs",Size=UDim2.new(0,270,1,0),Position=UDim2.new(1,-286,0,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=9999,ClipsDescendants=false},gui)
	New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right},NotifHolder)
	New("UIPadding",{PaddingBottom=UDim.new(0,20)},NotifHolder)

	-- ── Open / Close ─────────────────────────────────────────────────────────
	local visible=true; local maximized=false; local preMaxSz,preMaxPos

	local function Open()
		win.Visible=true; SetAlpha(1)
		win.Size=UDim2.new(size.X.Scale,size.X.Offset*.94,size.Y.Scale,size.Y.Offset*.94)
		Tw(win,.22,{Size=size})
		if isCanvas then Tw(win,.22,{GroupTransparency=transparency}) else Tw(win,.22,{BackgroundTransparency=transparency}) end
		visible=true
	end
	local function Close()
		local s=UDim2.new(size.X.Scale,size.X.Offset*.94,size.Y.Scale,size.Y.Offset*.94)
		Tw(win,.18,{Size=s})
		if isCanvas then Tw(win,.18,{GroupTransparency=1}) else Tw(win,.18,{BackgroundTransparency=1}) end
		task.delay(.2,function() win.Visible=false; win.Size=size end)
		visible=false
	end

	-- Dots
	dots[1].frame.InputBegan:Connect(function(i)
		if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
		Tw(win,.14,{Size=UDim2.new(size.X.Scale,size.X.Offset*.88,size.Y.Scale,size.Y.Offset*.88)}); SetAlpha(1)
		task.delay(.16,function() gui:Destroy() end)
	end)
	dots[2].frame.InputBegan:Connect(function(i)
		if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
		if visible then Close() else Open() end
	end)
	dots[3].frame.InputBegan:Connect(function(i)
		if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
		if not maximized then
			preMaxSz=win.Size; preMaxPos=win.Position; maximized=true
			Tw(win,.2,{Size=UDim2.fromScale(1,1),Position=UDim2.fromScale(0.5,0.5)})
		else
			maximized=false; Tw(win,.2,{Size=preMaxSz,Position=preMaxPos})
		end
	end)

	UserInputService.InputBegan:Connect(function(inp,gpe)
		if gpe then return end
		if inp.KeyCode==keybind then if visible then Close() else Open() end end
	end)

	Drag(win,tb); Resize(win)
	Open()

	-- ── Win API ───────────────────────────────────────────────────────────────
	local Win={}; local tabBtns={}; local tabPages={}; local activeTab=nil; local sOrder=0

	local function SideSection(text)
		sOrder+=1
		local w=New("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=sOrder},sbList)
		New("Frame",{Size=UDim2.new(1,-24,0,1),Position=UDim2.fromOffset(12,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.72,BorderSizePixel=0},w)
		New("TextLabel",{Size=UDim2.new(1,-28,1,-4),Position=UDim2.fromOffset(14,6),BackgroundTransparency=1,Text=text:upper(),TextColor3=T.Accent,TextTransparency=0.22,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},w)
	end

	function Win:SetTab(name)
		for n,b in pairs(tabBtns) do
			local on=(n==name)
			-- active = accent bg pill, inactive = transparent
			Tw(b.frame,.15,{BackgroundColor3=on and T.Accent or Color3.fromRGB(0,0,0),BackgroundTransparency=on and 0 or 1})
			Tw(b.label,.15,{TextColor3=on and Color3.fromRGB(255,255,255) or T.TextSecondary})
			b.label.Font=on and Enum.Font.GothamBold or Enum.Font.Gotham
			if b.icoFrame then b.icoFrame.BackgroundColor3=on and Color3.fromRGB(255,255,255) or T.Surface; b.icoFrame.BackgroundTransparency=on and 0.82 or 0 end
			if b.bar then Tw(b.bar,.15,{BackgroundTransparency=on and 0 or 1}) end
		end
		for n,pg in pairs(tabPages) do
			if n==name then pg.Visible=true; pcall(function() pg.GroupTransparency=1; Tw(pg,.18,{GroupTransparency=0}) end)
			elseif pg.Visible then pcall(function() Tw(pg,.12,{GroupTransparency=1}) end); task.delay(.14,function() pg.Visible=false end) end
		end
		activeTab=name
	end

	function Win:AddSection(name) SideSection(name) end

	function Win:AddTab(cfg2)
		cfg2=cfg2 or {}; local tabTitle=cfg2.Title or "Tab"
		sOrder+=1

		local btn=New("TextButton",{Name=tabTitle,Size=UDim2.new(1,-16,0,38),Position=UDim2.fromOffset(8,0),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=sOrder},sbList)
		New("UICorner",{CornerRadius=UDim.new(0,9)},btn)

		local row=New("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0},btn)
		New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,9),VerticalAlignment=Enum.VerticalAlignment.Center},row)
		New("UIPadding",{PaddingLeft=UDim.new(0,11),PaddingRight=UDim.new(0,10)},row)

		-- icon square
		local icoF=New("Frame",{Size=UDim2.fromOffset(24,24),BackgroundColor3=T.Surface,BorderSizePixel=0},row)
		New("UICorner",{CornerRadius=UDim.new(0,7)},icoF)
		if cfg2.Icon then
			New("ImageLabel",{Size=UDim2.fromOffset(15,15),Position=UDim2.fromOffset(4,4),BackgroundTransparency=1,Image=cfg2.Icon,ImageColor3=T.TextSecondary},icoF)
		end

		local lbl=New("TextLabel",{Size=UDim2.new(1,-36,1,0),BackgroundTransparency=1,Text=tabTitle,TextColor3=T.TextSecondary,TextSize=13.5,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},row)

		-- left active bar
		local bar=New("Frame",{Size=UDim2.new(0,3,0.55,0),Position=UDim2.new(0,0,0.225,0),BackgroundColor3=T.Accent,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5},btn)
		New("UICorner",{CornerRadius=UDim.new(0,2)},bar)

		tabBtns[tabTitle]={frame=btn,label=lbl,bar=bar,icoFrame=icoF}

		-- Page
		local page=nil
		pcall(function()
			page=Instance.new("CanvasGroup"); page.Name=tabTitle.."_Page"
			page.Size=UDim2.fromScale(1,1); page.BackgroundTransparency=1; page.BorderSizePixel=0
			page.Visible=false; page.GroupTransparency=1; page.Parent=content
		end)
		if not page then page=New("Frame",{Name=tabTitle.."_Page",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Visible=false},content) end

		local scroll=New("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.Surface2,CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},page)
		New("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
		New("UIPadding",{PaddingTop=UDim.new(0,16),PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16),PaddingBottom=UDim.new(0,16)},scroll)
		tabPages[tabTitle]=page

		btn.MouseButton1Click:Connect(function() Win:SetTab(tabTitle) end)
		btn.MouseEnter:Connect(function()
			if activeTab~=tabTitle then Tw(btn,.1,{BackgroundColor3=T.Surface,BackgroundTransparency=0}) end
		end)
		btn.MouseLeave:Connect(function()
			if activeTab~=tabTitle then Tw(btn,.1,{BackgroundTransparency=1}) end
		end)
		if not activeTab then Win:SetTab(tabTitle) end

		-- ── Tab object ───────────────────────────────────────────────────────
		local Tab={}; local tO=0
		local function NO() tO+=1; return tO end

		-- Section divider
		function Tab:AddSection(text)
			local w=New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=NO()},scroll)
			New("Frame",{Size=UDim2.new(0,3,0,16),Position=UDim2.fromOffset(0,5),BackgroundColor3=T.Accent,BackgroundTransparency=0.28,BorderSizePixel=0},w)
			New("TextLabel",{Size=UDim2.new(1,-12,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text=text:upper(),TextColor3=T.Accent,TextTransparency=0.22,TextSize=10.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},w)
		end

		-- ── Card helpers ─────────────────────────────────────────────────────
		-- Every component lives in a card (rounded rect)
		local function MakeCard(h)
			local c=New("Frame",{
				Size=UDim2.new(1,0,0,h or 66), BackgroundColor3=T.BG4,
				BorderSizePixel=0, LayoutOrder=NO(), ClipsDescendants=false,
			},scroll)
			New("UICorner",{CornerRadius=UDim.new(0,T.Radius)},c)
			Stroke(c,0.07)
			return c
		end

		local function CardIcon(parent, iconColor, iconBgColor)
			local f=New("Frame",{Size=UDim2.fromOffset(44,44),Position=UDim2.fromOffset(13,11),BackgroundColor3=iconBgColor or T.Surface,BorderSizePixel=0},parent)
			New("UICorner",{CornerRadius=UDim.new(0,12)},f)
			return f
		end

		local function CardText(parent, titleText, subText, subColor)
			local lbl=New("TextLabel",{BackgroundTransparency=1,Text=titleText,TextColor3=T.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Bottom,Position=UDim2.new(0,68,0,14),Size=UDim2.new(1,-144,0,19)},parent)
			local sub=nil
			if subText then
				sub=New("TextLabel",{BackgroundTransparency=1,Text=subText,TextColor3=subColor or T.TextTertiary,TextSize=11.5,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Position=UDim2.new(0,68,0,35),Size=UDim2.new(1,-144,0,17)},parent)
			end
			return lbl, sub
		end

		-- ── Toggle ────────────────────────────────────────────────────────────
		function Tab:AddToggle(cfg3)
			cfg3=cfg3 or {}
			local state=cfg3.Default or false
			local card=MakeCard(66)
			Hover(card,T.BG4,T.Surface)

			local icoColor=cfg3.IconColor or T.Accent
			local icoBg=Color3.fromRGB(
				math.clamp(icoColor.R*255*0.18+T.BG4.R*255*0.82,0,255),
				math.clamp(icoColor.G*255*0.18+T.BG4.G*255*0.82,0,255),
				math.clamp(icoColor.B*255*0.18+T.BG4.B*255*0.82,0,255))
			local icoFrame=CardIcon(card,icoColor,icoBg)

			local icoDot=New("Frame",{Size=UDim2.fromOffset(16,16),Position=UDim2.fromOffset(14,14),BackgroundColor3=icoColor,BorderSizePixel=0},icoFrame)
			New("UICorner",{CornerRadius=UDim.new(0.5,0)},icoDot)

			local titleLbl,subLbl=CardText(card,cfg3.Title or "Toggle",state and "● Active" or "● Disabled",state and T.Green or T.TextTertiary)

			-- toggle switch (right side)
			local track=New("Frame",{Size=UDim2.fromOffset(40,24),Position=UDim2.new(1,-54,0.5,-12),BackgroundColor3=state and T.Green or T.Surface2,BorderSizePixel=0},card)
			New("UICorner",{CornerRadius=UDim.new(0,12)},track)
			Stroke(track,0.12)
			local thumb=New("Frame",{Size=UDim2.fromOffset(20,20),Position=state and UDim2.fromOffset(18,2) or UDim2.fromOffset(2,2),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0},track)
			New("UICorner",{CornerRadius=UDim.new(0.5,0)},thumb)

			local cb=New("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},card)

			local function SV(v)
				state=v
				Spring(thumb,.22,{Position=v and UDim2.fromOffset(18,2) or UDim2.fromOffset(2,2)})
				Tw(track,.18,{BackgroundColor3=v and T.Green or T.Surface2})
				if subLbl then subLbl.Text=v and "● Active" or "● Disabled"; subLbl.TextColor3=v and T.Green or T.TextTertiary end
				-- tint icon
				Tw(icoDot,.18,{BackgroundColor3=v and icoColor or T.TextTertiary})
				if cfg3.Callback then cfg3.Callback(v) end
			end

			cb.MouseButton1Click:Connect(function() SV(not state) end)
			return {SetValue=SV, GetValue=function() return state end}
		end

		-- ── Button ────────────────────────────────────────────────────────────
		function Tab:AddButton(cfg3)
			cfg3=cfg3 or {}
			local card=MakeCard(66)
			Hover(card,T.BG4,T.Surface)

			local icoColor=cfg3.IconColor or T.TextSecondary
			local icoFrame=CardIcon(card,icoColor,T.Surface)
			New("TextLabel",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(15,15),BackgroundTransparency=1,Text="›",TextColor3=icoColor,TextSize=20,Font=Enum.Font.Gotham},icoFrame)

			CardText(card,cfg3.Title or "Button",cfg3.Description)

			New("TextLabel",{Size=UDim2.fromOffset(22,34),Position=UDim2.new(1,-30,0.5,-17),BackgroundTransparency=1,Text="›",TextColor3=T.TextTertiary,TextSize=20,Font=Enum.Font.Gotham},card)

			local btn=New("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},card)
			btn.MouseButton1Click:Connect(function()
				Tw(card,.07,{BackgroundColor3=T.Surface2})
				task.delay(.14,function() Tw(card,.12,{BackgroundColor3=T.BG4}) end)
				if cfg3.Callback then cfg3.Callback() end
			end)
		end

		-- ── Slider ────────────────────────────────────────────────────────────
		function Tab:AddSlider(cfg3)
			cfg3=cfg3 or {}
			local mn=cfg3.Min or 0; local mx=cfg3.Max or 100
			local cur=math.clamp(cfg3.Default or mn,mn,mx); local decs=cfg3.Decimals or 0
			local card=MakeCard(76)

			local function fmt(v) if decs>0 then return string.format("%."..decs.."f",v) end; return tostring(math.round(v)) end

			New("TextLabel",{Size=UDim2.new(0.6,0,0,22),Position=UDim2.fromOffset(16,14),BackgroundTransparency=1,Text=cfg3.Title or "Slider",TextColor3=T.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},card)
			local vLbl=New("TextLabel",{Size=UDim2.new(0.4,-16,0,22),Position=UDim2.new(0.6,0,0,14),BackgroundTransparency=1,Text=fmt(cur),TextColor3=T.Accent,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right},card)

			local trackBG=New("Frame",{Size=UDim2.new(1,-32,0,4),Position=UDim2.fromOffset(16,48),BackgroundColor3=T.Surface2,BorderSizePixel=0},card)
			New("UICorner",{CornerRadius=UDim.new(0,2)},trackBG)
			local fill=New("Frame",{Size=UDim2.fromScale((cur-mn)/(mx-mn),1),BackgroundColor3=T.Accent,BorderSizePixel=0},trackBG)
			New("UICorner",{CornerRadius=UDim.new(0,2)},fill)
			local thmb=New("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.new((cur-mn)/(mx-mn),-9,0.5,-9),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=3},trackBG)
			New("UICorner",{CornerRadius=UDim.new(0.5,0)},thmb)
			local hit=New("TextButton",{Size=UDim2.new(1,0,0,24),Position=UDim2.fromOffset(0,-10),BackgroundTransparency=1,Text="",ZIndex=10},trackBG)

			local drag2=false
			local function Upd(mx2)
				local s=math.clamp((mx2-trackBG.AbsolutePosition.X)/trackBG.AbsoluteSize.X,0,1)
				local v=mn+s*(mx-mn); if decs==0 then v=math.round(v) end; cur=v
				local sc=(v-mn)/(mx-mn)
				Tw(fill,.05,{Size=UDim2.fromScale(sc,1)}); Tw(thmb,.05,{Position=UDim2.new(sc,-9,0.5,-9)})
				vLbl.Text=fmt(v); if cfg3.Callback then cfg3.Callback(v) end
			end
			hit.MouseButton1Down:Connect(function() drag2=true; Upd(Mouse.X) end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag2=false end end)
			RunService.RenderStepped:Connect(function() if drag2 then Upd(Mouse.X) end end)
			return {SetValue=function(v) cur=math.clamp(v,mn,mx); Upd(trackBG.AbsolutePosition.X+(cur-mn)/(mx-mn)*trackBG.AbsoluteSize.X) end, GetValue=function() return cur end}
		end

		-- ── Input ─────────────────────────────────────────────────────────────
		function Tab:AddInput(cfg3)
			cfg3=cfg3 or {}
			local card=MakeCard(64)

			New("TextLabel",{Size=UDim2.new(0.45,0,0,22),Position=UDim2.fromOffset(16,21),BackgroundTransparency=1,Text=cfg3.Title or "Input",TextColor3=T.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},card)

			local box=New("TextBox",{Size=UDim2.new(0.5,-22,0,30),Position=UDim2.new(0.5,0,0,17),BackgroundColor3=T.Surface,BorderSizePixel=0,Text=cfg3.Default or "",PlaceholderText=cfg3.Placeholder or "Type here...",TextColor3=T.TextPrimary,PlaceholderColor3=T.TextTertiary,TextSize=12.5,Font=Enum.Font.Gotham,ClearTextOnFocus=false},card)
			New("UICorner",{CornerRadius=UDim.new(0,7)},box)
			New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},box)
			local st=Stroke(box,0.12)

			box.Focused:Connect(function() if st then Tw(st,.15,{Color=T.Accent,Transparency=0.35}) end end)
			box.FocusLost:Connect(function()
				if st then Tw(st,.15,{Color=Color3.fromRGB(255,255,255),Transparency=0.88}) end
				if cfg3.Callback then cfg3.Callback(box.Text) end
			end)
			return {GetValue=function() return box.Text end, SetValue=function(v) box.Text=v end}
		end

		-- ── Dropdown (single select) ──────────────────────────────────────────
		function Tab:AddDropdown(cfg3)
			cfg3=cfg3 or {}
			local opts=cfg3.Options or {}; local sel=cfg3.Default or (opts[1] or "")
			local card=MakeCard(66)
			Hover(card,T.BG4,T.Surface)

			New("TextLabel",{Size=UDim2.new(0.5,0,0,22),Position=UDim2.fromOffset(16,22),BackgroundTransparency=1,Text=cfg3.Title or "Dropdown",TextColor3=T.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},card)
			local selLbl=New("TextLabel",{Size=UDim2.new(0.45,-30,0,22),Position=UDim2.new(0.5,0,0,22),BackgroundTransparency=1,Text=sel,TextColor3=T.TextSecondary,TextSize=12.5,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right},card)
			New("TextLabel",{Size=UDim2.fromOffset(20,32),Position=UDim2.new(1,-28,0.5,-16),BackgroundTransparency=1,Text="⌄",TextColor3=T.TextTertiary,TextSize=15,Font=Enum.Font.Gotham},card)

			local function OD()
				local menu=New("Frame",{Size=UDim2.new(0,180,0,0),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(0,0,1,4),BackgroundColor3=T.BG2,BorderSizePixel=0,ZIndex=60},card)
				New("UICorner",{CornerRadius=UDim.new(0,10)},menu); Stroke(menu,0.15)
				New("UIListLayout",{Padding=UDim.new(0,0)},menu)
				New("UIPadding",{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},menu)

				for _,opt in ipairs(opts) do
					local ob=New("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=opt==sel and T.Surface or T.BG2,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=61},menu)
					New("TextLabel",{Size=UDim2.new(1,-36,1,0),Position=UDim2.fromOffset(12,0),BackgroundTransparency=1,Text=opt,TextColor3=opt==sel and T.Accent or T.TextPrimary,TextSize=12.5,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},ob)
					if opt==sel then
						New("TextLabel",{Size=UDim2.fromOffset(18,34),Position=UDim2.new(1,-22,0,0),BackgroundTransparency=1,Text="✓",TextColor3=T.Accent,TextSize=13,Font=Enum.Font.GothamBold},ob)
					end
					Hover(ob,opt==sel and T.Surface or T.BG2,T.Surface)
					ob.MouseButton1Click:Connect(function()
						sel=opt; selLbl.Text=opt
						if cfg3.Callback then cfg3.Callback(opt) end
						menu:Destroy()
					end)
				end
				local conn; conn=UserInputService.InputBegan:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseButton1 then
						task.delay(.05,function() if menu and menu.Parent then menu:Destroy() end end); conn:Disconnect()
					end
				end)
			end
			local cb=New("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},card)
			cb.MouseButton1Click:Connect(OD)
			return {GetValue=function() return sel end, SetValue=function(v) sel=v; selLbl.Text=v end}
		end

		-- ── Multi-Select (checkbox list popup) ────────────────────────────────
		-- กดปุ่ม → popup แสดงรายการทุกข้อ กาได้หลายอัน → Callback({list})
		function Tab:AddMultiSelect(cfg3)
			cfg3=cfg3 or {}
			local opts=cfg3.Options or {}
			local selected={}
			if cfg3.Default then for _,v in ipairs(cfg3.Default) do selected[v]=true end end

			local function selectedList()
				local t={}; for _,o in ipairs(opts) do if selected[o] then table.insert(t,o) end end; return t
			end
			local function countText()
				local n=0; for _ in pairs(selected) do n+=1 end
				return n==0 and "None selected" or n.." selected"
			end

			local card=MakeCard(66)
			Hover(card,T.BG4,T.Surface)

			New("TextLabel",{Size=UDim2.new(0.5,0,0,22),Position=UDim2.fromOffset(16,22),BackgroundTransparency=1,Text=cfg3.Title or "Multi-Select",TextColor3=T.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},card)
			local cntLbl=New("TextLabel",{Size=UDim2.new(0.45,-30,0,22),Position=UDim2.new(0.5,0,0,22),BackgroundTransparency=1,Text=countText(),TextColor3=T.TextSecondary,TextSize=12.5,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right},card)
			New("TextLabel",{Size=UDim2.fromOffset(20,32),Position=UDim2.new(1,-28,0.5,-16),BackgroundTransparency=1,Text="⌄",TextColor3=T.TextTertiary,TextSize=15,Font=Enum.Font.Gotham},card)

			local function OpenMenu()
				local menuH=math.min(#opts*40+10,220)
				local menu=New("Frame",{Size=UDim2.new(0,220,0,menuH),Position=UDim2.new(0,0,1,6),BackgroundColor3=T.BG2,BorderSizePixel=0,ZIndex=60,ClipsDescendants=true},card)
				New("UICorner",{CornerRadius=UDim.new(0,11)},menu); Stroke(menu,0.15)

				local sf=New("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.Surface2,CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},menu)
				New("UIListLayout",{Padding=UDim.new(0,0)},sf)
				New("UIPadding",{PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,5)},sf)

				local checkFrames={}
				for _,opt in ipairs(opts) do
					local ob=New("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=T.BG2,BorderSizePixel=0},sf)
					Hover(ob,T.BG2,T.Surface)

					local box2=New("Frame",{Size=UDim2.fromOffset(20,20),Position=UDim2.fromOffset(12,10),BackgroundColor3=selected[opt] and T.Accent or T.Surface2,BorderSizePixel=0},ob)
					New("UICorner",{CornerRadius=UDim.new(0,6)},box2); Stroke(box2,0.15)
					local chk=New("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="✓",TextColor3=Color3.fromRGB(255,255,255),TextSize=12,Font=Enum.Font.GothamBold,Visible=selected[opt]},box2)

					New("TextLabel",{Size=UDim2.new(1,-44,1,0),Position=UDim2.fromOffset(40,0),BackgroundTransparency=1,Text=opt,TextColor3=T.TextPrimary,TextSize=13,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},ob)

					checkFrames[opt]={box=box2,chk=chk}

					local hb=New("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},ob)
					hb.MouseButton1Click:Connect(function()
						selected[opt]=not selected[opt]
						Tw(box2,.15,{BackgroundColor3=selected[opt] and T.Accent or T.Surface2})
						chk.Visible=selected[opt]
						cntLbl.Text=countText()
						if cfg3.Callback then cfg3.Callback(selectedList()) end
					end)
				end

				local conn; conn=UserInputService.InputBegan:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseButton1 then
						task.delay(.08,function() if menu and menu.Parent then menu:Destroy() end end); conn:Disconnect()
					end
				end)
			end

			local cb=New("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},card)
			cb.MouseButton1Click:Connect(OpenMenu)
			return {
				GetValue=function() return selectedList() end,
				SetValue=function(list) selected={}; for _,v in ipairs(list) do selected[v]=true end; cntLbl.Text=countText() end,
				IsSelected=function(opt) return selected[opt]==true end,
			}
		end

		-- ── Listbox (scrollable pick list, single select) ─────────────────────
		-- แสดง list ฝังอยู่ในการ์ดเลย ไม่ต้อง popup
		function Tab:AddListbox(cfg3)
			cfg3=cfg3 or {}
			local opts=cfg3.Options or {}
			local sel=cfg3.Default or (opts[1] or "")
			local visRows=math.min(cfg3.MaxVisible or 5, #opts)
			local rowH=40
			local cardH=visRows*rowH+16+26

			local card=New("Frame",{Size=UDim2.new(1,0,0,cardH),BackgroundColor3=T.BG4,BorderSizePixel=0,LayoutOrder=NO(),ClipsDescendants=true},scroll)
			New("UICorner",{CornerRadius=UDim.new(0,T.Radius)},card); Stroke(card,0.07)

			New("TextLabel",{Size=UDim2.new(1,-16,0,26),Position=UDim2.fromOffset(16,0),BackgroundTransparency=1,Text=(cfg3.Title or "Listbox"):upper(),TextColor3=T.TextTertiary,TextSize=10.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},card)

			local sf=New("ScrollingFrame",{Size=UDim2.new(1,0,1,-26),Position=UDim2.fromOffset(0,26),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.Surface2,CanvasSize=UDim2.fromScale(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},card)
			New("UIListLayout",{Padding=UDim.new(0,0),SortOrder=Enum.SortOrder.LayoutOrder},sf)

			local rowObjs={}
			local function Refresh()
				for opt,rb in pairs(rowObjs) do
					local on=(opt==sel)
					Tw(rb.frame,.12,{BackgroundColor3=on and T.Surface or T.BG4})
					rb.lbl.TextColor3=on and T.TextPrimary or T.TextSecondary
					rb.lbl.Font=on and Enum.Font.GothamBold or Enum.Font.Gotham
					rb.dot.Visible=on
				end
			end

			for i,opt in ipairs(opts) do
				local row=New("Frame",{Size=UDim2.new(1,0,0,rowH),BackgroundColor3=opt==sel and T.Surface or T.BG4,BorderSizePixel=0,LayoutOrder=i},sf)

				if i<#opts then
					New("Frame",{Size=UDim2.new(1,-16,0,1),Position=UDim2.new(0,8,1,-1),BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.92,BorderSizePixel=0},row)
				end

				local dot=New("Frame",{Size=UDim2.fromOffset(7,7),Position=UDim2.fromOffset(14,16),BackgroundColor3=T.Accent,BorderSizePixel=0,Visible=opt==sel},row)
				New("UICorner",{CornerRadius=UDim.new(0.5,0)},dot)

				local lbl=New("TextLabel",{Size=UDim2.new(1,-50,1,0),Position=UDim2.fromOffset(30,0),BackgroundTransparency=1,Text=opt,TextColor3=opt==sel and T.TextPrimary or T.TextSecondary,TextSize=13,Font=opt==sel and Enum.Font.GothamBold or Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},row)

				local chk=New("TextLabel",{Size=UDim2.fromOffset(24,rowH),Position=UDim2.new(1,-28,0,0),BackgroundTransparency=1,Text="✓",TextColor3=T.Accent,TextSize=14,Font=Enum.Font.GothamBold,Visible=opt==sel},row)

				rowObjs[opt]={frame=row,lbl=lbl,dot=dot,chk=chk}

				local hb=New("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=5},row)
				hb.MouseButton1Click:Connect(function()
					sel=opt
					-- update checkmarks
					for o,rb in pairs(rowObjs) do rb.chk.Visible=(o==opt) end
					Refresh()
					if cfg3.Callback then cfg3.Callback(opt) end
				end)
				Hover(row, opt==sel and T.Surface or T.BG4, T.Surface2)
			end

			return {GetValue=function() return sel end, SetValue=function(v) sel=v; Refresh() end}
		end

		-- ── Keybind ───────────────────────────────────────────────────────────
		function Tab:AddKeybind(cfg3)
			cfg3=cfg3 or {}
			local ck=cfg3.Default; local ls=false
			local card=MakeCard(cfg3.Description and 72 or 64)
			Hover(card,T.BG4,T.Surface)

			New("TextLabel",{Size=UDim2.new(0.55,0,0,22),Position=UDim2.fromOffset(16,cfg3.Description and 16 or 21),BackgroundTransparency=1,Text=cfg3.Title or "Keybind",TextColor3=T.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},card)
			if cfg3.Description then
				New("TextLabel",{Size=UDim2.new(0.55,0,0,17),Position=UDim2.fromOffset(16,38),BackgroundTransparency=1,Text=cfg3.Description,TextColor3=T.TextTertiary,TextSize=11.5,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},card)
			end

			local function KN(k)
				if not k then return "None" end
				local s=tostring(k.KeyCode or k.UserInputType)
				return s:gsub("Enum%.KeyCode%.",""):gsub("Enum%.UserInputType%.",""):gsub("MouseButton","MB")
			end

			local badge=New("TextButton",{Size=UDim2.fromOffset(74,30),Position=UDim2.new(1,-88,0.5,-15),BackgroundColor3=T.Surface2,BorderSizePixel=0,Text=ck and KN(ck) or "None",TextColor3=T.TextPrimary,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false},card)
			New("UICorner",{CornerRadius=UDim.new(0,7)},badge); Stroke(badge,0.12)

			badge.MouseButton1Click:Connect(function()
				if ls then return end; ls=true; badge.Text="..."; Tw(badge,.15,{BackgroundColor3=T.Accent})
				local conn; conn=UserInputService.InputBegan:Connect(function(inp,gpe)
					if gpe then return end; ls=false; ck=inp; badge.Text=KN(inp)
					Tw(badge,.15,{BackgroundColor3=T.Surface2}); if cfg3.Callback then cfg3.Callback(inp) end; conn:Disconnect()
				end)
			end)
			return {GetValue=function() return ck end}
		end

		-- ── Paragraph ─────────────────────────────────────────────────────────
		function Tab:AddParagraph(cfg3)
			cfg3=cfg3 or {}
			local card=MakeCard(nil)
			card.AutomaticSize=Enum.AutomaticSize.Y; card.Size=UDim2.new(1,0,0,0)

			local con=New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,BorderSizePixel=0},card)
			New("UIListLayout",{Padding=UDim.new(0,4)},con)
			New("UIPadding",{PaddingTop=UDim.new(0,14),PaddingBottom=UDim.new(0,14),PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)},con)

			if cfg3.Title then New("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=cfg3.Title,TextColor3=T.TextPrimary,TextSize=13.5,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},con) end
			if cfg3.Description then New("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=cfg3.Description,TextColor3=T.TextSecondary,TextSize=12,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},con) end
		end

		return Tab
	end -- AddTab

	function Win:Notify(cfg2)
		cfg2=cfg2 or {}
		Notif(cfg2.Title or "Notice",cfg2.Description or "",cfg2.Type or "info",cfg2.Duration or 2.5)
	end

	function Win:SetTheme(name)
		local p=Presets[name]; if not p then return end
		for k,v in pairs(p) do T[k]=v end
		win.BackgroundColor3=T.BG2; tb.BackgroundColor3=T.BG; sb.BackgroundColor3=T.BG; content.BackgroundColor3=T.BG3
		Notif("Theme",name,"info",2)
	end

	function Win:SetAccent(color) T.Accent=color end
	function Win:SetKeybind(key) keybind=key end

	return Win
end

return Library

--[[
══════════════════════════════════════════════════
 EXAMPLE USAGE
══════════════════════════════════════════════════

local UI = loadstring(game:HttpGet("YOUR_URL"))()

local W = UI:CreateWindow({
    Title   = "My Script",
    Size    = UDim2.fromOffset(600, 440),
    Theme   = "Dark Blue",
    Keybind = Enum.KeyCode.LeftControl,
})

W:AddSection("Main")
local Home = W:AddTab({ Title = "Home" })
local Player = W:AddTab({ Title = "Player" })

-- Toggle
Home:AddToggle({
    Title = "God Mode",
    Default = false,
    Callback = function(v) print(v) end,
})

-- Button
Home:AddButton({
    Title = "Execute",
    Description = "Run script",
    Callback = function() print("clicked") end,
})

-- Slider
Home:AddSlider({
    Title = "Speed", Min = 16, Max = 200, Default = 50,
    Callback = function(v) game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end,
})

-- Dropdown (single)
Home:AddDropdown({
    Title = "Team",
    Options = {"Red", "Blue", "Green"},
    Default = "Red",
    Callback = function(v) print(v) end,
})

-- Multi-Select  ← NEW
Home:AddMultiSelect({
    Title = "ESP Options",
    Options = {"Boxes", "Names", "Health", "Tracers", "Dots"},
    Default = {"Boxes", "Names"},
    Callback = function(list)
        for _, v in ipairs(list) do print(v) end
    end,
})

-- Listbox  ← NEW
Home:AddListbox({
    Title = "Select game mode",
    Options = {"Competitive", "Casual", "Ranked", "Custom"},
    Default = "Competitive",
    MaxVisible = 4,
    Callback = function(v) print("Selected:", v) end,
})

-- Keybind
Home:AddKeybind({
    Title = "Toggle fly",
    Callback = function(key) print(key) end,
})

-- Notifications
W:Notify({ Title = "Loaded", Description = "Script ready!", Type = "success", Duration = 3 })

══════════════════════════════════════════════════
]]
