local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local PLACE_ID = 2961583129  

local function onButtonClick(option)
    if option == "Yes" then
        local player = Players.LocalPlayer
        if game.PlaceId == PLACE_ID then
            return
        end
        TeleportService:Teleport(PLACE_ID, player)
    end
end

if game.PlaceId ~= PLACE_ID then
    local Bindable = Instance.new("BindableFunction")
    Bindable.OnInvoke = onButtonClick

    StarterGui:SetCore("SendNotification", {
        Title = "Alert!";
        Text = "Would you like to teleport?";
        Duration = 10;  
        Button1 = "Yes";  
        Button2 = "No";  
        Callback = Bindable;  
    })
    return
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Executor = identifyexecutor and identifyexecutor() or "Unknown"

local Window = Fluent:CreateWindow({
    Title = "Made by Jaimz Version: 1.0",
    SubTitle = "Executor " .. Executor,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}
Window:SelectTab(1)
Tabs.Main:AddButton({
    Title = "Join my Discord. Report Any Bugs",
    Callback = function()
        setclipboard("https://discord.gg/cuRJbSdrtZ")
    end
})

local toggleTeleport = false
local toggleMeteor = false
local toggleAutoCoin = false
local connection
local autoCoinConnection

local function isHoldingBomb()
    if not Players.LocalPlayer.Character then return false end
    local bomb = Players.LocalPlayer.Character:FindFirstChild("Bomb")
    return bomb and bomb:IsA("Tool")
end

local function getRandomPlayer()
    local otherPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character and not p.Character:FindFirstChild("Bomb") then
            table.insert(otherPlayers, p)
        end
    end
    if #otherPlayers > 0 then
        return otherPlayers[math.random(1, #otherPlayers)]
    end
    return nil
end

local function teleportToRandomPlayer()
    local randomPlayer = getRandomPlayer()
    if not randomPlayer then return end

    local destination = randomPlayer.Character and randomPlayer.Character:FindFirstChild("HumanoidRootPart")
    local character = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if destination and character then
        character.CFrame = destination.CFrame
    end
end

local function toggleScript(state)
    if state then
        if not connection then
            connection = RunService.Heartbeat:Connect(function()
                if isHoldingBomb() then
                    teleportToRandomPlayer()
                end
            end)
        end
    else
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end

local function RemoveMeteors()
    while toggleMeteor do
        local DisastersFolder = workspace:FindFirstChild("DisastersFolder")
        if DisastersFolder then
            for _, disaster in ipairs(DisastersFolder:GetChildren()) do
                if string.find(disaster.Name, "Meteor") then
                    disaster:Destroy()
                end
            end
        end
        task.wait(1) 
    end
end

local function getNil(name, class)
    for _, v in next, getnilinstances() do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
end

local function collectCoins()
    while toggleAutoCoin do
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()

        repeat task.wait() until character and character.Parent

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
        local folder = game:GetService("Workspace"):FindFirstChild("DisastersFolder")

        if humanoid and rootPart and folder then
            for _, coin in ipairs(folder:GetChildren()) do
                if coin:IsA("Model") and coin.Name:match("^Coin%d+$") then
                    local coinPrimaryPart = coin.PrimaryPart or coin:FindFirstChildWhichIsA("BasePart")
                    if coinPrimaryPart and getNil("Attachment", "Attachment") then
                        rootPart.CFrame = CFrame.new(coinPrimaryPart.Position)
                        task.wait(0.6)
                    end
                end
            end
        end
        task.wait(1)
    end
end

Tabs.Main:AddToggle("TeleportToggle", {
    Title = "Enable Teleport",
    Description = "Toggle teleporting to random players when holding the bomb",
    Default = false,
    Callback = function(state)
        toggleTeleport = state
        toggleScript(toggleTeleport)
    end
})

Tabs.Main:AddToggle("MeteorToggle", {
    Title = "Remove Meteors",
    Description = "Destroys all meteors in the disaster folder",
    Default = false,
    Callback = function(state)
        toggleMeteor = state
        if toggleMeteor then
            spawn(RemoveMeteors)
        end
    end
})

Tabs.Main:AddToggle("AutoCoinToggle", {
    Title = "Auto Collect Coins",
    Description = "Automatically moves to collect all coins in the game when visible",
    Default = false,
    Callback = function(state)
        toggleAutoCoin = state
        if toggleAutoCoin then
            spawn(collectCoins)
        end
    end
})
