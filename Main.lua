-- Khởi tạo thư viện Fluent GUI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Tạo Window "Seorb Hub"
local Window = Fluent:CreateWindow({
    Title = "Seorb Hub",
    SubTitle = "Blox Fruits Update 31",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Tạo Tabs
local Tabs = {
    MainFarm = Window:AddTab({ Title = "Main Farm", Icon = "home" }),
    LocalPlayer = Window:AddTab({ Title = "Local Player", Icon = "user" })
}

-- Biến Global điều khiển
_G.AutoFarm = false
_G.FarmMode = "Farm Bone"
_G.SelectWeapon = "Melee"
_G.AttackSpeed = "Fast Attack"
_G.BringMob = false
_G.AutoBuso = false
_G.AutoKen = false
_G.TweenSpeed = 250
_G.AutoQuest = false
_G.MobFarmRadius = 80        -- khoảng cách tối đa để gom quái
_G.MaxMobStack = 8           -- số lượng quái tối đa
_G.DespawnCheckDistance = 120
_G.SafeHeight = 30           

local currentTween = nil
local lastAttackTick = 0 

-- Biến Services & Player
local Player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ==========================================
-- GIAO DIỆN: MAIN FARM
-- ==========================================
local WeaponDropdown = Tabs.MainFarm:AddDropdown("WeaponDropdown", {
    Title = "Chọn Vũ Khí",
    Values = {"Melee", "Sword"},
    Multi = false,
    Default = 1,
})
WeaponDropdown:OnChanged(function(Value) _G.SelectWeapon = Value end)

local FarmModeDropdown = Tabs.MainFarm:AddDropdown("FarmModeDropdown", {
    Title = "Chế Độ Farm",
    Values = {"Farm Bone", "Farm Level", "Farm Katakuri"},
    Multi = false,
    Default = 1,
})
FarmModeDropdown:OnChanged(function(Value) _G.FarmMode = Value end)

local AttackSpeedDropdown = Tabs.MainFarm:AddDropdown("AttackSpeedDropdown", {
    Title = "Tốc Độ Đánh (Attack Speed)",
    Values = {"Normal", "Fast Attack", "Superfast Attack (CẢNH BÁO)"},
    Multi = false,
    Default = 2,
})
AttackSpeedDropdown:OnChanged(function(Value) _G.AttackSpeed = Value end)

local AutoQuestToggle = Tabs.MainFarm:AddToggle("AutoQuestToggle", {Title = "Tự Động Nhận Quest", Default = false})
AutoQuestToggle:OnChanged(function(Value) _G.AutoQuest = Value end)

local AutoFarmToggle = Tabs.MainFarm:AddToggle("AutoFarmToggle", {Title = "Bật Auto Farm", Default = false})
AutoFarmToggle:OnChanged(function(Value)
    _G.AutoFarm = Value
    if not Value and currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
end)

-- ==========================================
-- GIAO DIỆN: LOCAL PLAYER
-- ==========================================
local BringMobToggle = Tabs.LocalPlayer:AddToggle("BringMobToggle", {Title = "Gom Quái (Bring Mob)", Default = false})
BringMobToggle:OnChanged(function(Value) _G.BringMob = Value end)

local FlySpeedDropdown = Tabs.LocalPlayer:AddDropdown("FlySpeedDropdown", {
    Title = "Tốc Độ Bay (Tween Speed)",
    Values = {"150", "200", "250", "350", "400", "450", "500"},
    Multi = false,
    Default = 3,
})
FlySpeedDropdown:OnChanged(function(Value) _G.TweenSpeed = tonumber(Value) end)

local AutoHakiToggle = Tabs.LocalPlayer:AddToggle("AutoHakiToggle", {Title = "Auto Haki (Vũ Trang)", Default = false})
AutoHakiToggle:OnChanged(function(Value) _G.AutoBuso = Value end)

local AutoKenToggle = Tabs.LocalPlayer:AddToggle("AutoKenToggle", {Title = "Auto Ken (Quan Sát)", Default = false})
AutoKenToggle:OnChanged(function(Value) _G.AutoKen = Value end)

-- ==========================================
-- HỆ THỐNG AUTO HAKI & KEN
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoBuso and Player.Character then
            if not Player.Character:FindFirstChild("HasBuso") then
                pcall(function() RS.Remotes.CommF_:InvokeServer("Buso") end)
            end
        end

        if _G.AutoKen and Player.Character then
            local kenActive = false
            local playerGui = Player:FindFirstChild("PlayerGui")
            if playerGui and playerGui:FindFirstChild("ScreenGui") and playerGui.ScreenGui:FindFirstChild("Dodge") then
                kenActive = playerGui.ScreenGui.Dodge.Visible
            end
            if not kenActive then
                pcall(function()
                    RS.Remotes.CommE:FireServer("Instinct")
                    task.wait(1.5)
                end)
            end
        end
    end
end)

-- ==========================================
-- CORE FUNCTIONS & TWEEN
-- ==========================================
local function EquipWeapon()
    if not Player.Character then return end
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == _G.SelectWeapon then
            if tool:FindFirstChild("EquipEvent") then
                tool.EquipEvent:FireServer()
            end
            Player.Character.Humanoid:EquipTool(tool)
        end
    end
end

local function TweenTo(targetCFrame)
    if not _G.AutoFarm or not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = Player.Character.HumanoidRootPart
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local speed = _G.TweenSpeed
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    
    if currentTween then currentTween:Cancel() end
    
    currentTween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
    currentTween.Completed:Wait()
    currentTween = nil
end

local function CheckQuest()
    local gui = Player:FindFirstChild("PlayerGui")
    if gui and gui:FindFirstChild("Main") and gui.Main:FindFirstChild("Quest") then
        return gui.Main.Quest.Visible
    end
    return false
end

local function IsValidMob(mob)
    if not mob then return false end
    if not mob:FindFirstChild("Humanoid") then return false end
    if not mob:FindFirstChild("HumanoidRootPart") then return false end
    if mob.Humanoid.Health <= 0 then return false end
    if mob.HumanoidRootPart.Anchored then return false end
    return true
end

-- ==========================================
-- DATA: FARM LEVEL PROGRESSION
-- ==========================================
local IslandsData = {
    TikiOutpost = {
        IslandCFrame = CFrame.new(-16000, 100, 1500),
        Quests = {
            {Min = 2550, Max = 2575, Mob = "Islander", QuestName = "TikiQuest1", QuestLevel = 1, NPCCFrame = CFrame.new(-16050, 110, 1520)},
            {Min = 2575, Max = 2800, Mob = "Tiki Warrior", QuestName = "TikiQuest2", QuestLevel = 2, NPCCFrame = CFrame.new(-15900, 110, 1480)}
        }
    },
    SubmergedIsland = {
        IslandCFrame = CFrame.new(61163, 11, 1819),
        Quests = {
            {Min = 2600, Max = 9999, Mob = "Fishman", QuestName = "SubmergedQuest1", QuestLevel = 1, NPCCFrame = CFrame.new(61150, 15, 1800)}
        }
    }
}

local function GetTargetInfo()
    local targetMobs = {}
    local islandCF = nil
    local needQuest = _G.AutoQuest
    local questName, questLevel, npcCF = nil, nil, nil

    if _G.FarmMode == "Farm Bone" then
        targetMobs = {"Reborn Skeleton", "Living Zombie", "Demonic Soul"}
        islandCF = CFrame.new(-9514, 172, 6069)
        if needQuest then
            questName = "BoneQuest"
            questLevel = 2025
            npcCF = CFrame.new(-9516.99316, 172.016998, 6078.46484)
        end
    elseif _G.FarmMode == "Farm Katakuri" then
        targetMobs = {"Cake Prince", "Dough King"}
        islandCF = CFrame.new(-2100, 70, -2000)
    elseif _G.FarmMode == "Farm Level" then
        needQuest = _G.AutoQuest 
        local myLevel = Player.Data.Level.Value
        
        for _, island in pairs(IslandsData) do
            for _, q in ipairs(island.Quests) do
                if myLevel >= q.Min and myLevel <= q.Max then
                    targetMobs = {q.Mob}
                    islandCF = island.IslandCFrame
                    if needQuest then
                        questName = q.QuestName
                        questLevel = q.QuestLevel
                        npcCF = q.NPCCFrame
                    end
                    break
                end
            end
        end
    end
    
    return targetMobs, islandCF, needQuest, questName, questLevel, npcCF
end

-- ==========================================
-- NOCLIP & CHỐNG RỚT VĂNG
-- ==========================================
local AntiFall = Instance.new("BodyVelocity")
AntiFall.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
AntiFall.Velocity = Vector3.new(0, 0, 0)

RunService.Stepped:Connect(function()
    if _G.AutoFarm and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        if not Player.Character.HumanoidRootPart:FindFirstChild("AntiFall_Seorb") then
            local bv = AntiFall:Clone()
            bv.Name = "AntiFall_Seorb"
            bv.Parent = Player.Character.HumanoidRootPart
        end
    else
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Player.Character.HumanoidRootPart:FindFirstChild("AntiFall_Seorb")
            if bv then bv:Destroy() end
        end
    end
end)

-- ==========================================
-- VÒNG LẶP FARM CHÍNH
-- ==========================================
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
                EquipWeapon()
                
                local targetMobs, islandCF, needQuest, questName, questLevel, npcCF = GetTargetInfo()
                
                if needQuest and npcCF and questName then
                    if not CheckQuest() then
                        local distToNPC = (Player.Character.HumanoidRootPart.Position - npcCF.Position).Magnitude
                        if distToNPC > 10 then
                            TweenTo(npcCF)
                        else
                            RS.Remotes.CommF_:InvokeServer("StartQuest", questName, questLevel)
                            task.wait(0.5)
                        end
                        return 
                    end
                end

                local targetMob = nil
                local killAuraTargets = {}
                local allValidMobs = {}

                if workspace:FindFirstChild("Enemies") then
                    for _, mob in pairs(workspace.Enemies:GetChildren()) do
                        if IsValidMob(mob) then
                            for _, name in ipairs(targetMobs) do
                                if string.find(mob.Name, name) then
                                    table.insert(allValidMobs, mob)
                                    break
                                end
                            end
                        end
                    end
                end 

                if #allValidMobs > 0 then
                    local playerPos = Player.Character.HumanoidRootPart.Position
                    table.sort(allValidMobs, function(a, b)
                        return (a.HumanoidRootPart.Position - playerPos).Magnitude <
                               (b.HumanoidRootPart.Position - playerPos).Magnitude
                    end)
                    
                    targetMob = allValidMobs[1]
                    
                    for _, mob in ipairs(allValidMobs) do
                        local distToTarget = (mob.HumanoidRootPart.Position - targetMob.HumanoidRootPart.Position).Magnitude
                        if distToTarget <= _G.MobFarmRadius then
                            if #killAuraTargets < _G.MaxMobStack then
                                table.insert(killAuraTargets, mob)
                            end
                        end
                    end
                end

                if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                    local safePos = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, _G.SafeHeight, 0)

                    if (Player.Character.HumanoidRootPart.Position - safePos.Position).Magnitude > 150 then
                        TweenTo(safePos)
                    end

                    Player.Character.HumanoidRootPart.CFrame = safePos

                    -- LOGIC GOM QUÁI & MỞ RỘNG HITBOX MỚI
                    if _G.BringMob then
                        for _, kMob in pairs(killAuraTargets) do
                            if kMob ~= targetMob and kMob:FindFirstChild("HumanoidRootPart") and kMob:FindFirstChild("Humanoid") then
                                -- Dịch chuyển quái
                                kMob.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame
                                kMob.HumanoidRootPart.CanCollide = false
                                -- Mở rộng Hitbox để đánh trúng kể cả khi server delay/tạo ghost
                                kMob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                kMob.HumanoidRootPart.Transparency = 1 
                                
                                if kMob.HumanoidRootPart:FindFirstChild("AssemblyLinearVelocity") then
                                    kMob.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                end
                            end
                        end
                    end

                    local attackDelay = 0.05 
                    if _G.AttackSpeed == "Normal" then
                        attackDelay = 0.25
                    elseif _G.AttackSpeed == "Superfast Attack (CẢNH BÁO)" then
                        attackDelay = 0.01
                    end

                    local currentTime = tick()
                    if currentTime - lastAttackTick >= attackDelay then
                        lastAttackTick = currentTime
                        
                        local Net = RS.Modules.Net
                        if Net:FindFirstChild("RE/RegisterAttack") then
                            Net["RE/RegisterAttack"]:FireServer()
                        end

                        if Net:FindFirstChild("RE/RegisterHit") then
                            for _, kTarget in pairs(killAuraTargets) do
                                if kTarget and kTarget:FindFirstChild("HumanoidRootPart") then
                                    -- Do hitbox đã được phóng to 50x50x50, khoảng cách đánh lan được nới lỏng an toàn
                                    local distanceToPlayer = (kTarget.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                                    if distanceToPlayer <= 80 then
                                        Net["RE/RegisterHit"]:FireServer(kTarget.HumanoidRootPart)
                                    end
                                end
                            end
                        end
                    end
                else
                    if islandCF then
                        local distanceToIsland = (Player.Character.HumanoidRootPart.Position - islandCF.Position).Magnitude
                        if distanceToIsland > 1500 then
                            TweenTo(islandCF)
                        end
                    end
                end
            end)
        end
    end
end)
