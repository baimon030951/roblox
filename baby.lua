local UI_URL = "https://raw.githubusercontent.com/patdanai-t/VertexUI/refs/heads/main/VertexUI.lua"
local Vertex = loadstring(game:HttpGet(UI_URL))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local window = Vertex:CreateWindow({
    Name = "GodWeapon",
    Title = "Vertex Hub",
    SecondaryBadge = "God Weapon",
    Version = "v2.0",
    ToggleKey = "RightControl",
    ConfigFolder = "GodWeaponConfig",
    LoadingDuration = 1.5
})

if window.Backdrop then
    window.Backdrop.BackgroundTransparency = 0.55
end

local GUIActive = true
local uiReady = false

local Config = {
    ExcludedPlayer = "None",
    TargetingEnabled = false,
    Highlight = {
        Enabled = true,
        Color = Color3.fromRGB(0, 255, 255),
        Transparency = 0.7
    },
    Target = {
        Size = Vector3.new(20, 20, 20),
        RefreshInterval = 1
    },
    Truck = {
        Selected = nil,
        AutoCollectEnabled = false,
        CollectItemName = "blueshard"
    },
    AutoArmor = {
        Enabled = false,
        KeyNumber = 1
    },
    Farm = {
        Settings = {
            TeleportDelay = 5,
            TeleportCount = 1,
            CollectAmount = 5,
            FarmMode = 1
        },
        Grape = {Enabled = false, Visited = {}, TeleportCounter = 0, Index = 1},
        Rock = {Enabled = false, Visited = {}, TeleportCounter = 0, Index = 1},
        ScrapIron = {Enabled = false, Visited = {}, TeleportCounter = 0, Index = 1},
        Garbage = {Enabled = false, Visited = {}, TeleportCounter = 0, Index = 1}
    },
    Proximity = {
        Enabled = false,
        Distance = 50
    }
}

local CarConfig = {
    ExcludedCar = "None",
    WheelSize = Vector3.new(10, 10, 10),
    Enabled = false,
    HighlightEnabled = true,
    HighlightColor = Color3.fromRGB(255, 165, 0),
    FillTransparency = 0.5,
    OutlineTransparency = 0
}

local CarESP = {
    Enabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    Boards = {}
}

local SavedCF = nil
local WheelConns = {}
local HitboxToggle
local WheelToggle
local uiToggleKeybind
local farmToggleRefs = {}

local function resolveNotifyType(icon, title)
    local text = (tostring(icon or "") .. " " .. tostring(title or "")):lower()
    if text:find("alert") or text:find("warning") or text:find("off") then
        return "warning"
    end
    if text:find("error") or text:find("x%-circle") or text:find("fail") then
        return "error"
    end
    if text:find("success") or text:find("on") or text:find("refresh") or text:find("zap") then
        return "success"
    end
    return "info"
end

local function Notify(title, text, icon, dur)
    window:Notify({
        Title = title,
        Description = text,
        Type = resolveNotifyType(icon, title),
        Duration = dur or 3
    })
end

local function GetAllPlayers()
    local list = {"None"}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    table.sort(list, function(a, b)
        if a == "None" then
            return true
        end
        if b == "None" then
            return false
        end
        return a < b
    end)
    return list
end

local function GetAllCars()
    local list = {"None"}
    local keepCar = workspace:FindFirstChild("KeepCar")
    if keepCar then
        for _, car in ipairs(keepCar:GetChildren()) do
            table.insert(list, car.Name)
        end
    end
    table.sort(list, function(a, b)
        if a == "None" then
            return true
        end
        if b == "None" then
            return false
        end
        return a < b
    end)
    return list
end

