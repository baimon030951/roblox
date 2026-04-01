--[[
    God Weapon v2.0 - WindUI
    Author: TheTorch
    Fixed by: Claude (bug fix - missing Notify strings)
]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "God Weapon", Icon = "sword", Author = "โดย TheTorch",
    Folder = "GodWeaponConfig", Theme = "Dark",
    Resizable = true, Transparent = true, BackgroundImageTransparency = 0.85,
    SideBarWidth = 200, ScrollBarEnabled = true,
    Size = UDim2.fromOffset(640, 500),
    User = { Enabled = true, Anonymous = false },
})
Window:Tag({ Title = "v2.0", Icon = "zap", Color = Color3.fromHex("#00ffcc"), Radius = 6 })

local PVPTab      = Window:Tab({ Title = "ต่อสู้",  Icon = "crosshair"    })
local FarmTab     = Window:Tab({ Title = "ฟาร์ม",   Icon = "briefcase"    })
local TeleportTab = Window:Tab({ Title = "เทเลพอต", Icon = "map-pin"      })
local ActivityTab = Window:Tab({ Title = "กิจกรรม", Icon = "party-popper" })
local CarTab      = Window:Tab({ Title = "รถยนต์",  Icon = "car"          })
local SettingsTab = Window:Tab({ Title = "ตั้งค่า", Icon = "settings"     })

-- ==================== CONFIG ====================
local GUIActive = true

local Keys = { Hitbox = Enum.KeyCode.X, Wheel = Enum.KeyCode.Z }

local Config = {
    ExcludedPlayers  = {},
    TargetingEnabled = false,
    Highlight = { Enabled = true, Color = Color3.fromRGB(0,255,255), Transparency = 0.7 },
    Target    = { Size = Vector3.new(20,20,20), RefreshInterval = 1 },
    Truck     = { Selected = nil },
    AutoArmor = { Enabled = false, KeyNumber = 1 },
    Farm = {
        Settings  = { TeleportDelay=5, TeleportCount=1, CollectAmount=5, FarmMode=1 },
        Grape     = { Enabled=false, Visited={}, TeleportCounter=0, Index=1 },
        Rock      = { Enabled=false, Visited={}, TeleportCounter=0, Index=1 },
        ScrapIron = { Enabled=false, Visited={}, TeleportCounter=0, Index=1 },
        Garbage   = { Enabled=false, Visited={}, TeleportCounter=0, Index=1 },
    },
    Proximity = { Enabled=false, Distance=50 },
}

local CarConfig = {
    ExcludedCars={}, WheelSize=Vector3.new(10,10,10),
    Enabled=false, HighlightEnabled=true,
    HighlightColor=Color3.fromRGB(255,165,0),
    FillTransparency=0.5,
    OutlineTransparency=0,
}

-- ==================== UTILITY ====================

local function Notify(title, text, icon, dur)
    WindUI:Notify({ Title=title, Content=text, Icon=icon or "bell", Duration=dur or 3 })
end

local function GetAllPlayers()
    local t = {}
    for _, p in pairs(game.Players:GetPlayers()) do table.insert(t, p.Name) end
    return t
end

-- ==================== TRUCK ====================

local function ScanPlayerTrucks()
    local player = game.Players.LocalPlayer
    local trucks = {}
    for _, v in pairs(player:GetChildren()) do
        if v:IsA("Model") or v:IsA("Folder") or v:IsA("Tool") then
            local n = v.Name:lower()
            if n:find("truck") or n:find("kg") or n:find("army") or n:find("free") or n:find("car") or n:find("van") then
                table.insert(trucks, v.Name)
            end
        end
    end
    if #trucks == 0 then
        local cache = workspace:FindFirstChild("CachePart")
        if cache then
            for _, v in pairs(cache:GetChildren()) do
                if v.Name:find(player.Name) then table.insert(trucks, v.Name) end
            end
        end
    end
    return trucks
end

local function GetTruck()
    local player = game.Players.LocalPlayer
    if Config.Truck.Selected then
        local t = player:FindFirstChild(Config.Truck.Selected)
        if t then return t end
        local cache = workspace:FindFirstChild("CachePart")
        if cache then
            local ct = cache:FindFirstChild(Config.Truck.Selected)
            if ct then return ct end
        end
    end
    for _, v in pairs(player:GetChildren()) do
        if v:IsA("Model") or v:IsA("Folder") or v:IsA("Tool") then
            local n = v.Name:lower()
            if n:find("truck") or n:find("kg") or n:find("army") or n:find("free") then
                Config.Truck.Selected = v.Name
                return v
            end
        end
    end
    return nil
end

-- ==================== TARGET ====================

