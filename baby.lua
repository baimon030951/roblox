--[[
	Made by Torch
	Extended with: Color Picker, Multi-select Dropdown, Search Bar,
	Nested Tabs, Config Save/Load, Player List, Bind Manager, Value Display
]]

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone
local Destroy = game.Destroy

if (not game:IsLoaded()) then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end

--// Important
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.2,
	ThemeMode = "Dark",
	Size = nil,
}

local Theme = {
	Primary      = Color3.fromRGB(30, 30, 30),
	Secondary    = Color3.fromRGB(35, 35, 35),
	Component    = Color3.fromRGB(40, 40, 40),
	Interactables= Color3.fromRGB(45, 45, 45),
	Tab          = Color3.fromRGB(200, 200, 200),
	Title        = Color3.fromRGB(240, 240, 240),
	Description  = Color3.fromRGB(200, 200, 200),
	Shadow       = Color3.fromRGB(0, 0, 0),
	Outline      = Color3.fromRGB(40, 40, 40),
	Icon         = Color3.fromRGB(220, 220, 220),
	Accent       = Color3.fromRGB(153, 155, 255),
}

--// Services & Functions
local Type, Blur = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween  = GetService(game, "TweenService");
	Run    = GetService(game, "RunService");
	Input  = GetService(game, "UserInputService");
}

local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI   = LocalPlayer.PlayerGui;
}

local Tween = function(Object, Speed, Properties, Info)
	local Style, Direction
	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end
	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object, Properties)
	for Index, Property in next, Properties do
		Object[Index] = Property
	end
	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
	}
	return UDim2.new(unpack(New))
end

local Color = function(Color3Value, Factor, Mode)
	Mode = Mode or Setup.ThemeMode
	if Mode == "Light" then
		return Color3.fromRGB(
			math.clamp((Color3Value.R * 255) - Factor, 0, 255),
			math.clamp((Color3Value.G * 255) - Factor, 0, 255),
			math.clamp((Color3Value.B * 255) - Factor, 0, 255)
		)
	else
		return Color3.fromRGB(
			math.clamp((Color3Value.R * 255) + Factor, 0, 255),
			math.clamp((Color3Value.G * 255) + Factor, 0, 255),
			math.clamp((Color3Value.B * 255) + Factor, 0, 255)
		)
	end
end

local Drag = function(Canvas)
	if Canvas then
		local Dragging, DragInput, Start, StartPosition

		Connect(Canvas.InputBegan, function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position

				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		Connect(Canvas.InputChanged, function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				DragInput = Input
			end
		end)

		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				local delta = Input.Position - Start
				Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
			end
		end)
	end
end

local Resizing = {
	TopLeft     = { X = Vector2.new(-1, 0), Y = Vector2.new(0, -1) };
	TopRight    = { X = Vector2.new(1,  0), Y = Vector2.new(0, -1) };
	BottomLeft  = { X = Vector2.new(-1, 0), Y = Vector2.new(0,  1) };
	BottomRight = { X = Vector2.new(1,  0), Y = Vector2.new(0,  1) };
}

local Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")
			for _, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)
				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end

		Connect(Player.Mouse.Move, function()
			if Type and MousePos and Size and UIPos then
				local Mode = Resizing[Type.Name]
				if not Mode then return end
				local Delta = Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos
				local NewSize = Vector2.new(
					math.clamp(Size.X + Delta.X * Mode.X.X, Minimum.X, Maximum.X),
					math.clamp(Size.Y + Delta.Y * Mode.Y.Y, Minimum.Y, Maximum.Y)
				)
				local DeltaAnchor = Vector2.new(Tab.AnchorPoint.X * (NewSize.X - Size.X), Tab.AnchorPoint.Y * (NewSize.Y - Size.Y))
				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)
				Tab.Position = UDim2.new(UIPos.X.Scale, UIPos.X.Offset + DeltaAnchor.X * Mode.X.X, UIPos.Y.Scale, UIPos.Y.Offset + DeltaAnchor.Y * Mode.Y.Y)
			end
		end)
	end)
end

--// Setup [UI]
local Screen
if identifyexecutor then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748")
	Blur = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))()
else
	Screen = script.Parent
	Blur = require(script.Blur)
end

Screen.Main.Visible = false

xpcall(function()
	Screen.Parent = game.CoreGui
end, function()
	Screen.Parent = Player.GUI
end)

--// Tables
local Animations  = {}
local Blurs       = {}
local Components  = Screen:FindFirstChild("Components")
local Library     = {}
local StoredInfo  = { ["Sections"] = {}, ["Tabs"] = {} }

--// Saved Binds & Config storage
local SavedBinds  = {}  -- { [Title] = KeyCode/UserInputType }
local SavedConfig = {}  -- { [Title] = value }

--// Animations
function Animations:Open(Window, Transparency, UseCurrentSize)
	local Original   = UseCurrentSize and Window.Size or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow     = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Shadow,  { Transparency = 1 })
	SetProperty(Window,  { Size = Multiplied, GroupTransparency = 1, Visible = true })

	Tween(Shadow, .25, { Transparency = 0.5 })
	Tween(Window, .25, { Size = Original, GroupTransparency = Transparency or 0 })
end

function Animations:Close(Window)
	local Original   = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow     = Window:FindFirstChildOfClass("UIStroke")

	Tween(Shadow, .25, { Transparency = 1 })
	Tween(Window, .25, { Size = Multiplied, GroupTransparency = 1 })

	task.wait(.25)
	Window.Size    = Original
	Window.Visible = false
end

function Animations:Component(Component, Custom)
	Connect(Component.InputBegan, function()
		if Custom then
			Tween(Component, .25, { Transparency = .85 })
		else
			Tween(Component, .25, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) })
		end
	end)
	Connect(Component.InputEnded, function()
		if Custom then
			Tween(Component, .25, { Transparency = 1 })
		else
			Tween(Component, .25, { BackgroundColor3 = Theme.Component })
		end
	end)
end