local function ScanPlayerTrucks()
    local trucks = {}
    local cache = workspace:FindFirstChild("CachePart")
    if cache then
        local prefix = LocalPlayer.Name
        for _, child in ipairs(cache:GetChildren()) do
            if string.sub(child.Name, 1, #prefix) == prefix then
                table.insert(trucks, child.Name)
            end
        end
    end

    table.sort(trucks)
    return trucks
end

local function GetPlayerTruckObjectName(selectedName)
    if not selectedName or selectedName == "None" then
        return nil
    end

    local prefix = LocalPlayer.Name
    if string.sub(selectedName, 1, #prefix) == prefix then
        local trimmed = string.sub(selectedName, #prefix + 1)
        if trimmed ~= "" then
            return trimmed
        end
    end

    return selectedName
end

local function GetTruck()
    if Config.Truck.Selected then
        local playerTruckName = GetPlayerTruckObjectName(Config.Truck.Selected)
        if playerTruckName then
            local directTruck = LocalPlayer:FindFirstChild(playerTruckName)
            if directTruck then
                return directTruck
            end
        end

        local cache = workspace:FindFirstChild("CachePart")
        if cache then
            local cacheTruck = cache:FindFirstChild(Config.Truck.Selected)
            if cacheTruck then
                return cacheTruck
            end
        end
    end

    local cache = workspace:FindFirstChild("CachePart")
    if cache then
        local prefix = LocalPlayer.Name
        for _, child in ipairs(cache:GetChildren()) do
            if string.sub(child.Name, 1, #prefix) == prefix then
                Config.Truck.Selected = child.Name
                return child
            end
        end
    end

    return nil
end

local function ResolveTruckCollectItem()
    if Config.Farm.Grape.Enabled then
        return "Grape"
    end
    if Config.Farm.Rock.Enabled then
        return "Rock"
    end
    if Config.Farm.ScrapIron.Enabled then
        return "ScrapIron"
    end
    if Config.Farm.Garbage.Enabled then
        return "Garbage"
    end
    return Config.Truck.CollectItemName
end

local function SetTruckAutoCollect(state)
    Config.Truck.AutoCollectEnabled = state
    if state then
        task.spawn(function()
            while Config.Truck.AutoCollectEnabled do
                local truck = GetTruck()
                local itemName = ResolveTruckCollectItem()
                if truck then
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("data"):FireServer(
                            "post",
                            itemName,
                            1,
                            truck
                        )
                    end)
                end
                task.wait(1)
            end
        end)

        if uiReady then
            Notify("Truck", "เปิดเก็บของหลังรถแล้ว", "success", 3)
        end
    else
        if uiReady then
            Notify("Truck", "ปิดเก็บของหลังรถแล้ว", "warning", 3)
        end
    end
end

local function ApplyTargeting()
    local modified, skipped = 0, 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end

        if Config.ExcludedPlayer ~= "None" and player.Name == Config.ExcludedPlayer then
            skipped += 1
            continue
        end

        local model = workspace:FindFirstChild(player.Name)
        if not model then
            continue
        end

        local head2 = model:FindFirstChild("Head2")
        if not head2 then
            continue
        end

        for _, child in ipairs(head2:GetChildren()) do
            if not child:IsA("BasePart") or not child.Name:match("^TARGET_") then
                continue
            end

            child.Size = Config.Target.Size
            child.Transparency = Config.Highlight.Transparency

            local highlight = child:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
            highlight.FillColor = Config.Highlight.Color
            highlight.OutlineColor = Config.Highlight.Color
            highlight.FillTransparency = 1
            highlight.OutlineTransparency = 0
            highlight.Enabled = Config.Highlight.Enabled
            highlight.Parent = child

            local selectionBox = child:FindFirstChildOfClass("SelectionBox") or Instance.new("SelectionBox")
            selectionBox.Adornee = child
            selectionBox.Color3 = Config.Highlight.Color
            selectionBox.LineThickness = 0.05
            selectionBox.Transparency = 0
            selectionBox.Visible = Config.Highlight.Enabled
            selectionBox.Parent = child

            modified += 1
        end
    end

    return modified, skipped
end

local function ResetTargeting()
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        local model = workspace:FindFirstChild(player.Name)
        if not model then
            continue
        end

        local head2 = model:FindFirstChild("Head2")
        if not head2 then
            continue
        end

        for _, child in ipairs(head2:GetChildren()) do
            if not child:IsA("BasePart") or not child.Name:match("^TARGET_") then
                continue
            end

            child.Size = Vector3.zero

            local highlight = child:FindFirstChildOfClass("Highlight")
            if highlight then
                highlight:Destroy()
            end

            local selectionBox = child:FindFirstChildOfClass("SelectionBox")
            if selectionBox then
                selectionBox:Destroy()
            end

            count += 1
        end
    end

    return count
end

local function SetTargeting(state)
    Config.TargetingEnabled = state
    if state then
        local modified, skipped = ApplyTargeting()
        if uiReady then
            Notify("Hitbox ON", ("ปรับ %d | ข้าม %d"):format(modified, skipped), "success", 4)
        end

        task.spawn(function()
            while Config.TargetingEnabled do
                ApplyTargeting()
                task.wait(Config.Target.RefreshInterval)
            end
        end)
    else
        local count = ResetTargeting()
        if uiReady then
            Notify("Hitbox OFF", ("รีเซ็ต %d เป้าหมาย"):format(count), "warning", 4)
        end
    end
end

local function GetPosKey(pos)
    return ("%.2f_%.2f_%.2f"):format(pos.X, pos.Y, pos.Z)
end

local function CountT(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count += 1
    end
    return count
end

local function TpJump(cf)
    local character = LocalPlayer.Character
    if not character then
        return false
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then
        return false
    end

    pcall(function()
        hrp.CFrame = cf
    end)
    task.wait(0.1)

    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.S, false, game)
        task.wait(0.2)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.S, false, game)
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
            local scriptRoot = workspace:FindFirstChild("JOB")
            scriptRoot = scriptRoot and scriptRoot:FindFirstChild("JOB")
            scriptRoot = scriptRoot and scriptRoot:FindFirstChild("SCRIPT")
            local folder = scriptRoot and scriptRoot:FindFirstChild(folderName)
            if not folder then
                task.wait(1)
                continue
            end

            local items = {}
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("BasePart") then
                    table.insert(items, child)
                end
            end

            if #items == 0 then
                task.wait(1)
                continue
            end

            local settings = Config.Farm.Settings
            if settings.FarmMode == 2 then
                if data.Index > #items then
                    data.Index = 1
                    data.TeleportCounter = 0
                    task.wait(0.5)
                    continue
                end

                local item = items[data.Index]
                data.TeleportCounter += 1
                if TpJump(item.CFrame) then
                    if data.TeleportCounter >= settings.TeleportCount then
                        data.Index += 1
                        data.TeleportCounter = 0
                    end
                    task.wait(settings.TeleportDelay)
                end
            else
                if CountT(data.Visited) >= #items then
                    data.Visited = {}
                    task.wait(0.5)
                end

                local target, key
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("BasePart") then
                        local positionKey = GetPosKey(child.Position)
                        if not data.Visited[positionKey] then
                            target = child
                            key = positionKey
                            break
                        end
                    end
                end

                if target then
                    data.TeleportCounter += 1
                    if TpJump(target.CFrame) then
                        if data.TeleportCounter >= settings.TeleportCount then
                            data.Visited[key] = true
                            data.TeleportCounter = 0
                        end
                        task.wait(settings.TeleportDelay)
                    end
                else
                    data.Visited = {}
                    data.TeleportCounter = 0
                    task.wait(0.5)
                end
            end
        end
    end)
end

local farms = {
    {title = "ฟาร์มองุ่น", data = Config.Farm.Grape, folder = "Grape", item = "Grape"},
    {title = "ฟาร์มหิน", data = Config.Farm.Rock, folder = "Miner", item = "Rock"},
    {title = "ฟาร์มเหล็ก", data = Config.Farm.ScrapIron, folder = "ScrapIron", item = "ScrapIron"},
    {title = "ฟาร์มขยะ", data = Config.Farm.Garbage, folder = "Garbage", item = "Garbage"}
}

local function StopAllFarms(reason)
    local stopped = false
    for _, farm in ipairs(farms) do
        if farm.data.Enabled then
            farm.data.Enabled = false
            stopped = true
        end
    end

    for _, toggle in pairs(farmToggleRefs) do
        if toggle:Get() then
            toggle:Set(false)
        end
    end

    if stopped and uiReady then
        Notify("⚠️ หยุดฟาร์ม", reason or "มีผู้เล่นเข้าใกล้!", "warning", 5)
    end
end

local function ClearConns()
    for _, connection in ipairs(WheelConns) do
        connection:Disconnect()
    end
    WheelConns = {}
end

local function ApplyWheels(size)
    local keepCar = workspace:FindFirstChild("KeepCar")
    if not keepCar then
        if uiReady then
            Notify("ผิดพลาด", "ไม่พบ KeepCar", "error")
        end
        return 0
    end

    local count = 0
    for _, car in ipairs(keepCar:GetChildren()) do
        if CarConfig.ExcludedCar ~= "None" and car.Name == CarConfig.ExcludedCar then
            continue
        end

        local chassis = car:FindFirstChild("Chassis")
        if not chassis then
            continue
        end

        for _, suspensionName in ipairs({"SuspensionFL", "SuspensionFR", "SuspensionRL", "SuspensionRR"}) do
            local suspension = chassis:FindFirstChild(suspensionName)
            if not suspension then
                continue
            end

            local wheel = suspension:FindFirstChild("Wheel")
            if not wheel then
                for _, descendant in ipairs(suspension:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        wheel = descendant
                        break
                    end
                end
            end

            if not wheel then
                continue
            end

            pcall(function()
                wheel.Size = size
            end)

            for _, child in ipairs(wheel:GetChildren()) do
                if child:IsA("Highlight") or child:IsA("SelectionBox") then
                    child:Destroy()
                end
            end

            if CarConfig.HighlightEnabled then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = wheel
                highlight.FillColor = CarConfig.HighlightColor
                highlight.OutlineColor = CarConfig.HighlightColor
                highlight.FillTransparency = CarConfig.FillTransparency
                highlight.OutlineTransparency = CarConfig.OutlineTransparency
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Enabled = true
                highlight.Parent = wheel

                local selectionBox = Instance.new("SelectionBox")
                selectionBox.Adornee = wheel
                selectionBox.Color3 = CarConfig.HighlightColor
                selectionBox.LineThickness = 0.05
                selectionBox.Transparency = 0
                selectionBox.Visible = true
                selectionBox.Parent = wheel
            end

            count += 1
        end
    end

    if count == 0 and uiReady then
        Notify("คำเตือน", "ไม่พบล้อในรถ", "warning")
    end

    return count
end

local function ResetWheels()
    local keepCar = workspace:FindFirstChild("KeepCar")
    if not keepCar then
        return
    end

    for _, car in ipairs(keepCar:GetChildren()) do
        local chassis = car:FindFirstChild("Chassis")
        if not chassis then
            continue
        end

        for _, suspensionName in ipairs({"SuspensionFL", "SuspensionFR", "SuspensionRL", "SuspensionRR"}) do
            local suspension = chassis:FindFirstChild(suspensionName)
            if not suspension then
                continue
            end

            local wheel = suspension:FindFirstChild("Wheel")
            if not wheel then
                for _, descendant in ipairs(suspension:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        wheel = descendant
                        break
                    end
                end
            end

            if not wheel then
                continue
            end

            pcall(function()
                wheel.Size = Vector3.new(3, 3, 3)
            end)

            for _, child in ipairs(wheel:GetChildren()) do
                if child:IsA("Highlight") or child:IsA("SelectionBox") then
                    child:Destroy()
                end
            end
        end
    end
end

local function HookWheels(size)
    ClearConns()

    local keepCar = workspace:FindFirstChild("KeepCar")
    if not keepCar then
        return
    end

    for _, car in ipairs(keepCar:GetChildren()) do
        if CarConfig.ExcludedCar ~= "None" and car.Name == CarConfig.ExcludedCar then
            continue
        end

        local chassis = car:FindFirstChild("Chassis")
        if not chassis then
            continue
        end

        for _, suspensionName in ipairs({"SuspensionFL", "SuspensionFR", "SuspensionRL", "SuspensionRR"}) do
            local suspension = chassis:FindFirstChild(suspensionName)
            if not suspension then
                continue
            end

            local wheel = suspension:FindFirstChild("Wheel")
            if not wheel then
                for _, descendant in ipairs(suspension:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        wheel = descendant
                        break
                    end
                end
            end

            if not wheel then
                continue
            end

            table.insert(WheelConns, wheel:GetPropertyChangedSignal("Size"):Connect(function()
                if CarConfig.Enabled and wheel.Size ~= size then
                    pcall(function()
                        wheel.Size = size
                    end)
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
        if uiReady then
            Notify("ล้อรถ ON", ("ขยายยาง %d ล้อ"):format(count), "success", 4)
        end
    else
        ClearConns()
        ResetWheels()
        if uiReady then
            Notify("ล้อรถ OFF", "รีเซ็ตขนาดยางแล้ว", "warning", 4)
        end
    end
end

local function ClearCarESP()
    for _, board in ipairs(CarESP.Boards) do
        pcall(function()
            board:Destroy()
        end)
    end
    CarESP.Boards = {}
end

local function ApplyCarESP()
    ClearCarESP()

    local keepCar = workspace:FindFirstChild("KeepCar")
    if not keepCar then
        return 0
    end

    for _, car in ipairs(keepCar:GetChildren()) do
        local root = nil
        if car:IsA("Model") then
            root = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart")
        end

        if not root then
            for _, descendant in ipairs(car:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    root = descendant
                    break
                end
            end
        end

        if not root then
            continue
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CarESP_" .. car.Name
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 200, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.Parent = root

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = car.Name
        label.TextColor3 = CarESP.Color
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard

        table.insert(CarESP.Boards, billboard)
    end

    return #CarESP.Boards
end

local function SetCarESP(state)
    CarESP.Enabled = state
    if state then
        local count = ApplyCarESP()
        if uiReady then
            Notify("ESP รถ ON", ("แสดงชื่อ %d คัน"):format(count), "success", 4)
        end
    else
        ClearCarESP()
        if uiReady then
            Notify("ESP รถ OFF", "ซ่อนชื่อรถแล้ว", "warning", 3)
        end
    end
end

local function TpTo(cf)
    local character = LocalPlayer.Character
    if not character then
        Notify("ผิดพลาด", "ไม่พบตัวละคร", "error")
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Notify("ผิดพลาด", "ไม่พบ HumanoidRootPart", "error")
        return
    end

    pcall(function()
        hrp.CFrame = cf
    end)
end

local function CheckArmor()
    local model = workspace:FindFirstChild(LocalPlayer.Name)
    if not model or model:FindFirstChild("BodyArmor") then
        return
    end

    local keyMap = {
        Enum.KeyCode.One,
        Enum.KeyCode.Two,
        Enum.KeyCode.Three,
        Enum.KeyCode.Four,
        Enum.KeyCode.Five,
        Enum.KeyCode.Six,
        Enum.KeyCode.Seven,
        Enum.KeyCode.Eight
    }

    local keyCode = keyMap[Config.AutoArmor.KeyNumber]
    if not keyCode then
        return
    end

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function GetRootPart()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end
    return character:FindFirstChild("HumanoidRootPart")
end

local function GetCarPrimaryPart(car)
    if car:IsA("Model") then
        return car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart", true)
    end
    if car:IsA("BasePart") then
        return car
    end
    return car:FindFirstChildWhichIsA("BasePart", true)
end

local function FindAttributeName(instance, targetName)
    for attributeName in pairs(instance:GetAttributes()) do
        if string.lower(attributeName) == string.lower(targetName) then
            return attributeName
        end
    end
    return nil
end

-- ===== Baccarat functions (ไม่แก้ไข) =====
local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local function getBaccaratSource()
    local gameZone = playerGui:FindFirstChild("GameZone")
    if gameZone then
        local remoteHolder = gameZone:FindFirstChild("remote")
        local remote = remoteHolder and remoteHolder.Value
        if remoteHolder and remoteHolder:IsA("ObjectValue") and typeof(remote) == "Instance" then
            return gameZone, remote
        end
    end

    return nil, nil
end

local function decodeBaccaratHistory(remote)
    if not remote or not remote.Parent then
        return {}
    end

    local historyRaw = remote.Parent:GetAttribute("history")
    if type(historyRaw) ~= "string" or historyRaw == "" then
        return {}
    end

    local httpService = game:GetService("HttpService")
    local ok, decoded = pcall(function()
        return httpService:JSONDecode(historyRaw)
    end)

    if ok and type(decoded) == "table" then
        return decoded
    end

    return {}
end

local function formatBaccaratResult(entry)
    if entry == "playerwin" then
        return "P"
    elseif entry == "bankerwin" then
        return "B"
    elseif entry == "tie" then
        return "T"
    end
    return "?"
end

local function predictBaccarat(history)
    local weights = {
        banker = 0,
        player = 0,
        tie = 0
    }

    local recentCount = math.min(#history, 20)
    for i = 1, recentCount do
        local entry = history[#history - recentCount + i]
        local weight = i

        if entry == "bankerwin" then
            weights.banker = weights.banker + weight
        elseif entry == "playerwin" then
            weights.player = weights.player + weight
        elseif entry == "tie" then
            weights.tie = weights.tie + (weight * 0.6)
        end
    end

    local streakType = nil
    local streakCount = 0
    for i = #history, 1, -1 do
        local entry = history[i]
        if not streakType then
            streakType = entry
            streakCount = 1
        elseif entry == streakType then
            streakCount = streakCount + 1
        else
            break
        end
    end

    if streakType == "bankerwin" then
        weights.banker = weights.banker + (streakCount * 2.5)
    elseif streakType == "playerwin" then
        weights.player = weights.player + (streakCount * 2.5)
    elseif streakType == "tie" then
        weights.tie = weights.tie + streakCount
    end

    local totalWeight = math.max(weights.banker + weights.player + weights.tie, 1)
    local bankerPercent = math.floor((weights.banker / totalWeight) * 100 + 0.5)
    local playerPercent = math.floor((weights.player / totalWeight) * 100 + 0.5)
    local tiePercent = math.max(0, 100 - bankerPercent - playerPercent)

    local bestKey = "banker"
    local bestValue = bankerPercent

    if playerPercent > bestValue then
        bestKey = "player"
        bestValue = playerPercent
    end

    if tiePercent > bestValue then
        bestKey = "tie"
        bestValue = tiePercent
    end

    local recommendation = "BANKER"
    if bestKey == "player" then
        recommendation = "PLAYER"
    elseif bestKey == "tie" then
        recommendation = "TIE"
    end

    return {
        Recommendation = recommendation,
        BankerPercent = bankerPercent,
        PlayerPercent = playerPercent,
        TiePercent = tiePercent,
        StreakType = streakType,
        StreakCount = streakCount
    }
end

-- ===== TABS =====
local pvpTab = window:CreateTab("PVP", {
    Group = "MAIN",
    Icon = "P"
})

local farmTab = window:CreateTab("Farm", {
    Group = "MAIN",
    Icon = "F",
    Selected = true
})

local teleportTab = window:CreateTab("Teleport", {
    Group = "MAIN",
    Icon = "T"
})

local activityTab = window:CreateTab("Activity", {
    Group = "MAIN",
    Icon = "A"
})

local carTab = window:CreateTab("Car", {
    Group = "MAIN",
    Icon = "C"
})

local baccaratTab = window:CreateTab("Baccarat", {  -- +++ tab ใหม่ +++
    Group = "MAIN",
    Icon = "B"
})

local settingsTab = window:CreateTab("Settings", {
    Group = "SETTINGS",
    Icon = "S"
})

-- ===== SECTIONS =====
local targetSection = pvpTab:CreateSection("Targeting", {
    Column = 1,
    Order = 10
})

local targetVisualSection = pvpTab:CreateSection("Visual", {
    Column = 1,
    Order = 20
})

local armorSection = pvpTab:CreateSection("Auto Armor", {
    Column = 2,
    Order = 10
})

local truckSection = farmTab:CreateSection("Truck", {
    Column = 1,
    Order = 10
})

local farmSettingsSection = farmTab:CreateSection("Farm Settings", {
    Column = 1,
    Order = 20
})

local farmControlSection = farmTab:CreateSection("Auto Farm", {
    Column = 2,
    Order = 10
})

local proximitySection = farmTab:CreateSection("Proximity", {
    Column = 2,
    Order = 20
})

local saveTeleportSection = teleportTab:CreateSection("Saved Position", {
    Column = 1,
    Order = 10
})

local destinationSection = teleportTab:CreateSection("Destinations", {
    Column = 2,
    Order = 10
})

local activitySection = activityTab:CreateSection("Event Teleports", {
    Column = 1,
    Order = 10
})

local carWheelSection = carTab:CreateSection("Wheel Size", {
    Column = 1,
    Order = 10
})

local carVisualSection = carTab:CreateSection("Visual", {
    Column = 1,
    Order = 20
})

local carControlSection = carTab:CreateSection("Control", {
    Column = 2,
    Order = 10
})

local carUnlockSection = carTab:CreateSection("Unlock Car", {
    Column = 2,
    Order = 20
})

local carOptionsSection = carTab:CreateSection("Car Options", {
    Column = 2,
    Order = 30
})

local baccaratSection = baccaratTab:CreateSection("Baccarat Predict", {  -- +++ section ใหม่ +++
    Column = 1,
    Order = 10
})

local uiSection = settingsTab:CreateSection("UI", {
    Column = 1,
    Order = 10
})

local settingSection = settingsTab:CreateSection("Setting", {
    Column = 1,
    Order = 20
})

local miscSection = settingsTab:CreateSection("Other", {
    Column = 2,
    Order = 10
})

local playerDropdown = targetSection:AddDropdown("Exclude Player", {
    Items = GetAllPlayers(),
    Default = "None",
    Callback = function(value)
        Config.ExcludedPlayer = value
        if Config.TargetingEnabled then
            ApplyTargeting()
        end
    end
})

targetSection:AddButton("Refresh Player List", {
    Callback = function()
        playerDropdown:Refresh(GetAllPlayers(), Config.ExcludedPlayer or "None")
    end
})

targetSection:AddTextbox("Hitbox Size (X,Y,Z)", {
    Default = "20,20,20",
    Placeholder = "20,20,20",
    Callback = function(value)
        local values = {}
        for token in tostring(value):gmatch("[^,]+") do
            local number = tonumber(token)
            if number then
                table.insert(values, number)
            end
        end

        if #values == 3 then
            Config.Target.Size = Vector3.new(values[1], values[2], values[3])
            if Config.TargetingEnabled then
                ApplyTargeting()
            end
        elseif uiReady then
            Notify("ผิดพลาด", "ใช้รูปแบบ X,Y,Z", "error")
        end
    end
})

targetSection:AddTextbox("Refresh Interval (sec)", {
    Default = "1",
    Placeholder = "1",
    Callback = function(value)
        local number = tonumber(value)
        if number and number > 0 then
            Config.Target.RefreshInterval = number
        end
    end
})

HitboxToggle = targetSection:AddToggle("Enable Hitbox Targeting", {
    Default = false,
    Callback = function(state)
        SetTargeting(state)
    end
})

targetSection:AddKeybind("Toggle Hitbox Key", {
    Default = "X",
    Callback = function()
        if GUIActive and HitboxToggle then
            HitboxToggle:Trigger()
        end
    end
})

targetSection:AddButton("Force Update", {
    Callback = function()
        if not Config.TargetingEnabled then
            Notify("คำเตือน", "เปิด toggle ก่อน!", "warning")
            return
        end

        local modified, skipped = ApplyTargeting()
        Notify("อัพเดทแล้ว", ("ปรับ %d | ข้าม %d"):format(modified, skipped), "success", 5)
    end
})

targetVisualSection:AddToggle("Enable Highlight", {
    Default = true,
    Callback = function(state)
        Config.Highlight.Enabled = state
        if Config.TargetingEnabled then
            ApplyTargeting()
        end
    end
})

targetVisualSection:AddSlider("Highlight Transparency", {
    Min = 0,
    Max = 100,
    Default = 70,
    Callback = function(value)
        Config.Highlight.Transparency = value / 100
        if Config.TargetingEnabled then
            ApplyTargeting()
        end
    end
})

targetVisualSection:AddColorPicker("Highlight Color", {
    Default = Color3.fromRGB(0, 255, 255),
    Callback = function(color)
        Config.Highlight.Color = color
        if Config.TargetingEnabled then
            ApplyTargeting()
        end
    end
})

armorSection:AddTextbox("Armor Slot (1-8)", {
    Default = "1",
    Placeholder = "1",
    Callback = function(value)
        local number = tonumber(value)
        if number and number >= 1 and number <= 8 then
            Config.AutoArmor.KeyNumber = math.floor(number)
        end
    end
})

armorSection:AddToggle("Auto Equip Armor", {
    Default = false,
    Callback = function(state)
        Config.AutoArmor.Enabled = state
        if state then
            task.spawn(function()
                while Config.AutoArmor.Enabled do
                    CheckArmor()
                    task.wait(1)
                end
            end)
        end
    end
})

local truckDropdown = truckSection:AddDropdown("Select Truck", {
    Items = {"None"},
    Default = "None",
    Callback = function(value)
        Config.Truck.Selected = value ~= "None" and value or nil
    end
})

truckSection:AddButton("Scan My Trucks", {
    Callback = function()
        local trucks = ScanPlayerTrucks()
        if #trucks > 0 then
            local items = {"None"}
            for _, truck in ipairs(trucks) do
                table.insert(items, truck)
            end

            local defaultTruck = Config.Truck.Selected or trucks[1]
            truckDropdown:Refresh(items, defaultTruck)
            Config.Truck.Selected = defaultTruck
            Notify("พบรถ", ("พบ %d คัน"):format(#trucks), "success")
        else
            local all = {"None"}
            for _, child in ipairs(LocalPlayer:GetChildren()) do
                if child:IsA("Model") or child:IsA("Folder") then
                    table.insert(all, child.Name)
                end
            end
            truckDropdown:Refresh(all, "None")
            Notify("ไม่พบรถ", "ไม่พบรถ", "warning")
        end
    end
})

truckSection:AddToggle("เก็บของหลังรถ", {
    Default = false,
    Callback = function(state)
        SetTruckAutoCollect(state)
    end
})

farmSettingsSection:AddDropdown("Farm Mode", {
    Items = {"Mode 1 - Repeat", "Mode 2 - No Repeat"},
    Default = "Mode 1 - Repeat",
    Callback = function(value)
        Config.Farm.Settings.FarmMode = value == "Mode 1 - Repeat" and 1 or 2
    end
})

farmSettingsSection:AddTextbox("Teleport Delay (sec)", {
    Default = "5",
    Placeholder = "5",
    Callback = function(value)
        local number = tonumber(value)
        if number and number > 0 then
            Config.Farm.Settings.TeleportDelay = number
        end
    end
})

farmSettingsSection:AddTextbox("Teleports Before Collect", {
    Default = "1",
    Placeholder = "1",
    Callback = function(value)
        local number = tonumber(value)
        if number and number >= 1 then
            Config.Farm.Settings.TeleportCount = math.floor(number)
        end
    end
})

farmSettingsSection:AddTextbox("Collect Amount", {
    Default = "5",
    Placeholder = "5",
    Callback = function(value)
        local number = tonumber(value)
        if number and number >= 1 then
            Config.Farm.Settings.CollectAmount = math.floor(number)
        end
    end
})

for _, farm in ipairs(farms) do
    farmToggleRefs[farm.title] = farmControlSection:AddToggle(farm.title, {
        Default = false,
        Callback = function(state)
            farm.data.Enabled = state
            if state then
                RunFarm(farm.data, farm.folder, farm.item)
            end
        end
    })
end

proximitySection:AddToggle("Stop Farm When Players Nearby", {
    Default = false,
    Callback = function(state)
        Config.Proximity.Enabled = state
        if state then
            Notify("เปิดตรวจจับ", ("รัศมี %d studs"):format(Config.Proximity.Distance), "info")
            task.spawn(function()
                while Config.Proximity.Enabled do
                    local myCharacter = LocalPlayer.Character
                    local myHRP = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local theirCharacter = player.Character
                                local theirHRP = theirCharacter and theirCharacter:FindFirstChild("HumanoidRootPart")
                                if theirHRP then
                                    local distance = (myHRP.Position - theirHRP.Position).Magnitude
                                    if distance <= Config.Proximity.Distance then
                                        StopAllFarms(player.Name .. " เข้าใกล้! (" .. math.floor(distance) .. " studs)")
                                        break
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

proximitySection:AddSlider("Detect Radius", {
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(value)
        Config.Proximity.Distance = value
    end
})

saveTeleportSection:AddButton("Save Current Position", {
    Callback = function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Notify("ผิดพลาด", "ไม่พบตัวละคร", "error")
            return
        end

        SavedCF = hrp.CFrame
        local position = SavedCF.Position
        Notify("เซฟสำเร็จ", ("X:%.1f Y:%.1f Z:%.1f"):format(position.X, position.Y, position.Z), "success", 4)
    end
})

saveTeleportSection:AddButton("Teleport To Saved Position", {
    Callback = function()
        if not SavedCF then
            Notify("ผิดพลาด", "ยังไม่ได้เซฟ!", "error")
            return
        end

        TpTo(SavedCF)
        local position = SavedCF.Position
        Notify("วาปกลับแล้ว", ("X:%.1f Y:%.1f Z:%.1f"):format(position.X, position.Y, position.Z), "success", 4)
    end
})

local destinations = {
    {title = "Garage", cf = CFrame.new(303.565521, 66.1486893, -906.82373, 0.767768562, 6.71885871e-08, -0.640727282, -5.10625604e-08, 1, 4.36759322e-08, 0.640727282, -8.15832679e-10, 0.767768562)},
    {title = "Blue Label", cf = CFrame.new(-900.60968, 88.9132462, 1224.23682, -0.907460213, -1.95295904e-08, -0.420138031, -9.32648447e-09, 1, -2.63393822e-08, 0.420138031, -1.99835295e-08, -0.907460213)},
    {title = "Council", cf = CFrame.new(5547.8877, 683.3078, 1496.87927, -0.267395705, 1.94510399e-08, 0.963586807, 5.54390418e-08, 1, -4.80172435e-09, -0.963586807, 5.21363681e-08, -0.267395705)},
    {title = "Red Label", cf = CFrame.new(6889.5166, 285.729034, -2287.85767, -0.0161244199, 1.21794734e-08, 0.999870002, -4.29730243e-08, 1, -1.28740627e-08, -0.999870002, -4.31750244e-08, -0.0161244199)},
    {title = "Top Gas", cf = CFrame.new(7985.23975, 264.948853, -781.145386, -0.745238066, -4.59924507e-08, -0.666798472, -1.86272047e-08, 1, -4.81566005e-08, 0.666798472, -2.3467539e-08, -0.745238066)}
}

for _, destination in ipairs(destinations) do
    destinationSection:AddButton("Teleport " .. destination.title, {
        Callback = function()
            TpTo(destination.cf)
        end
    })
end

activitySection:AddButton("Teleport Pakua Event", {
    Callback = function()
        TpTo(CFrame.new(-694.090698, 188.338425, 571.563782, 0.0845197961, -4.88692606e-08, -0.996421814, 3.67553454e-08, 1, -4.59270417e-08, 0.996421814, -3.27420828e-08, 0.0845197961))
    end
})

activitySection:AddButton("Teleport Lucky Bomb", {
    Callback = function()
        TpTo(CFrame.new(-391.9711, 66.0340271, 578.966553, -0.0431948975, -4.21879598e-09, -0.999066651, 8.60502336e-09, 1, -4.59477745e-09, 0.999066651, -8.79546302e-09, -0.0431948975))
    end
})

local carDropdown = carWheelSection:AddDropdown("Exclude Car", {
    Items = GetAllCars(),
    Default = "None",
    Callback = function(value)
        CarConfig.ExcludedCar = value
        if CarConfig.Enabled then
            ApplyWheels(CarConfig.WheelSize)
            HookWheels(CarConfig.WheelSize)
        end
    end
})

carWheelSection:AddButton("Refresh Car List", {
    Callback = function()
        carDropdown:Refresh(GetAllCars(), CarConfig.ExcludedCar or "None")
    end
})

carWheelSection:AddTextbox("Wheel Size (X,Y,Z)", {
    Default = "10,10,10",
    Placeholder = "10,10,10",
    Callback = function(value)
        local values = {}
        for token in tostring(value):gmatch("[^,]+") do
            local number = tonumber(token)
            if number then
                table.insert(values, number)
            end
        end

        if #values == 3 then
            CarConfig.WheelSize = Vector3.new(values[1], values[2], values[3])
            if CarConfig.Enabled then
                ApplyWheels(CarConfig.WheelSize)
                HookWheels(CarConfig.WheelSize)
            end
        elseif uiReady then
            Notify("ผิดพลาด", "ใช้รูปแบบ X,Y,Z", "error")
        end
    end
})

carVisualSection:AddToggle("Car Name ESP", {
    Default = false,
    Callback = function(state)
        SetCarESP(state)
    end
})

carVisualSection:AddColorPicker("Car ESP Color", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        CarESP.Color = color
        if CarESP.Enabled then
            for _, board in ipairs(CarESP.Boards) do
                local label = board:FindFirstChildOfClass("TextLabel")
                if label then
                    label.TextColor3 = color
                end
            end
        end
    end
})

carVisualSection:AddButton("Refresh Car ESP", {
    Callback = function()
        if not CarESP.Enabled then
            Notify("คำเตือน", "เปิด ESP ก่อน!", "warning")
            return
        end

        local count = ApplyCarESP()
        Notify("รีเฟรชแล้ว", ("แสดง %d คัน"):format(count), "success", 3)
    end
})

carVisualSection:AddToggle("Wheel Highlight", {
    Default = true,
    Callback = function(state)
        CarConfig.HighlightEnabled = state
        if CarConfig.Enabled then
            ApplyWheels(CarConfig.WheelSize)
        end
    end
})

carVisualSection:AddColorPicker("Wheel Highlight Color", {
    Default = Color3.fromRGB(255, 165, 0),
    Callback = function(color)
        CarConfig.HighlightColor = color
        if CarConfig.Enabled then
            ApplyWheels(CarConfig.WheelSize)
        end
    end
})

WheelToggle = carControlSection:AddToggle("Expand Car Wheels", {
    Default = false,
    Callback = function(state)
        SetWheels(state)
    end
})

carControlSection:AddKeybind("Toggle Wheel Key", {
    Default = "Z",
    Callback = function()
        if GUIActive and WheelToggle then
            WheelToggle:Trigger()
        end
    end
})

carControlSection:AddButton("Force Update Wheels", {
    Callback = function()
        if not CarConfig.Enabled then
            Notify("คำเตือน", "เปิด toggle ก่อน!", "warning")
            return
        end

        local count = ApplyWheels(CarConfig.WheelSize)
        HookWheels(CarConfig.WheelSize)
        Notify("อัพเดทยางแล้ว", ("ขยาย %d ล้อ"):format(count), "success", 5)
    end
})

carUnlockSection:AddButton("Unlock Nearby Cars", {
    Callback = function()
        local keepCar = workspace:FindFirstChild("KeepCar")
        local rootPart = GetRootPart()
        if not keepCar then
            Notify("Unlock Car", "KeepCar not found", "error", 4)
            return
        end
        if not rootPart then
            Notify("Unlock Car", "HumanoidRootPart not found", "error", 4)
            return
        end

        local updatedCount = 0
        local skippedCount = 0

        for _, car in ipairs(keepCar:GetChildren()) do
            local primaryPart = GetCarPrimaryPart(car)
            if primaryPart then
                local distance = (primaryPart.Position - rootPart.Position).Magnitude
                if distance >= 0 and distance <= 15 then
                    local driveAttribute = FindAttributeName(car, "drive")
                    local playerAttribute = FindAttributeName(car, "player")

                    if driveAttribute and playerAttribute then
                        local okDrive = pcall(function()
                            car:SetAttribute(driveAttribute, LocalPlayer.Name)
                        end)
                        local okPlayer = pcall(function()
                            car:SetAttribute(playerAttribute, LocalPlayer.Name)
                        end)

                        if okDrive and okPlayer then
                            updatedCount += 1
                        else
                            skippedCount += 1
                        end
                    else
                        skippedCount += 1
                    end
                end
            end
        end

        if updatedCount > 0 then
            Notify("Unlock Car", ("Unlocked %d car(s) | skipped %d"):format(updatedCount, skippedCount), "success", 4)
        else
            Notify("Unlock Car", "No nearby cars found in range 0-15 or missing drive/player attributes", "warning", 4)
        end
    end
})

-- Car Options
local appliedCarStatsEnabled = false
local appliedCarStatsTarget = nil
local appliedCarStatsOriginal = {
    MaxSpeed = nil,
    DrivingTorque = nil
}
local desiredCarMaxSpeed = ""
local desiredCarAcceleration = ""

local function GetNearestKeepCar()
    local keepCarFolder = workspace:FindFirstChild("KeepCar")
    local rootPart = GetRootPart()
    if not keepCarFolder or not rootPart then
        return nil
    end
    local nearestCar = nil
    local nearestDistance = math.huge
    for _, car in ipairs(keepCarFolder:GetChildren()) do
        local primaryPart = GetCarPrimaryPart(car)
        if primaryPart then
            local distance = (primaryPart.Position - rootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestCar = car
            end
        end
    end
    return nearestCar
end

local function ApplyCarStatValues(targetCar)
    if not targetCar then return false, "No target car" end
    local maxSpeedAttribute = FindAttributeName(targetCar, "MaxSpeed")
    local drivingTorqueAttribute = FindAttributeName(targetCar, "DrivingTorque")
    if not maxSpeedAttribute or not drivingTorqueAttribute then
        return false, "Missing MaxSpeed or DrivingTorque attribute"
    end
    local maxSpeedValue = tonumber(desiredCarMaxSpeed)
    local accelerationValue = tonumber(desiredCarAcceleration)
    if not maxSpeedValue or not accelerationValue then
        return false, "Invalid Max Speed or Acceleration value"
    end
    local ok = pcall(function()
        targetCar:SetAttribute(maxSpeedAttribute, maxSpeedValue)
        targetCar:SetAttribute(drivingTorqueAttribute, accelerationValue)
    end)
    return ok, ok and nil or "Unable to update car attributes"
end

local function RestoreCarStatValues()
    if not appliedCarStatsTarget or not appliedCarStatsTarget.Parent then
        appliedCarStatsTarget = nil
        appliedCarStatsOriginal.MaxSpeed = nil
        appliedCarStatsOriginal.DrivingTorque = nil
        return false, "Target car was removed"
    end
    local maxSpeedAttribute = FindAttributeName(appliedCarStatsTarget, "MaxSpeed")
    local drivingTorqueAttribute = FindAttributeName(appliedCarStatsTarget, "DrivingTorque")
    if not maxSpeedAttribute or not drivingTorqueAttribute then
        return false, "Missing MaxSpeed or DrivingTorque attribute"
    end
    local ok = pcall(function()
        appliedCarStatsTarget:SetAttribute(maxSpeedAttribute, appliedCarStatsOriginal.MaxSpeed)
        appliedCarStatsTarget:SetAttribute(drivingTorqueAttribute, appliedCarStatsOriginal.DrivingTorque)
    end)
    if ok then
        appliedCarStatsTarget = nil
        appliedCarStatsOriginal.MaxSpeed = nil
        appliedCarStatsOriginal.DrivingTorque = nil
    end
    return ok, ok and nil or "Unable to restore car attributes"
end

carOptionsSection:AddTextbox("Max Speed", {
    Default = "",
    Placeholder = "Enter max speed",
    Callback = function(value)
        desiredCarMaxSpeed = value
        if appliedCarStatsEnabled and appliedCarStatsTarget then
            ApplyCarStatValues(appliedCarStatsTarget)
        end
    end
})

carOptionsSection:AddTextbox("Acceleration", {
    Default = "",
    Placeholder = "Enter acceleration",
    Callback = function(value)
        desiredCarAcceleration = value
        if appliedCarStatsEnabled and appliedCarStatsTarget then
            ApplyCarStatValues(appliedCarStatsTarget)
        end
    end
})

carOptionsSection:AddToggle("Apply Car Stats", {
    Default = false,
    Callback = function(state)
        appliedCarStatsEnabled = state
        local ok = true
        local message = nil
        if state then
            local targetCar = GetNearestKeepCar()
            if not targetCar then
                ok = false
                message = "No nearby car found in KeepCar"
                appliedCarStatsEnabled = false
            else
                local maxSpeedAttribute = FindAttributeName(targetCar, "MaxSpeed")
                local drivingTorqueAttribute = FindAttributeName(targetCar, "DrivingTorque")
                if not maxSpeedAttribute or not drivingTorqueAttribute then
                    ok = false
                    message = "Missing MaxSpeed or DrivingTorque attribute"
                    appliedCarStatsEnabled = false
                else
                    appliedCarStatsTarget = targetCar
                    appliedCarStatsOriginal.MaxSpeed = targetCar:GetAttribute(maxSpeedAttribute)
                    appliedCarStatsOriginal.DrivingTorque = targetCar:GetAttribute(drivingTorqueAttribute)
                    ok, message = ApplyCarStatValues(targetCar)
                    if not ok then
                        appliedCarStatsEnabled = false
                        appliedCarStatsTarget = nil
                        appliedCarStatsOriginal.MaxSpeed = nil
                        appliedCarStatsOriginal.DrivingTorque = nil
                    end
                end
            end
        else
            ok, message = RestoreCarStatValues()
        end
        if not uiReady then return end
        Notify(
            "Car Options",
            ok and (state and "Applied car stats to nearest car" or "Restored original car stats")
               or (message or "Unable to update car stats"),
            ok and "success" or "error",
            2
        )
    end
})

-- ===== Baccarat Section UI =====
baccaratSection:AddButton("Predict", {
    Callback = function()
        local _, remote = getBaccaratSource()
        if not remote then
            Notify("Baccarat", "GameZone baccarat source not found", "error", 4)
            return
        end

        local history = decodeBaccaratHistory(remote)
        local result = predictBaccarat(history)

        local latest = {}
        local startIndex = math.max(1, #history - 9)
        for i = startIndex, #history do
            table.insert(latest, formatBaccaratResult(history[i]))
        end

        local latestStr = #latest > 0 and table.concat(latest, " ") or "-"
        local streakStr = (result.StreakType or "-") .. " x" .. (result.StreakCount or 0)

        Notify(
            "Recommend: " .. result.Recommendation,
            "B:" .. result.BankerPercent .. "% P:" .. result.PlayerPercent .. "% T:" .. result.TiePercent .. "%\nStreak: " .. streakStr .. "\nLatest: " .. latestStr,
            "info",
            8
        )
    end
})

-- ===== SETTINGS =====
uiToggleKeybind = uiSection:AddKeybind("Toggle UI Key", {
    Default = "RightControl",
    Callback = function(keyCode)
        window.ToggleKeyCode = keyCode
        if not uiReady then
            return
        end

        Notify("UI Setting", "GUI toggle key updated", "success", 2)
    end
})

settingSection:AddToggle("Show FPS/PING", {
    Default = false,
    Callback = function(state)
        if state then
            window:OpenStatsOverlay({
                Title = "Performance"
            })
        else
            window:CloseStatsOverlay()
        end

        if uiReady then
            Notify("Setting", state and "FPS/PING enabled" or "FPS/PING disabled", state and "success" or "warning", 2)
        end
    end
})

settingSection:AddToggle("Show Keybinds", {
    Default = false,
    Callback = function(state)
        if state then
            window:OpenKeybinds({
                Title = "Keybinds"
            })
        else
            window:CloseKeybinds()
        end

        if uiReady then
            Notify("Setting", state and "Keybind display enabled" or "Keybind display disabled", state and "success" or "warning", 2)
        end
    end
})

miscSection:AddButton("Close GUI", {
    Callback = function()
        GUIActive = false
        Config.TargetingEnabled = false
        Config.AutoArmor.Enabled = false
        Config.Proximity.Enabled = false
        Config.Truck.AutoCollectEnabled = false
        StopAllFarms("GUI closed")
        ClearConns()
        ResetWheels()
        ClearCarESP()
        window:Destroy()
    end
})

Players.PlayerAdded:Connect(function()
    if playerDropdown then
        playerDropdown:Refresh(GetAllPlayers(), Config.ExcludedPlayer or "None")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Config.ExcludedPlayer == player.Name then
        Config.ExcludedPlayer = "None"
    end

    if playerDropdown then
        playerDropdown:Refresh(GetAllPlayers(), Config.ExcludedPlayer or "None")
    end
end)

local keepCar = workspace:FindFirstChild("KeepCar")
if keepCar then
    keepCar.ChildAdded:Connect(function()
        if carDropdown then
            carDropdown:Refresh(GetAllCars(), CarConfig.ExcludedCar or "None")
        end
        if CarESP.Enabled then
            ApplyCarESP()
        end
    end)

    keepCar.ChildRemoved:Connect(function(removedCar)
        if CarConfig.ExcludedCar == removedCar.Name then
            CarConfig.ExcludedCar = "None"
        end

        if carDropdown then
            carDropdown:Refresh(GetAllCars(), CarConfig.ExcludedCar or "None")
        end
        if CarESP.Enabled then
            ApplyCarESP()
        end
    end)
end

UserInputService.WindowFocusReleased:Connect(function()
    if Config.TargetingEnabled then
        ApplyTargeting()
    end
end)

task.spawn(function()
    local lastKeyCode = nil
    while GUIActive and window and window.ScreenGui do
        if uiToggleKeybind and uiToggleKeybind.GetKeybind then
            local current = uiToggleKeybind:GetKeybind()
            if current ~= lastKeyCode then
                window.ToggleKeyCode = current
                lastKeyCode = current
            end
        end
        task.wait(0.2)
    end
end)

uiReady = true
Notify("Vertex Hub", "God Weapon loaded successfully.", "success", 3)
print("[GodWeapon v2.0] Loaded with VertexUI")