local function ApplyTargeting()
    local modified, skipped = 0, 0
    local exclude = {}
    for _, n in pairs(Config.ExcludedPlayers) do exclude[n] = true end
    for _, player in pairs(game.Players:GetPlayers()) do
        if exclude[player.Name] then skipped += 1 continue end
        local model = workspace:FindFirstChild(player.Name)
        if not model then continue end
        local head2 = model:FindFirstChild("Head2")
        if not head2 then continue end
        for _, child in pairs(head2:GetChildren()) do
            if not child.Name:match("^TARGET_") or not child:IsA("BasePart") then continue end
            child.Size = Config.Target.Size
            child.Transparency = Config.Highlight.Transparency
            local hl = child:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", child)
            hl.FillColor=Config.Highlight.Color hl.OutlineColor=Config.Highlight.Color
            hl.FillTransparency=1 hl.OutlineTransparency=0 hl.Enabled=Config.Highlight.Enabled
            local sb = child:FindFirstChildOfClass("SelectionBox")
            if not sb then sb=Instance.new("SelectionBox",child) sb.Adornee=child end
            sb.Color3=Config.Highlight.Color sb.LineThickness=0.05 sb.Transparency=0 sb.Visible=Config.Highlight.Enabled
            modified += 1
        end
    end
    return modified, skipped
end

local function ResetTargeting()
    local count = 0
    for _, player in pairs(game.Players:GetPlayers()) do
        local model = workspace:FindFirstChild(player.Name)
        if not model then continue end
        local head2 = model:FindFirstChild("Head2")
        if not head2 then continue end
        for _, child in pairs(head2:GetChildren()) do
            if not child.Name:match("^TARGET_") or not child:IsA("BasePart") then continue end
            child.Size = Vector3.new(0,0,0)
            local hl = child:FindFirstChildOfClass("Highlight") if hl then hl:Destroy() end
            local sb = child:FindFirstChildOfClass("SelectionBox") if sb then sb:Destroy() end
            count += 1
        end
    end
    return count
end

local function SetTargeting(state)
    Config.TargetingEnabled = state
    if state then
        local m, s = ApplyTargeting()
        Notify("Hitbox ON", ("ปรับ %d | ข้าม %d"):format(m,s), "crosshair", 4)
        task.spawn(function()
            while Config.TargetingEnabled do
                ApplyTargeting()
                task.wait(Config.Target.RefreshInterval)
            end
        end)
    else
        Notify("Hitbox OFF", ("รีเซ็ต %d เป้าหมาย"):format(ResetTargeting()), "x-circle", 4)
    end
end

-- ==================== FARM ====================

local function GetPosKey(pos) return ("%.2f_%.2f_%.2f"):format(pos.X,pos.Y,pos.Z) end
local function CountT(t) local c=0 for _ in pairs(t) do c+=1 end return c end

local function TpJump(cf)
    local char = game.Players.LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return false end
    pcall(function() hrp.CFrame = cf end)
    task.wait(0.1)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.S, false, game)
        task.wait(0.2)
        VIM:SendKeyEvent(false, Enum.KeyCode.S, false, game)
    end)
    return true
end

local function RunFarm(data, folderName, itemName)
    task.spawn(function()
        while data.Enabled do
            local truck = GetTruck()
            if truck then
                pcall(function()
                    game.ReplicatedStorage.Remote.data:FireServer("post", itemName, Config.Farm.Settings.CollectAmount, truck)
                end)
            end
            task.wait(Config.Farm.Settings.TeleportDelay)
        end
    end)
    task.spawn(function()
        while data.Enabled do
            local sc = workspace:FindFirstChild("JOB")
            sc = sc and sc:FindFirstChild("JOB")
            sc = sc and sc:FindFirstChild("SCRIPT")
            local folder = sc and sc:FindFirstChild(folderName)
            if not folder then task.wait(1) continue end
            local items = {}
            for _, g in pairs(folder:GetChildren()) do
                if g:IsA("BasePart") then table.insert(items, g) end
            end
            if #items == 0 then task.wait(1) continue end
            local S = Config.Farm.Settings
            if S.FarmMode == 2 then
                if data.Index > #items then data.Index=1 data.TeleportCounter=0 task.wait(0.5) continue end
                local item = items[data.Index]
                data.TeleportCounter += 1
                if TpJump(item.CFrame) then
                    if data.TeleportCounter >= S.TeleportCount then data.Index+=1 data.TeleportCounter=0 end
                    task.wait(S.TeleportDelay)
                end
            else
                if CountT(data.Visited) >= #items then data.Visited={} task.wait(0.5) end
                local target, key
                for _, g in pairs(folder:GetChildren()) do
                    if not g:IsA("BasePart") then continue end
                    local k = GetPosKey(g.Position)
                    if not data.Visited[k] then target=g key=k break end
                end
                if target then
                    data.TeleportCounter += 1
                    if TpJump(target.CFrame) then
                        if data.TeleportCounter >= S.TeleportCount then data.Visited[key]=true data.TeleportCounter=0 end
                        task.wait(S.TeleportDelay)
                    end
                else
                    data.Visited={} data.TeleportCounter=0 task.wait(0.5)
                end
            end
        end
    end)