-- ============================================================
--  UTILITY: build a Frame-based popup overlay
-- ============================================================
local function MakeOverlay(Parent, Title)
	local Overlay = Instance.new("CanvasGroup")
	Overlay.Size              = UDim2.new(0, 340, 0, 420)
	Overlay.Position          = UDim2.new(0.5, -170, 0.5, -210)
	Overlay.BackgroundColor3  = Theme.Secondary
	Overlay.GroupTransparency = 1
	Overlay.ZIndex            = 10
	Overlay.Name              = "Overlay_" .. Title

	local Stroke = Instance.new("UIStroke", Overlay)
	Stroke.Color     = Theme.Outline
	Stroke.Thickness = 1

	local Header = Instance.new("TextLabel", Overlay)
	Header.Size              = UDim2.new(1, -20, 0, 30)
	Header.Position          = UDim2.new(0, 10, 0, 8)
	Header.BackgroundTransparency = 1
	Header.Text              = Title
	Header.TextColor3        = Theme.Title
	Header.Font              = Enum.Font.GothamBold
	Header.TextSize          = 14
	Header.TextXAlignment    = Enum.TextXAlignment.Left

	local CloseBtn = Instance.new("TextButton", Overlay)
	CloseBtn.Size             = UDim2.new(0, 24, 0, 24)
	CloseBtn.Position         = UDim2.new(1, -30, 0, 8)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text             = "✕"
	CloseBtn.TextColor3       = Theme.Description
	CloseBtn.Font             = Enum.Font.GothamBold
	CloseBtn.TextSize         = 14

	Overlay.Parent = Parent
	Animations:Open(Overlay, 0, true)

	Connect(CloseBtn.MouseButton1Click, function()
		Animations:Close(Overlay)
		task.wait(.3)
		Destroy(Overlay)
	end)

	return Overlay, Header, CloseBtn
end

-- ============================================================
--  UTILITY: HSV -> Color3 and Color3 -> HSV
-- ============================================================
local function HSVtoRGB(h, s, v)
	return Color3.fromHSV(h, s, v)
end

