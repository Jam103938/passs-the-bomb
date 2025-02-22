local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local PLACE_ID = 2961583129

local function onButtonClick(option)
    if option == "Yes" then
        local player = Players.LocalPlayer

        if game.PlaceId == PLACE_ID then
            return
        end
        TeleportService:Teleport(PLACE_ID, player)
        print("Teleporting you")
    else
        print("Dont Teleport")
    end
end

local Bindable = Instance.new("BindableFunction")
Bindable.OnInvoke = onButtonClick

StarterGui:SetCore("SendNotification", {
    Title = "Alert!";
    Text = "Would you like to teleport?";
    Duration = nil;  
    Button1 = "Yes";  
    Button2 = "No";  
    Callback = Bindable;  
})
if game.PlaceId == PLACE_ID then

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Executor = identifyexecutor and identifyexecutor() or "Unknown" 
local Window = Fluent:CreateWindow({
    Title = "Made by Jaimz Version: 1.0",
    SubTitle = "Executor " ..Executor,
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

Tab:AddButton({
    Title = "Join my discord. Report Any Bugs",
    Callback = function()
        setclipboard("https://discord.gg/cuRJbSdrtZ")
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local connection

local toggleTeleport = false
local toggleMeteor = false

local function isHoldingBomb()
    if not player.Character then return false end
    local bomb = player.Character:FindFirstChild("Bomb")
    return bomb and bomb:IsA("Tool")
end

local function getRandomPlayer()
    local otherPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and not p.Character:FindFirstChild("Bomb") then
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
    local character = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

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

-- Teleport the bomb --
local TeleportToggle = Tabs.Main:AddToggle("TeleportToggle", {
    Title = "Enable Teleport",
    Description = "Toggle teleporting to random players when holding the bomb",
    Default = false,
    Callback = function(state)
        toggleTeleport = state
        toggleScript(toggleTeleport)
    end
})

-- Meteor remove -- 
local MeteorToggle = Tabs.Main:AddToggle("MeteorToggle", {
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