end

-- ==================== CAR ====================

local WheelConns = {}

local function ClearConns()
    for _, c in pairs(WheelConns) do c:Disconnect() end
    WheelConns = {}
end

local function GetAllCars()
    local t = {}
    local kc = workspace:FindFirstChild("KeepCar")
    if kc then for _, c in pairs(kc:GetChildren()) do table.insert(t, c.Name) end end
    return t
end

local function ApplyWheels(size)
    local keepCar = workspace:FindFirstChild("KeepCar")
    if not keepCar then Notify("ผิดพลาด","ไม่พบ KeepCar","alert-triangle") return 0 end
    local excl = {}
    for _, n in pairs(CarConfig.ExcludedCars) do excl[n]=true end
    local count = 0
    for _, car in pairs(keepCar:GetChildren()) do
        if excl[car.Name] then continue end
        local chassis = car:FindFirstChild("Chassis")
        if not chassis then continue end
        for _, sn in ipairs({"SuspensionFL","SuspensionFR","SuspensionRL","SuspensionRR"}) do
            local susp = chassis:FindFirstChild(sn)
            if not susp then continue end
            local wheel = susp:FindFirstChild("Wheel")
            if not wheel then
                for _, d in pairs(susp:GetDescendants()) do
                    if d:IsA("BasePart") then wheel=d break end
                end
            end
            if not wheel then continue end
            pcall(function() wheel.Size = size end)
            for _, old in pairs(wheel:GetChildren()) do
                if old:IsA("Highlight") or old:IsA("SelectionBox") then old:Destroy() end
            end
            if CarConfig.HighlightEnabled then
                local hl = Instance.new("Highlight")
                hl.Adornee=wheel hl.FillColor=CarConfig.HighlightColor hl.OutlineColor=CarConfig.HighlightColor
                hl.FillTransparency=CarConfig.FillTransparency hl.OutlineTransparency=CarConfig.OutlineTransparency
                hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Enabled=true hl.Parent=wheel
                local sb = Instance.new("SelectionBox")
                sb.Adornee=wheel sb.Color3=CarConfig.HighlightColor
                sb.LineThickness=0.05 sb.Transparency=0 sb.Visible=true sb.Parent=wheel
            end
            count += 1
        end
    end
    if count == 0 then Notify("คำเตือน","ไม่พบล้อในรถ","alert-triangle") end
    return count
end

local function ResetWheels()
    local keepCar = workspace:FindFirstChild("KeepCar")
    if not keepCar then return end
    for _, car in pairs(keepCar:GetChildren()) do
        local chassis = car:FindFirstChild("Chassis")
        if not chassis then continue end
        for _, sn in ipairs({"SuspensionFL","SuspensionFR","SuspensionRL","SuspensionRR"}) do
            local susp = chassis:FindFirstChild(sn)
            if not susp then continue end
            local wheel = susp:FindFirstChild("Wheel")
            if not wheel then
                for _, d in pairs(susp:GetDescendants()) do
                    if d:IsA("BasePart") then wheel=d break end
                end
            end
            if not wheel then continue end
            pcall(function() wheel.Size = Vector3.new(3,3,3) end)
            for _, old in pairs(wheel:GetChildren()) do
                if old:IsA("Highlight") or old:IsA("SelectionBox") then old:Destroy() end
            end
        end
    end
end

local function HookWheels(size)
    ClearConns()
    local keepCar = workspace:FindFirstChild("KeepCar")
    if not keepCar then return end
    local excl = {}
    for _, n in pairs(CarConfig.ExcludedCars) do excl[n]=true end
    for _, car in pairs(keepCar:GetChildren()) do
        if excl[car.Name] then continue end
        local chassis = car:FindFirstChild("Chassis")
        if not chassis then continue end
        for _, sn in ipairs({"SuspensionFL","SuspensionFR","SuspensionRL","SuspensionRR"}) do
            local susp = chassis:FindFirstChild(sn)
            if not susp then continue end
            local wheel = susp:FindFirstChild("Wheel")
            if not wheel then
                for _, d in pairs(susp:GetDescendants()) do
                    if d:IsA("BasePart") then wheel=d break end
                end
            end
            if not wheel then continue end
            table.insert(WheelConns, wheel:GetPropertyChangedSignal("Size"):Connect(function()
                if CarConfig.Enabled and wheel.Size ~= size then
                    pcall(function() wheel.Size = size end)
                end
            end))
        end
    end