-- ============================================================
--  LIBRARY
-- ============================================================
function Library:CreateWindow(Settings)
	local Window  = Clone(Screen:WaitForChild("Main"))
	local Sidebar = Window:FindFirstChild("Sidebar")
	local Holder  = Window:FindFirstChild("Main")
	local BG      = Window:FindFirstChild("BackgroundShadow")
	local TabList = Sidebar:FindFirstChild("Tab")

	local Options  = {}
	local Examples = {}
	local Opened   = true
	local Maximized = false
	local BlurEnabled = false

	for _, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end

	Drag(Window)
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9))
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size         = Settings.Size
	Setup.ThemeMode    = Settings.Theme or "Dark"

	if Settings.Blurring then
		Blurs[Settings.Title] = Blur.new(Window, 5)
		BlurEnabled = true
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	local function CloseToggle()
		if Opened then
			if BlurEnabled then Blurs[Settings.Title].root.Parent = nil end
			Opened = false
			Animations:Close(Window)
			Window.Visible = false
		else
			Animations:Open(Window, Setup.Transparency)
			Opened = true
			if BlurEnabled then Blurs[Settings.Title].root.Parent = workspace.CurrentCamera end
		end
	end

	for _, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") then
			local Name = Button.Name
			Animations:Component(Button, true)
			Connect(Button.MouseButton1Click, function()
				if Name == "Close" then
					CloseToggle()
				elseif Name == "Maximize" then
					if Maximized then
						Maximized = false
						Tween(Window, .15, { Size = Setup.Size })
					else
						Maximized = true
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5) })
					end
				elseif Name == "Minimize" then
					Opened = false
					Window.Visible = false
					if BlurEnabled then Blurs[Settings.Title].root.Parent = nil end
				end
			end)
		end
	end

	Services.Input.InputBegan:Connect(function(Input, Focused)
		if Input.KeyCode == Setup.Keybind and not Focused then
			CloseToggle()
		end
	end)

	-- --------------------------------------------------------
	--  Tab system
	-- --------------------------------------------------------
	function Options:SetTab(Name)
		for _, Button in next, TabList:GetChildren() do
			if Button:IsA("TextButton") then
				local IsOpen    = Button.Value
				local SameName  = (Button.Name == Name)
				local Padding   = Button:FindFirstChildOfClass("UIPadding")

				if SameName and not IsOpen.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) })
					Tween(Button,  .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) })
					IsOpen.Value = true
				elseif not SameName and IsOpen.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) })
					Tween(Button,  .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) })
					IsOpen.Value = false
				end
			end
		end

		for _, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local IsOpen   = Main.Value
				local SameName = (Main.Name == Name)
				local Scroll   = Main:FindFirstChild("ScrollingFrame")

				if SameName and not IsOpen.Value then
					IsOpen.Value = true
					Main.Visible = true
					Tween(Main, .3, { GroupTransparency = 0 })
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) })
				elseif not SameName and IsOpen.Value then
					IsOpen.Value = false
					Tween(Main, .15, { GroupTransparency = 1 })
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) })
					task.delay(.2, function() Main.Visible = false end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings2)
		local Example = Examples["SectionExample"]
		local Section = Clone(Example)
		StoredInfo["Sections"][Settings2.Name] = Settings2.Order
		SetProperty(Section, {
			Parent      = Example.Parent,
			Text        = Settings2.Name,
			Name        = Settings2.Name,
			LayoutOrder = Settings2.Order,
			Visible     = true,
		})
	end

	function Options:AddTab(Settings2)
		if StoredInfo["Tabs"][Settings2.Title] then
			error("[UI LIB]: A tab with the same name has already been created")
		end

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"]
		local Section = StoredInfo["Sections"][Settings2.Section]
		local Main    = Clone(MainExample)
		local Tab     = Clone(Example)

		if not Settings2.Icon then
			Destroy(Tab["ICO"])
		else
			SetProperty(Tab["ICO"], { Image = Settings2.Icon })
		end

		StoredInfo["Tabs"][Settings2.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings2.Title })
		SetProperty(Main, { Parent = MainExample.Parent, Name = Settings2.Title })
		SetProperty(Tab,  { Parent = Example.Parent, LayoutOrder = Section or #StoredInfo["Sections"] + 1, Name = Settings2.Title, Visible = true })

		Connect(Tab.MouseButton1Click, function()
			Options:SetTab(Tab.Name)
		end)

		return Main.ScrollingFrame
	end

	-- --------------------------------------------------------
	--  Notifications
	-- --------------------------------------------------------
	function Options:Notify(Settings2)
		local Notification = Clone(Components["Notification"])
		local Title, Description = Options:GetLabels(Notification)
		local Timer = Notification["Timer"]

		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description })
		SetProperty(Notification, { Parent = Screen["Frame"] })

		task.spawn(function()
			local Duration = Settings2.Duration or 2
			Animations:Open(Notification, Setup.Transparency, true)
			Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) })
			task.wait(Duration)
			Animations:Close(Notification)
			task.wait(1)
			Destroy(Notification)
		end)
	end

	-- --------------------------------------------------------
	--  Helpers
	-- --------------------------------------------------------
	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")
		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings2)
		local Section = Clone(Components["Section"])
		SetProperty(Section, { Text = Settings2.Name, Parent = Settings2.Tab, Visible = true })
	end

	-- --------------------------------------------------------
	--  Original Components
	-- --------------------------------------------------------
	function Options:AddButton(Settings2)
		local Button = Clone(Components["Button"])
		local Title, Description = Options:GetLabels(Button)
		Connect(Button.MouseButton1Click, Settings2.Callback)
		Animations:Component(Button)
		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description })
		SetProperty(Button, { Name = Settings2.Title, Parent = Settings2.Tab, Visible = true })
	end

	function Options:AddInput(Settings2)
		local Input   = Clone(Components["Input"])
		local Title, Description = Options:GetLabels(Input)
		local TextBox = Input["Main"]["Input"]

		Connect(Input.MouseButton1Click, function() TextBox:CaptureFocus() end)
		Connect(TextBox.FocusLost,       function() Settings2.Callback(TextBox.Text) end)

		Animations:Component(Input)
		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description })
		SetProperty(Input, { Name = Settings2.Title, Parent = Settings2.Tab, Visible = true })
	end

	function Options:AddToggle(Settings2)
		local Toggle  = Clone(Components["Toggle"])
		local Title, Description = Options:GetLabels(Toggle)
		local On      = Toggle["Value"]
		local Main    = Toggle["Main"]
		local Circle  = Main["Circle"]

		local function Set(Value)
			if Value then
				Tween(Main,   .2, { BackgroundColor3 = Theme.Accent })
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) })
			else
				Tween(Main,   .2, { BackgroundColor3 = Theme.Interactables })
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) })
			end
			On.Value = Value
		end

		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value
			Set(Value)
			Settings2.Callback(Value)
		end)

		Animations:Component(Toggle)
		Set(Settings2.Default)
		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description })
		SetProperty(Toggle, { Name = Settings2.Title, Parent = Settings2.Tab, Visible = true })

		-- Config support
		SavedConfig[Settings2.Title] = Settings2.Default
		return {
			Set = function(val) Set(val); SavedConfig[Settings2.Title] = val end,
			Get = function() return On.Value end,
		}
	end

	function Options:AddKeybind(Settings2)
		local Dropdown = Clone(Components["Keybind"])
		local Title, Description = Options:GetLabels(Dropdown)
		local Bind = Dropdown["Main"].Options

		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }
		local Types = { ["Mouse"] = "Enum.UserInputType.MouseButton", ["Key"] = "Enum.KeyCode." }

		Connect(Dropdown.MouseButton1Click, function()
			local Finished = false
			local Detect
			SetProperty(Bind, { Text = "..." })

			Detect = Connect(Services.Input.InputBegan, function(Key, Focused)
				if not Finished and not Focused then
					Finished = true
					Detect:Disconnect()   -- FIX: disconnect after first input

					if table.find(Mouse, Key.UserInputType) then
						Settings2.Callback(Key)
						SavedBinds[Settings2.Title] = Key.UserInputType
						Bind.Text = tostring(Key.UserInputType):gsub(Types.Mouse, "MB")
					elseif Key.UserInputType == Enum.UserInputType.Keyboard then
						Settings2.Callback(Key)
						SavedBinds[Settings2.Title] = Key.KeyCode
						Bind.Text = tostring(Key.KeyCode):gsub(Types.Key, "")
					end
				end
			end)
		end)

		Animations:Component(Dropdown)
		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description })
		SetProperty(Dropdown, { Name = Settings2.Title, Parent = Settings2.Tab, Visible = true })
	end

	function Options:AddSlider(Settings2)
		local Slider  = Clone(Components["Slider"])
		local Title, Description = Options:GetLabels(Slider)
		local Main    = Slider["Slider"]
		local Amount  = Main["Main"].Input
		local Slide   = Main["Slide"]
		local Fire    = Slide["Fire"]
		local Fill    = Slide["Highlight"]

		local Active = false
		local Value  = Settings2.Default or 0

		local function SetNumber(Number)
			if Settings2.AllowDecimals then
				local Power = 10 ^ (Settings2.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			return Number
		end

		local function Update(Num)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X
			Scale = math.clamp(Scale, 0, 1)
			if Num then
				Num = math.clamp(Num, 0, Settings2.MaxValue)
			end
			Value = SetNumber(Num or (Scale * Settings2.MaxValue))
			Amount.Text = tostring(Value)
			Fill.Size = UDim2.fromScale((Num and Num / Settings2.MaxValue) or Scale, 1)
			Settings2.Callback(Value)
			SavedConfig[Settings2.Title] = Value
		end

		Connect(Amount.FocusLost, function() Update(tonumber(Amount.Text) or 0) end)
		Connect(Fire.MouseButton1Down, function()
			Active = true
			local Timeout = 0
			repeat
				task.wait()
				Timeout = Timeout + 1
				Update()
			until not Active or Timeout > 600  -- FIX: 10s max timeout
		end)
		Connect(Services.Input.InputEnded, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale(Value / (Settings2.MaxValue or 100), 1)
		Amount.Text = tostring(Value)
		Animations:Component(Slider)
		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description })
		SetProperty(Slider, { Name = Settings2.Title, Parent = Settings2.Tab, Visible = true })

		return {
			Set = function(v) Update(v) end,
			Get = function() return Value end,
		}
	end

	function Options:AddParagraph(Settings2)
		local Paragraph = Clone(Components["Paragraph"])
		local Title, Description = Options:GetLabels(Paragraph)
		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description })
		SetProperty(Paragraph,   { Parent = Settings2.Tab, Visible = true })
	end

	function Options:AddDropdown(Settings2)
		local Dropdown = Clone(Components["Dropdown"])
		local Title, Description = Options:GetLabels(Dropdown)
		local Text = Dropdown["Main"].Options

		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"])
			local Buttons = Example["Top"]["Buttons"]

			Tween(BG, .25, { BackgroundTransparency = 0.6 })
			SetProperty(Example, { Parent = Window })
			Animations:Open(Example, 0, true)

			for _, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)
					Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 })
						Animations:Close(Example)
						task.wait(2); Destroy(Example)
					end)
				end
			end

			for Index, Option in next, Settings2.Options do
				local Button = Clone(Examples["DropdownButtonExample"])
				local BTitle, BDesc = Options:GetLabels(Button)
				local Selected = Button["Value"]

				Animations:Component(Button)
				SetProperty(BTitle,  { Text = Index })
				SetProperty(Button,  { Parent = Example.ScrollingFrame, Visible = true })
				Destroy(BDesc)

				Connect(Button.MouseButton1Click, function()
					if not Selected.Value then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables })
						Settings2.Callback(Option)
						Text.Text = Index
						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component })
					end
					Selected.Value = not Selected.Value
					Tween(BG, .25, { BackgroundTransparency = 1 })
					Animations:Close(Example)
					task.wait(2); Destroy(Example)
				end)
			end
		end)

		Animations:Component(Dropdown)
		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description })
		SetProperty(Dropdown, { Name = Settings2.Title, Parent = Settings2.Tab, Visible = true })
	end

	-- ============================================================
	--  NEW: Multi-select Dropdown
	-- ============================================================
	function Options:AddMultiDropdown(Settings2)
		-- Settings2: Title, Description, Options{}, Tab, Callback(selectedTable)
		local Dropdown = Clone(Components["Dropdown"])
		local Title, Description = Options:GetLabels(Dropdown)
		local Text = Dropdown["Main"].Options

		local Selected = {}
		Text.Text = "None"

		local function UpdateLabel()
			local Keys = {}
			for k in next, Selected do table.insert(Keys, k) end
			Text.Text = (#Keys == 0) and "None" or table.concat(Keys, ", ")
		end

		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"])
			local Buttons = Example["Top"]["Buttons"]

			Tween(BG, .25, { BackgroundTransparency = 0.6 })
			SetProperty(Example, { Parent = Window })
			Animations:Open(Example, 0, true)

			for _, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)
					Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 })
						Animations:Close(Example)
						task.wait(2); Destroy(Example)
					end)
				end
			end

			for Index, Option in next, Settings2.Options do
				local Button = Clone(Examples["DropdownButtonExample"])
				local BTitle, BDesc = Options:GetLabels(Button)

				Animations:Component(Button)
				SetProperty(BTitle, { Text = Index })
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true })
				Destroy(BDesc)

				-- Show already-selected state
				if Selected[Index] then
					Button.BackgroundColor3 = Theme.Interactables
				end

				Connect(Button.MouseButton1Click, function()
					if Selected[Index] then
						Selected[Index] = nil
						Tween(Button, .25, { BackgroundColor3 = Theme.Component })
					else
						Selected[Index] = Option
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables })
					end
					UpdateLabel()
					-- Return list of selected values
					local Values = {}
					for _, v in next, Selected do table.insert(Values, v) end
					Settings2.Callback(Values)
					SavedConfig[Settings2.Title] = Selected
				end)
			end
		end)

		Animations:Component(Dropdown)
		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description })
		SetProperty(Dropdown, { Name = Settings2.Title, Parent = Settings2.Tab, Visible = true })

		return {
			Get = function() return Selected end,
			Set = function(tbl) Selected = tbl; UpdateLabel() end,
		}
	end

	-- ============================================================
	--  NEW: Search / Filter Box
	-- ============================================================
	function Options:AddSearchBar(Settings2)
		-- Settings2: Title, Description, Placeholder, Tab, Callback(query)
		local Input   = Clone(Components["Input"])
		local Title, Description = Options:GetLabels(Input)
		local TextBox = Input["Main"]["Input"]

		TextBox.PlaceholderText  = Settings2.Placeholder or "Search..."
		TextBox.PlaceholderColor3 = Theme.Description

		Connect(Input.MouseButton1Click, function() TextBox:CaptureFocus() end)
		Connect(TextBox.Changed, function(prop)
			if prop == "Text" then
				Settings2.Callback(TextBox.Text)
			end
		end)

		Animations:Component(Input)
		SetProperty(Title,       { Text = Settings2.Title or "Search" })
		SetProperty(Description, { Text = Settings2.Description or "" })
		SetProperty(Input, { Name = Settings2.Title or "SearchBar", Parent = Settings2.Tab, Visible = true })
	end

	-- ============================================================
	--  NEW: Nested Tabs (Sub-tabs inside a tab's scroll frame)
	-- ============================================================
	function Options:AddNestedTabs(Settings2)
		-- Settings2: Tabs{ "Name1", "Name2" }, Tab (parent ScrollingFrame)
		-- Returns: { ["Name1"] = subScrollFrame, ... }
		local Container = Instance.new("Frame")
		Container.Size              = UDim2.new(1, 0, 0, 200)
		Container.AutomaticSize     = Enum.AutomaticSize.Y
		Container.BackgroundTransparency = 1
		Container.Parent            = Settings2.Tab

		-- Tab bar
		local TabBar = Instance.new("Frame", Container)
		TabBar.Size             = UDim2.new(1, 0, 0, 28)
		TabBar.BackgroundColor3 = Theme.Primary
		TabBar.BorderSizePixel  = 0

		local TabBarLayout = Instance.new("UIListLayout", TabBar)
		TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
		TabBarLayout.SortOrder     = Enum.SortOrder.LayoutOrder

		-- Content holder
		local Content = Instance.new("Frame", Container)
		Content.Size             = UDim2.new(1, 0, 0, 0)
		Content.AutomaticSize    = Enum.AutomaticSize.Y
		Content.Position         = UDim2.new(0, 0, 0, 30)
		Content.BackgroundTransparency = 1

		local SubFrames = {}
		local SubButtons = {}
		local ActiveSub  = nil

		local function SetSub(Name)
			for n, frame in next, SubFrames do
				frame.Visible = (n == Name)
			end
			for n, btn in next, SubButtons do
				Tween(btn, .2, {
					BackgroundColor3 = (n == Name) and Theme.Interactables or Theme.Primary,
					TextColor3       = (n == Name) and Theme.Title or Theme.Description,
				})
			end
			ActiveSub = Name
		end

		local SubScrolls = {}

		for Order, TabName in ipairs(Settings2.Tabs) do
			-- Button
			local Btn = Instance.new("TextButton", TabBar)
			Btn.Size                = UDim2.new(0, 90, 1, 0)
			Btn.BackgroundColor3    = Theme.Primary
			Btn.BorderSizePixel     = 0
			Btn.Text                = TabName
			Btn.TextColor3          = Theme.Description
			Btn.Font                = Enum.Font.Gotham
			Btn.TextSize            = 12
			Btn.LayoutOrder         = Order
			SubButtons[TabName]     = Btn

			-- Underline indicator
			local Underline = Instance.new("Frame", Btn)
			Underline.Name           = "Underline"
			Underline.Size           = UDim2.new(1, 0, 0, 2)
			Underline.AnchorPoint    = Vector2.new(0, 1)
			Underline.Position       = UDim2.new(0, 0, 1, 0)
			Underline.BackgroundColor3 = Theme.Accent
			Underline.BorderSizePixel = 0
			Underline.Visible        = false

			-- Sub-frame with scroll
			local SubFrame = Instance.new("ScrollingFrame", Content)
			SubFrame.Size             = UDim2.new(1, 0, 0, 0)
			SubFrame.AutomaticSize    = Enum.AutomaticSize.Y
			SubFrame.BackgroundTransparency = 1
			SubFrame.ScrollBarThickness = 2
			SubFrame.ScrollBarImageColor3 = Theme.Component
			SubFrame.Visible          = false
			SubFrame.BorderSizePixel  = 0

			local SubLayout = Instance.new("UIListLayout", SubFrame)
			SubLayout.SortOrder  = Enum.SortOrder.LayoutOrder
			SubLayout.Padding    = UDim.new(0, 4)

			SubFrames[TabName]   = SubFrame
			SubScrolls[TabName]  = SubFrame

			Connect(Btn.MouseButton1Click, function()
				SetSub(TabName)
				for n, u in next, SubButtons do
					local ul = u:FindFirstChild("Underline")
					if ul then ul.Visible = (n == TabName) end
				end
			end)
		end

		-- Activate first
		if #Settings2.Tabs > 0 then
			SetSub(Settings2.Tabs[1])
			local firstBtn = SubButtons[Settings2.Tabs[1]]
			local ul = firstBtn and firstBtn:FindFirstChild("Underline")
			if ul then ul.Visible = true end
		end

		return SubScrolls
	end

	-- ============================================================
	--  NEW: Color Picker
	-- ============================================================
	function Options:AddColorPicker(Settings2)
		-- Settings2: Title, Description, Default (Color3), Tab, Callback(Color3)
		local Button = Clone(Components["Button"])
		local Title, Description = Options:GetLabels(Button)

		local CurrentColor = Settings2.Default or Color3.fromRGB(255, 0, 0)
		SavedConfig[Settings2.Title] = CurrentColor

		-- Preview swatch (replaces main button icon)
		local Swatch = Instance.new("Frame", Button)
		Swatch.Size             = UDim2.new(0, 20, 0, 20)
		Swatch.AnchorPoint      = Vector2.new(1, 0.5)
		Swatch.Position         = UDim2.new(1, -12, 0.5, 0)
		Swatch.BackgroundColor3 = CurrentColor
		Swatch.BorderSizePixel  = 0
		Instance.new("UICorner", Swatch).CornerRadius = UDim.new(0, 4)

		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = Settings2.Description or "Click to pick color" })
		SetProperty(Button, { Name = Settings2.Title, Parent = Settings2.Tab, Visible = true })
		Animations:Component(Button)

		Connect(Button.MouseButton1Click, function()
			-- Build Color Picker popup
			local Overlay, _, CloseBtn = MakeOverlay(Window, "Color Picker — " .. Settings2.Title)
			Overlay.Size = UDim2.new(0, 300, 0, 350)
			Overlay.Position = UDim2.new(0.5, -150, 0.5, -175)

			local H, S, V = Color3.toHSV(CurrentColor)

			-- Saturation/Value picker (gradient box)
			local SVBox = Instance.new("ImageLabel", Overlay)
			SVBox.Size             = UDim2.new(0, 260, 0, 180)
			SVBox.Position         = UDim2.new(0.5, -130, 0, 45)
			SVBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
			SVBox.Image            = "rbxassetid://4155801252"  -- white-to-transparent gradient
			SVBox.BorderSizePixel  = 0
			Instance.new("UICorner", SVBox).CornerRadius = UDim.new(0, 4)

			-- Black overlay for V axis
			local BlackOverlay = Instance.new("ImageLabel", SVBox)
			BlackOverlay.Size  = UDim2.new(1, 0, 1, 0)
			BlackOverlay.Image = "rbxassetid://4155801252"
			BlackOverlay.ImageColor3 = Color3.fromRGB(0, 0, 0)
			BlackOverlay.Rotation    = 90
			BlackOverlay.BackgroundTransparency = 1

			-- SV cursor
			local SVCursor = Instance.new("Frame", SVBox)
			SVCursor.Size            = UDim2.new(0, 10, 0, 10)
			SVCursor.AnchorPoint     = Vector2.new(0.5, 0.5)
			SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SVCursor.BorderSizePixel = 1
			Instance.new("UICorner", SVCursor).CornerRadius = UDim.new(1, 0)
			SVCursor.Position = UDim2.new(S, 0, 1 - V, 0)

			-- Hue slider
			local HueBar = Instance.new("ImageLabel", Overlay)
			HueBar.Size           = UDim2.new(0, 260, 0, 16)
			HueBar.Position       = UDim2.new(0.5, -130, 0, 235)
			HueBar.Image          = "rbxassetid://698052001"  -- rainbow gradient
			HueBar.BorderSizePixel = 0
			Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 4)

			local HueCursor = Instance.new("Frame", HueBar)
			HueCursor.Size            = UDim2.new(0, 6, 1, 4)
			HueCursor.AnchorPoint     = Vector2.new(0.5, 0.5)
			HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			HueCursor.Position        = UDim2.new(H, 0, 0.5, 0)
			HueCursor.BorderSizePixel = 1
			Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(0, 3)

			-- Hex input
			local HexLabel = Instance.new("TextLabel", Overlay)
			HexLabel.Size             = UDim2.new(0, 60, 0, 24)
			HexLabel.Position         = UDim2.new(0.5, -130, 0, 260)
			HexLabel.BackgroundTransparency = 1
			HexLabel.Text             = "Hex:"
			HexLabel.TextColor3       = Theme.Description
			HexLabel.Font             = Enum.Font.Gotham
			HexLabel.TextSize         = 12
			HexLabel.TextXAlignment   = Enum.TextXAlignment.Left

			local HexBox = Instance.new("TextBox", Overlay)
			HexBox.Size             = UDim2.new(0, 130, 0, 24)
			HexBox.Position         = UDim2.new(0.5, -70, 0, 260)
			HexBox.BackgroundColor3 = Theme.Interactables
			HexBox.BorderSizePixel  = 0
			HexBox.Text             = string.format("#%02X%02X%02X", math.round(CurrentColor.R*255), math.round(CurrentColor.G*255), math.round(CurrentColor.B*255))
			HexBox.TextColor3       = Theme.Title
			HexBox.Font             = Enum.Font.GothamMono
			HexBox.TextSize         = 12
			Instance.new("UICorner", HexBox).CornerRadius = UDim.new(0, 4)

			-- Preview
			local Preview = Instance.new("Frame", Overlay)
			Preview.Size            = UDim2.new(0, 50, 0, 24)
			Preview.Position        = UDim2.new(0.5, 70, 0, 260)
			Preview.BackgroundColor3 = CurrentColor
			Preview.BorderSizePixel = 0
			Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

			-- Apply button
			local ApplyBtn = Instance.new("TextButton", Overlay)
			ApplyBtn.Size            = UDim2.new(0, 260, 0, 28)
			ApplyBtn.Position        = UDim2.new(0.5, -130, 0, 295)
			ApplyBtn.BackgroundColor3 = Theme.Accent
			ApplyBtn.BorderSizePixel = 0
			ApplyBtn.Text            = "Apply"
			ApplyBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
			ApplyBtn.Font            = Enum.Font.GothamBold
			ApplyBtn.TextSize        = 13
			Instance.new("UICorner", ApplyBtn).CornerRadius = UDim.new(0, 4)

			local function UpdateColor()
				local New = Color3.fromHSV(H, S, V)
				CurrentColor = New
				SVBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
				SVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
				HueCursor.Position = UDim2.new(H, 0, 0.5, 0)
				Preview.BackgroundColor3 = New
				HexBox.Text = string.format("#%02X%02X%02X", math.round(New.R*255), math.round(New.G*255), math.round(New.B*255))
			end

			-- Hue dragging
			local DraggingHue = false
			Connect(HueBar.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingHue = true end
			end)
			Connect(Services.Input.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingHue = false end
			end)
			Connect(Services.Input.InputChanged, function(Input)
				if DraggingHue and Input.UserInputType == Enum.UserInputType.MouseMovement then
					H = math.clamp((Input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
					UpdateColor()
				end
			end)

			-- SV dragging
			local DraggingSV = false
			Connect(SVBox.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingSV = true end
			end)
			Connect(Services.Input.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingSV = false end
			end)
			Connect(Services.Input.InputChanged, function(Input)
				if DraggingSV and Input.UserInputType == Enum.UserInputType.MouseMovement then
					S = math.clamp((Input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
					V = 1 - math.clamp((Input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
					UpdateColor()
				end
			end)

			-- Hex input
			Connect(HexBox.FocusLost, function()
				local hex = HexBox.Text:gsub("#", "")
				if #hex == 6 then
					local r = tonumber(hex:sub(1,2), 16) or 0
					local g = tonumber(hex:sub(3,4), 16) or 0
					local b = tonumber(hex:sub(5,6), 16) or 0
					local c = Color3.fromRGB(r, g, b)
					H, S, V = Color3.toHSV(c)
					UpdateColor()
				end
			end)

			Connect(ApplyBtn.MouseButton1Click, function()
				Settings2.Callback(CurrentColor)
				Swatch.BackgroundColor3 = CurrentColor
				SavedConfig[Settings2.Title] = CurrentColor
				Animations:Close(Overlay)
				task.wait(.3); Destroy(Overlay)
			end)
		end)

		return {
			Get = function() return CurrentColor end,
			Set = function(c) CurrentColor = c; Swatch.BackgroundColor3 = c end,
		}
	end

	-- ============================================================
	--  NEW: Value Display (real-time label)
	-- ============================================================
	function Options:AddValueDisplay(Settings2)
		-- Settings2: Title, Default (string/number), Tab
		-- Returns: { Set(value) }
		local Paragraph = Clone(Components["Paragraph"])
		local Title, Description = Options:GetLabels(Paragraph)

		SetProperty(Title,       { Text = Settings2.Title })
		SetProperty(Description, { Text = tostring(Settings2.Default or "—") })
		SetProperty(Paragraph,   { Parent = Settings2.Tab, Visible = true })

		return {
			Set = function(value)
				Description.Text = tostring(value)
			end,
		}
	end

	-- ============================================================
	--  NEW: Player List
	-- ============================================================
	function Options:AddPlayerList(Settings2)
		-- Settings2: Title, Description, Tab, Callback(Player)
		local Button = Clone(Components["Button"])
		local Title, Description = Options:GetLabels(Button)

		SetProperty(Title,       { Text = Settings2.Title or "Player List" })
		SetProperty(Description, { Text = Settings2.Description or "Select a player" })
		SetProperty(Button, { Name = Settings2.Title or "PlayerList", Parent = Settings2.Tab, Visible = true })
		Animations:Component(Button)

		local Players = GetService(game, "Players")

		Connect(Button.MouseButton1Click, function()
			local Overlay, Header = MakeOverlay(Window, "Players")
			Overlay.Size = UDim2.new(0, 260, 0, 320)
			Overlay.Position = UDim2.new(0.5, -130, 0.5, -160)

			local Scroll = Instance.new("ScrollingFrame", Overlay)
			Scroll.Size             = UDim2.new(1, -10, 1, -50)
			Scroll.Position         = UDim2.new(0, 5, 0, 45)
			Scroll.BackgroundTransparency = 1
			Scroll.ScrollBarThickness = 3
			Scroll.ScrollBarImageColor3 = Theme.Component
			Scroll.BorderSizePixel  = 0
			Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			Scroll.CanvasSize       = UDim2.new(0, 0, 0, 0)

			local Layout = Instance.new("UIListLayout", Scroll)
			Layout.SortOrder = Enum.SortOrder.Name
			Layout.Padding   = UDim.new(0, 3)

			local function AddPlayerRow(p)
				local Row = Instance.new("TextButton", Scroll)
				Row.Name             = p.Name
				Row.Size             = UDim2.new(1, -6, 0, 30)
				Row.BackgroundColor3 = Theme.Component
				Row.BorderSizePixel  = 0
				Row.Text             = ""
				Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 4)

				local NameLabel = Instance.new("TextLabel", Row)
				NameLabel.Size            = UDim2.new(1, -36, 1, 0)
				NameLabel.Position        = UDim2.new(0, 36, 0, 0)
				NameLabel.BackgroundTransparency = 1
				NameLabel.Text            = p.Name
				NameLabel.TextColor3      = Theme.Title
				NameLabel.Font            = Enum.Font.Gotham
				NameLabel.TextSize        = 12
				NameLabel.TextXAlignment  = Enum.TextXAlignment.Left

				-- Avatar thumb
				local Icon = Instance.new("ImageLabel", Row)
				Icon.Size             = UDim2.new(0, 24, 0, 24)
				Icon.Position         = UDim2.new(0, 4, 0.5, -12)
				Icon.BackgroundColor3 = Theme.Interactables
				Icon.BorderSizePixel  = 0
				Icon.Image            = ("https://www.roblox.com/headshot-thumbnail/image?userId=" .. p.UserId .. "&width=48&height=48&format=png")
				Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)

				Animations:Component(Row)
				Connect(Row.MouseButton1Click, function()
					Settings2.Callback(p)
					Animations:Close(Overlay)
					task.wait(.3); Destroy(Overlay)
				end)
			end

			for _, p in ipairs(Players:GetPlayers()) do
				AddPlayerRow(p)
			end

			Connect(Players.PlayerAdded,   function(p) AddPlayerRow(p) end)
			Connect(Players.PlayerRemoving, function(p)
				local row = Scroll:FindFirstChild(p.Name)
				if row then Destroy(row) end
			end)
		end)
	end

	-- ============================================================
	--  NEW: Bind Manager (view all keybinds in one place)
	-- ============================================================
	function Options:AddBindManager(Settings2)
		-- Settings2: Title, Description, Tab
		local Button = Clone(Components["Button"])
		local Title, Description = Options:GetLabels(Button)

		SetProperty(Title,       { Text = Settings2.Title or "Bind Manager" })
		SetProperty(Description, { Text = Settings2.Description or "View all keybinds" })
		SetProperty(Button, { Name = "BindManager", Parent = Settings2.Tab, Visible = true })
		Animations:Component(Button)

		Connect(Button.MouseButton1Click, function()
			local Overlay = MakeOverlay(Window, "Bind Manager")
			Overlay.Size     = UDim2.new(0, 300, 0, 380)
			Overlay.Position = UDim2.new(0.5, -150, 0.5, -190)

			local Scroll = Instance.new("ScrollingFrame", Overlay)
			Scroll.Size            = UDim2.new(1, -10, 1, -50)
			Scroll.Position        = UDim2.new(0, 5, 0, 45)
			Scroll.BackgroundTransparency = 1
			Scroll.ScrollBarThickness = 3
			Scroll.ScrollBarImageColor3 = Theme.Component
			Scroll.BorderSizePixel = 0
			Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			Scroll.CanvasSize      = UDim2.new(0, 0, 0, 0)

			local Layout = Instance.new("UIListLayout", Scroll)
			Layout.SortOrder = Enum.SortOrder.LayoutOrder
			Layout.Padding   = UDim.new(0, 4)

			local i = 0
			for bindName, bindValue in next, SavedBinds do
				i = i + 1
				local Row = Instance.new("Frame", Scroll)
				Row.Size            = UDim2.new(1, -6, 0, 28)
				Row.BackgroundColor3 = Theme.Component
				Row.BorderSizePixel = 0
				Row.LayoutOrder     = i
				Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 4)

				local NLabel = Instance.new("TextLabel", Row)
				NLabel.Size    = UDim2.new(0.65, 0, 1, 0)
				NLabel.Position = UDim2.new(0, 8, 0, 0)
				NLabel.BackgroundTransparency = 1
				NLabel.Text    = bindName
				NLabel.TextColor3 = Theme.Title
				NLabel.Font    = Enum.Font.Gotham
				NLabel.TextSize = 12
				NLabel.TextXAlignment = Enum.TextXAlignment.Left

				local BLabel = Instance.new("TextLabel", Row)
				BLabel.Size    = UDim2.new(0.35, -8, 1, 0)
				BLabel.Position = UDim2.new(0.65, 0, 0, 0)
				BLabel.BackgroundTransparency = 1
				BLabel.Text    = tostring(bindValue):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.MouseButton", "MB")
				BLabel.TextColor3 = Theme.Accent
				BLabel.Font    = Enum.Font.GothamBold
				BLabel.TextSize = 12
				BLabel.TextXAlignment = Enum.TextXAlignment.Right
			end

			if i == 0 then
				local Empty = Instance.new("TextLabel", Scroll)
				Empty.Size    = UDim2.new(1, 0, 0, 30)
				Empty.BackgroundTransparency = 1
				Empty.Text    = "No keybinds set yet."
				Empty.TextColor3 = Theme.Description
				Empty.Font    = Enum.Font.Gotham
				Empty.TextSize = 12
			end
		end)
	end

	-- ============================================================
	--  NEW: Config Save / Load
	-- ============================================================
	function Options:SaveConfig(Name)
		if not writefile then
			warn("[UI LIB]: writefile not available in this executor.")
			return
		end
		local data = {}
		for k, v in next, SavedConfig do
			if typeof(v) == "Color3" then
				data[k] = { type = "Color3", r = v.R, g = v.G, b = v.B }
			elseif typeof(v) == "boolean" or typeof(v) == "number" or typeof(v) == "string" then
				data[k] = { type = typeof(v), value = v }
			end
		end

		local encoded = game:GetService("HttpService"):JSONEncode(data)
		local filename = (Name or "UIConfig") .. ".json"
		writefile(filename, encoded)
		Options:Notify({ Title = "Config Saved", Description = filename, Duration = 2 })
	end

	function Options:LoadConfig(Name, ApplyCallbacks)
		-- ApplyCallbacks: { ["Toggle Title"] = callback, ... }
		if not readfile then
			warn("[UI LIB]: readfile not available in this executor.")
			return
		end
		local filename = (Name or "UIConfig") .. ".json"
		local ok, raw = pcall(readfile, filename)
		if not ok then
			Options:Notify({ Title = "Config Error", Description = "File not found: " .. filename, Duration = 3 })
			return
		end
		local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
		if not ok2 then
			Options:Notify({ Title = "Config Error", Description = "Failed to parse config.", Duration = 3 })
			return
		end

		for key, entry in next, data do
			if entry.type == "Color3" then
				SavedConfig[key] = Color3.fromRGB(entry.r * 255, entry.g * 255, entry.b * 255)
			else
				SavedConfig[key] = entry.value
			end
			if ApplyCallbacks and ApplyCallbacks[key] then
				ApplyCallbacks[key](SavedConfig[key])
			end
		end

		Options:Notify({ Title = "Config Loaded", Description = filename, Duration = 2 })
	end

	-- ============================================================
	--  Theme system (unchanged + extended)
	-- ============================================================
	local Themes = {
		Names = {
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark")
				end
			end,
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then Label.TextColor3 = Theme.Title end
			end,
			["Description"] = function(Label)
				if Label:IsA("TextLabel") then Label.TextColor3 = Theme.Description end
			end,
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then Label.TextColor3 = Theme.Title end
			end,
			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					Label.BackgroundColor3 = Theme.Primary
					Label.UIStroke.Color   = Theme.Outline
				end
			end,
			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") then
					Label.TextColor3 = Theme.Tab
				end
			end,
			["Main"] = function(Label)
				if Label:IsA("Frame") then
					if Label.Parent == Window then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value
						if not Toggle.Value then
							Label.BackgroundColor3 = Theme.Interactables
						end
					else
						Label.BackgroundColor3 = Theme.Interactables
					end
				elseif Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Amount"]    = function(Label) if Label:IsA("Frame") then Label.BackgroundColor3 = Theme.Interactables end end,
			["Slide"]     = function(Label) if Label:IsA("Frame") then Label.BackgroundColor3 = Theme.Interactables end end,
			["Input"]     = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Outline"]   = function(Stroke) if Stroke:IsA("UIStroke") then Stroke.Color = Theme.Outline end end,
			["DropdownExample"] = function(Label) Label.BackgroundColor3 = Theme.Secondary end,
			["Underline"] = function(Label) if Label:IsA("Frame") then Label.BackgroundColor3 = Theme.Outline end end,
		},
		Classes = {
			["ImageLabel"]      = function(Label) if Label.Image ~= "rbxassetid://6644618143" then Label.ImageColor3 = Theme.Icon end end,
			["TextLabel"]       = function(Label) if Label:FindFirstChild("Padding") then Label.TextColor3 = Theme.Title end end,
			["TextButton"]      = function(Label) if Label:FindFirstChild("Labels") then Label.BackgroundColor3 = Theme.Component end end,
			["ScrollingFrame"]  = function(Label) Label.ScrollBarImageColor3 = Theme.Component end,
		},
	}

	function Options:SetTheme(Info)
		Theme = Info or Theme
		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color   = Theme.Shadow

		for _, Descendant in next, Screen:GetDescendants() do
			local Name  = Themes.Names[Descendant.Name]
			local Class = Themes.Classes[Descendant.ClassName]
			if Name  then Name(Descendant)  end
			if Class then Class(Descendant) end
		end
	end

	function Options:SetSetting(Setting, Value)
		if Setting == "Size" then
			Window.Size = Value; Setup.Size = Value
		elseif Setting == "Transparency" then
			Window.GroupTransparency = Value; Setup.Transparency = Value
			for _, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = Value
				end
			end
		elseif Setting == "Blur" then
			local Existing = Blurs[Settings.Title]
			if Value then
				BlurEnabled = true
				if not Existing then
					Blurs[Settings.Title] = Blur.new(Window, 5)
				elseif Existing.root and not Existing.root.Parent then
					Existing.root.Parent = workspace.CurrentCamera
				end
			elseif Existing and Existing.root and Existing.root.Parent then
				Existing.root.Parent = nil; BlurEnabled = false
			end
		elseif Setting == "Theme" and typeof(Value) == "table" then
			Options:SetTheme(Value)
		elseif Setting == "Keybind" then
			Setup.Keybind = Value
		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen })
	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end

return Library