end

local function SetWheels(state)
    CarConfig.Enabled = state
    if state then
        local count = ApplyWheels(CarConfig.WheelSize)
        HookWheels(CarConfig.WheelSize)
        Notify("ล้อรถ ON", ("ขยายยาง %d ล้อ"):format(count), "car", 4)
    else
        ClearConns() ResetWheels()
        Notify("ล้อรถ OFF", "รีเซ็ตขนาดยางแล้ว", "car", 4)
    end
end

-- ==================== TELEPORT ====================

local SavedCF = nil

local function TpTo(cf)
    local char = game.Players.LocalPlayer.Character
    if not char then Notify("ผิดพลาด","ไม่พบตัวละคร","alert-triangle") return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then Notify("ผิดพลาด","ไม่พบ HumanoidRootPart","alert-triangle") return end
    pcall(function() hrp.CFrame = cf end)
end

-- ==================== KEYBIND (single listener) ====================

game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe or not GUIActive then return end
    if input.KeyCode == Keys.Hitbox then
        local newState = not Config.TargetingEnabled
        SetTargeting(newState)
        if HitboxToggle then HitboxToggle:Set(newState) end
    elseif input.KeyCode == Keys.Wheel then
        local newState = not CarConfig.Enabled
        SetWheels(newState)
        if WheelToggle then WheelToggle:Set(newState) end
    end
end)

-- ╔══════════════╗
-- ║  TAB: ต่อสู้  ║
-- ╚══════════════╝

PVPTab:Section({ Title = "🎯 ระบบเล็ง" })

local playerDD = PVPTab:Dropdown({
    Title="ยกเว้นผู้เล่น", Desc="ไม่ถูกปรับ Hitbox",
    Values=GetAllPlayers(), Multi=true, AllowNone=true,
    Callback=function(v)
        Config.ExcludedPlayers=v
        if Config.TargetingEnabled then ApplyTargeting() end
    end,
})

PVPTab:Space()
PVPTab:Button({
    Title="รีเฟรชรายชื่อ", Icon="refresh-cw",
    Callback=function() playerDD:Refresh(GetAllPlayers()) end,
})
PVPTab:Space()
PVPTab:Input({
    Title="ขนาด Hitbox (X,Y,Z)", Desc="เช่น 20,20,20",
    Value="20,20,20", Placeholder="20,20,20",
    Callback=function(v)
        local vals={}
        for n in v:gmatch("[^,]+") do local num=tonumber(n) if num then table.insert(vals,num) end end
        if #vals==3 then
            Config.Target.Size=Vector3.new(vals[1],vals[2],vals[3])
            if Config.TargetingEnabled then ApplyTargeting() end
        else Notify("ผิดพลาด","ใช้รูปแบบ X,Y,Z","alert-triangle") end
    end,
})
PVPTab:Input({
    Title="รีเฟรชทุก (วิ)", Value="1", Placeholder="1",
    Callback=function(v)
        local n=tonumber(v)
        if n and n>0 then Config.Target.RefreshInterval=n end
    end,
})
PVPTab:Space()
PVPTab:Keybind({
    Title="ปุ่ม Toggle Hitbox", Desc="กดเพื่อเปิด/ปิด Hitbox", Value="X",
    Callback=function(v)
        local ok,kc=pcall(function() return Enum.KeyCode[v] end)
        if ok and kc then Keys.Hitbox=kc end
    end,
})
PVPTab:Space()
local HitboxToggle = PVPTab:Toggle({
    Title="เปิดปรับเป้าหมาย", Desc="เปิด=ขยาย | ปิด=รีเซ็ต", Value=false,
    Callback=function(state) SetTargeting(state) end,
})
PVPTab:Space()
PVPTab:Button({
    Title="บังคับอัพเดท", Icon="zap",
    Callback=function()
        if not Config.TargetingEnabled then Notify("คำเตือน","เปิด toggle ก่อน!","alert-triangle") return end
        local m,s=ApplyTargeting()
        Notify("อัพเดทแล้ว", ("ปรับ %d | ข้าม %d"):format(m,s), "zap", 5)
    end,
})

PVPTab:Section({ Title = "🎨 การตั้งค่าภาพ" })
PVPTab:Toggle({
    Title="เปิดไฮไลท์", Value=true,
    Callback=function(state)
        Config.Highlight.Enabled=state
        if Config.TargetingEnabled then ApplyTargeting() end
    end,
})
PVPTab:Space()
PVPTab:Slider({
    Title="ความโปร่งใส", Desc="0=ทึบ / 1=ใส", Step=0.01,
    Value={Min=0, Max=1, Default=0.7},
    Callback=function(v)
        Config.Highlight.Transparency=v
        if Config.TargetingEnabled then ApplyTargeting() end
    end,
})
PVPTab:Space()
PVPTab:Colorpicker({
    Title="สีไฮไลท์", Default=Color3.fromRGB(0,255,255),
    Callback=function(c)
        Config.Highlight.Color=c
        if Config.TargetingEnabled then ApplyTargeting() end
    end,
})

PVPTab:Section({ Title = "🛡️ เกราะอัตโนมัติ" })
PVPTab:Input({
    Title="ปุ่มเกราะ (1-8)", Value="1", Placeholder="1",
    Callback=function(v)
        local n=tonumber(v)
        if n and n>=1 and n<=8 then Config.AutoArmor.KeyNumber=math.floor(n) end
    end,
})
PVPTab:Space()

local function CheckArmor()
    local model=workspace:FindFirstChild(game.Players.LocalPlayer.Name)
    if not model or model:FindFirstChild("BodyArmor") then return end
    local keyMap={
        Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,
        Enum.KeyCode.Five,Enum.KeyCode.Six,Enum.KeyCode.Seven,Enum.KeyCode.Eight,
    }
    local kc=keyMap[Config.AutoArmor.KeyNumber]
    if not kc then return end
    pcall(function()
        local VIM=game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true,kc,false,game) task.wait(0.1) VIM:SendKeyEvent(false,kc,false,game)
    end)
end

PVPTab:Toggle({
    Title="สวมเกราะอัตโนมัติ", Desc="สวมเมื่อไม่มี BodyArmor", Value=false,
    Callback=function(state)
        Config.AutoArmor.Enabled=state
        if state then
            task.spawn(function() while Config.AutoArmor.Enabled do CheckArmor() task.wait(1) end end)
        end
    end,
})

-- ╔══════════════╗
-- ║  TAB: ฟาร์ม  ║
-- ╚══════════════╝

FarmTab:Section({ Title = "🚛 รถบรรทุก" })

local truckDD = FarmTab:Dropdown({
    Title="เลือกรถบรรทุก", Values={}, AllowNone=false,
    Callback=function(v) Config.Truck.Selected=v end,
})
FarmTab:Space()
FarmTab:Button({
    Title="สแกนรถของฉัน", Icon="search",
    Callback=function()
        local trucks=ScanPlayerTrucks()
        if #trucks>0 then
            truckDD:Refresh(trucks)
            if not Config.Truck.Selected then Config.Truck.Selected=trucks[1] truckDD:Set(trucks[1]) end
            Notify("พบรถ", ("พบ %d คัน"):format(#trucks), "truck")
        else
            local all={}
            for _,v in pairs(game.Players.LocalPlayer:GetChildren()) do
                if v:IsA("Model") or v:IsA("Folder") then table.insert(all,v.Name) end
            end
            if #all>0 then truckDD:Refresh(all)
            else Notify("ไม่พบรถ","ไม่พบรถ","alert-triangle") end
        end
    end,
})

FarmTab:Section({ Title = "⚙️ ตั้งค่าฟาร์ม (ทุกฟาร์ม)" })
FarmTab:Dropdown({
    Title="โหมดฟาร์ม",
    Values={"โหมด 1 - วาปซ้ำได้","โหมด 2 - ไม่ซ้ำเรื่อยๆ"},
    Value="โหมด 1 - วาปซ้ำได้", AllowNone=false,
    Callback=function(v) Config.Farm.Settings.FarmMode=(v=="โหมด 1 - วาปซ้ำได้") and 1 or 2 end,
})
FarmTab:Space()
FarmTab:Input({ Title="ดีเลวาป (วิ)", Value="5", Placeholder="5",
    Callback=function(v) local n=tonumber(v) if n and n>0 then Config.Farm.Settings.TeleportDelay=n end end })
FarmTab:Input({ Title="วาปกี่ครั้งจึงเก็บ", Value="1", Placeholder="1",
    Callback=function(v) local n=tonumber(v) if n and n>=1 then Config.Farm.Settings.TeleportCount=math.floor(n) end end })
FarmTab:Input({ Title="จำนวนที่เก็บต่อครั้ง", Value="5", Placeholder="5",
    Callback=function(v) local n=tonumber(v) if n and n>=1 then Config.Farm.Settings.CollectAmount=math.floor(n) end end })

local farms = {
    { t="🍇 ฟาร์มองุ่น", d=Config.Farm.Grape,     f="Grape",     i="Grape"     },
    { t="🪨 ฟาร์มหิน",   d=Config.Farm.Rock,      f="Miner",     i="Rock"      },
    { t="⚙️ ฟาร์มเหล็ก", d=Config.Farm.ScrapIron, f="ScrapIron", i="ScrapIron" },
    { t="🗑️ ฟาร์มขยะ",   d=Config.Farm.Garbage,   f="Garbage",   i="Garbage"   },
}

local function StopAllFarms(reason)
    local stopped = false
    for _, fm in ipairs(farms) do
        if fm.d.Enabled then
            fm.d.Enabled = false
            stopped = true
        end
    end
    if stopped then
        Notify("⚠️ หยุดฟาร์ม", reason or "มีผู้เล่นเข้าใกล้!", "alert-triangle", 5)
    end
end

for _, fm in ipairs(farms) do
    FarmTab:Section({ Title = fm.t })
    FarmTab:Toggle({
        Title=fm.t.."อัตโนมัติ", Desc="วาปเก็บแล้วส่งรถ", Value=false,
        Callback=function(state)
            fm.d.Enabled=state
            if state then RunFarm(fm.d,fm.f,fm.i) end
        end,
    })
end

-- ── ระบบตรวจจับผู้เล่นใกล้เคียง ──
FarmTab:Section({ Title = "🔍 ตรวจจับผู้เล่น" })

FarmTab:Toggle({
    Title = "หยุดฟาร์มเมื่อมีคนใกล้",
    Desc  = "ปิดฟาร์มทุกตัวอัตโนมัติเมื่อมีผู้เล่นเข้าใกล้",
    Value = false,
    Callback = function(state)
        Config.Proximity.Enabled = state
        if state then
            Notify("เปิดตรวจจับ", ("รัศมี %d studs"):format(Config.Proximity.Distance), "eye")
            task.spawn(function()
                while Config.Proximity.Enabled do
                    local me = game.Players.LocalPlayer
                    local myChar = me.Character
                    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        for _, player in pairs(game.Players:GetPlayers()) do
                            if player == me then continue end
                            local theirChar = player.Character
                            local theirHRP = theirChar and theirChar:FindFirstChild("HumanoidRootPart")
                            if theirHRP then
                                local dist = (myHRP.Position - theirHRP.Position).Magnitude
                                if dist <= Config.Proximity.Distance then
                                    StopAllFarms(player.Name.." เข้าใกล้! ("..math.floor(dist).." studs)")
                                    break
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

FarmTab:Space()

FarmTab:Slider({
    Title = "รัศมีตรวจจับ (studs)",
    Desc  = "ระยะที่ถือว่า 'ใกล้เคียง'",
    Step  = 5,
    Value = { Min = 10, Max = 200, Default = 50 },
    Callback = function(v)
        Config.Proximity.Distance = v
    end,
})

-- ╔══════════════════╗
-- ║  TAB: เทเลพอต   ║
-- ╚══════════════════╝

TeleportTab:Section({ Title = "📍 เซฟตำแหน่ง" })
TeleportTab:Button({
    Title="เซฟตำแหน่งปัจจุบัน", Icon="bookmark",
    Callback=function()
        local hrp=game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then Notify("ผิดพลาด","ไม่พบตัวละคร","alert-triangle") return end
        SavedCF=hrp.CFrame
        local p=SavedCF.Position
        Notify("เซฟสำเร็จ",("X:%.1f Y:%.1f Z:%.1f"):format(p.X,p.Y,p.Z),"bookmark",4)
    end,
})
TeleportTab:Space()
TeleportTab:Button({
    Title="วาปกลับตำแหน่งที่เซฟ", Icon="corner-down-left",
    Callback=function()
        if not SavedCF then Notify("ผิดพลาด","ยังไม่ได้เซฟ!","alert-triangle") return end
        TpTo(SavedCF)
        local p=SavedCF.Position
        Notify("วาปกลับแล้ว",("X:%.1f Y:%.1f Z:%.1f"):format(p.X,p.Y,p.Z),"corner-down-left",4)
    end,
})

TeleportTab:Section({ Title = "🗺️ จุดหมาย" })
local Dests = {
    { t="การาช",    i="car",      cf=CFrame.new(303.565521,66.1486893,-906.82373,0.767768562,6.71885871e-08,-0.640727282,-5.10625604e-08,1,4.36759322e-08,0.640727282,-8.15832679e-10,0.767768562) },
    { t="เลเบลฟ้า", i="map-pin",  cf=CFrame.new(-900.60968,88.9132462,1224.23682,-0.907460213,-1.95295904e-08,-0.420138031,-9.32648447e-09,1,-2.63393822e-08,0.420138031,-1.99835295e-08,-0.907460213) },
    { t="สภา",      i="landmark", cf=CFrame.new(5547.8877,683.3078,1496.87927,-0.267395705,1.94510399e-08,0.963586807,5.54390418e-08,1,-4.80172435e-09,-0.963586807,5.21363681e-08,-0.267395705) },
    { t="เลเบลแดง", i="map-pin",  cf=CFrame.new(6889.5166,285.729034,-2287.85767,-0.0161244199,1.21794734e-08,0.999870002,-4.29730243e-08,1,-1.28740627e-08,-0.999870002,-4.31750244e-08,-0.0161244199) },
    { t="ปั้มบนสุด", i="fuel",     cf=CFrame.new(7985.23975,264.948853,-781.145386,-0.745238066,-4.59924507e-08,-0.666798472,-1.86272047e-08,1,-4.81566005e-08,0.666798472,-2.3467539e-08,-0.745238066) },
}
for k, d in ipairs(Dests) do
    TeleportTab:Button({
        Title="วาปไป"..d.t, Icon=d.i,
        Callback=function() TpTo(d.cf) end,
    })
    if k < #Dests then TeleportTab:Space() end
end

-- ╔══════════════════╗
-- ║  TAB: กิจกรรม   ║
-- ╚══════════════════╝

ActivityTab:Section({ Title = "🎉 วาปไปกิจกรรม" })
ActivityTab:Button({
    Title="วาปไปชนะปากัว", Icon="swords",
    Callback=function()
        TpTo(CFrame.new(-694.090698,188.338425,571.563782,0.0845197961,-4.88692606e-08,-0.996421814,3.67553454e-08,1,-4.59270417e-08,0.996421814,-3.27420828e-08,0.0845197961))
    end,
})
ActivityTab:Space()
ActivityTab:Button({
    Title="วาปไปลักกี้บอม", Icon="bomb",
    Callback=function()
        TpTo(CFrame.new(-391.9711,66.0340271,578.966553,-0.0431948975,-4.21879598e-09,-0.999066651,8.60502336e-09,1,-4.59477745e-09,0.999066651,-8.79546302e-09,-0.0431948975))
    end,
})

-- ╔══════════════╗
-- ║  TAB: รถยนต์  ║
-- ╚══════════════╝

CarTab:Section({ Title = "🚗 ยกเว้นรถ" })
local carDD = CarTab:Dropdown({
    Title="ยกเว้นรถ", Desc="ไม่ขยายยางรถที่เลือก",
    Values=GetAllCars(), Multi=true, AllowNone=true,
    Callback=function(v)
        CarConfig.ExcludedCars=v
        if CarConfig.Enabled then ApplyWheels(CarConfig.WheelSize) end
    end,
})
CarTab:Space()
CarTab:Button({
    Title="รีเฟรชรายชื่อรถ", Icon="refresh-cw",
    Callback=function() carDD:Refresh(GetAllCars()) end,
})

CarTab:Section({ Title = "📐 ขนาดยาง" })
CarTab:Input({
    Title="ขนาดยาง (X,Y,Z)", Desc="เช่น 10,10,10", Value="10,10,10", Placeholder="10,10,10",
    Callback=function(v)
        local vals={}
        for n in v:gmatch("[^,]+") do local num=tonumber(n) if num then table.insert(vals,num) end end
        if #vals==3 then
            CarConfig.WheelSize=Vector3.new(vals[1],vals[2],vals[3])
            if CarConfig.Enabled then ApplyWheels(CarConfig.WheelSize) HookWheels(CarConfig.WheelSize) end
        else Notify("ผิดพลาด","ใช้รูปแบบ X,Y,Z","alert-triangle") end
    end,
})

-- ==================== CAR ESP ====================

local CarESP = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    BillboardConns = {},
    Boards = {},
}

local function ClearCarESP()
    for _, bb in pairs(CarESP.Boards) do
        pcall(function() bb:Destroy() end)
    end
    CarESP.Boards = {}
end

local function ApplyCarESP()
    ClearCarESP()
    local keepCar = workspace:FindFirstChild("KeepCar")
    if not keepCar then return end
    for _, car in pairs(keepCar:GetChildren()) do
        -- หา BasePart ที่เป็น root ของรถ (PrimaryPart หรือ part แรก)
        local root = car:IsA("Model") and (car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart"))
        if not root then
            -- อาจเป็น Folder/BasePart โดยตรง
            for _, d in pairs(car:GetDescendants()) do
                if d:IsA("BasePart") then root = d break end
            end
        end
        if not root then continue end

        local bb = Instance.new("BillboardGui")
        bb.Name = "CarESP_" .. car.Name
        bb.Adornee = root
        bb.Size = UDim2.new(0, 200, 0, 40)
        bb.StudsOffset = Vector3.new(0, 5, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.Parent = root

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = car.Name
        label.TextColor3 = CarESP.Color
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = bb

        table.insert(CarESP.Boards, bb)
    end
    return #CarESP.Boards
end

local function SetCarESP(state)
    CarESP.Enabled = state
    if state then
        local count = ApplyCarESP()
        Notify("ESP รถ ON", ("แสดงชื่อ %d คัน"):format(count or 0), "eye", 4)
    else
        ClearCarESP()
        Notify("ESP รถ OFF", "ซ่อนชื่อรถแล้ว", "eye-off", 3)
    end
end

CarTab:Section({ Title = "👁️ การมองเห็น" })

CarTab:Toggle({
    Title="ESP ชื่อรถ", Desc="แสดงชื่อรถลอยเหนือคัน", Value=false,
    Callback=function(state) SetCarESP(state) end,
})
CarTab:Space()
CarTab:Colorpicker({
    Title="สี ESP ชื่อรถ", Default=Color3.fromRGB(255,255,255),
    Callback=function(c)
        CarESP.Color = c
        -- อัพเดทสีทันทีถ้าเปิดอยู่
        if CarESP.Enabled then
            for _, bb in pairs(CarESP.Boards) do
                local lbl = bb:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.TextColor3 = c end
            end
        end
    end,
})
CarTab:Space()
CarTab:Button({
    Title="รีเฟรช ESP ชื่อรถ", Icon="refresh-cw",
    Callback=function()
        if not CarESP.Enabled then Notify("คำเตือน","เปิด ESP ก่อน!","alert-triangle") return end
        local count = ApplyCarESP()
        Notify("รีเฟรชแล้ว", ("แสดง %d คัน"):format(count or 0), "refresh-cw", 3)
    end,
})
CarTab:Space()

CarTab:Toggle({
    Title="เปิดไฮไลท์ล้อ", Value=true,
    Callback=function(state)
        CarConfig.HighlightEnabled=state
        if CarConfig.Enabled then ApplyWheels(CarConfig.WheelSize) end
    end,
})
CarTab:Space()
CarTab:Colorpicker({
    Title="สีไฮไลท์ล้อ", Default=Color3.fromRGB(255,165,0),
    Callback=function(c)
        CarConfig.HighlightColor=c
        if CarConfig.Enabled then ApplyWheels(CarConfig.WheelSize) end
    end,
})
CarTab:Space()
CarTab:Section({ Title = "🔧 ควบคุม" })
CarTab:Keybind({
    Title="ปุ่ม Toggle ล้อรถ", Desc="กดเพื่อเปิด/ปิดขยายล้อ", Value="Z",
    Callback=function(v)
        local ok,kc=pcall(function() return Enum.KeyCode[v] end)
        if ok and kc then Keys.Wheel=kc end
    end,
})
CarTab:Space()
local WheelToggle = CarTab:Toggle({
    Title="เปิดขยายยางรถ", Desc="เปิด=ขยาย | ปิด=รีเซ็ต", Value=false,
    Callback=function(state) SetWheels(state) end,
})
CarTab:Space()
CarTab:Button({
    Title="บังคับอัพเดทยาง", Icon="zap",
    Callback=function()
        if not CarConfig.Enabled then Notify("คำเตือน","เปิด toggle ก่อน!","alert-triangle") return end
        local count=ApplyWheels(CarConfig.WheelSize)
        HookWheels(CarConfig.WheelSize)
        Notify("อัพเดทยางแล้ว", ("ขยาย %d ล้อ"):format(count), "zap", 5)
    end,
})

-- ╔══════════════════╗
-- ║  TAB: ตั้งค่า    ║
-- ╚══════════════════╝

SettingsTab:Section({ Title = "🖥️ การตั้งค่า UI" })
SettingsTab:Keybind({
    Title="ปุ่มเปิด/ปิด UI", Desc="กดปุ่มที่ต้องการ", Value="RightControl",
    Callback=function(v)
        local ok,kc=pcall(function() return Enum.KeyCode[v] end)
        if ok and kc then Window:SetToggleKey(kc) end
    end,
})

SettingsTab:Section({ Title = "⚠️ อื่นๆ" })
SettingsTab:Button({
    Title="ปิด GUI", Icon="x-circle",
    Callback=function()
        local dialog=Window:Dialog({
            Icon="alert-triangle", Title="ยืนยันการปิด",
            Content="ต้องการปิด God Weapon จริงหรือไม่?",
            Buttons={
                { Title="ปิดเลย", Icon="x", Variant="Primary",
                  Callback=function() GUIActive=false Window:Destroy() end },
                { Title="ยกเลิก", Icon="arrow-left", Variant="Tertiary", Callback=function() end },
            },
        })
        dialog:Show()
    end,
})

print("[GodWeapon v2.0] โหลดสำเร็จ")
