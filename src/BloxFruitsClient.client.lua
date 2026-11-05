--[[
	BloxFruitsClient.client.lua
	Client-side: HUD (Beli, fruit), fruit switching UI and combat controls.
	Located at: StarterPlayer > StarterPlayerScripts (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BloxRemotes")
local ReplicateBeli = remotes:WaitForChild("ReplicateBeli")
local ReplicateFruit = remotes:WaitForChild("ReplicateFruit")
local ReplicateDamage = remotes:WaitForChild("ReplicateDamage")
local ReplicateNotify = remotes:WaitForChild("ReplicateNotify")
local CombatRequest = remotes:WaitForChild("CombatRequest")

local playerGui = player:WaitForChild("PlayerGui")

-- Build a simple HUD.
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloxHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local beliLabel = Instance.new("TextLabel")
beliLabel.Name = "BeliLabel"
beliLabel.Size = UDim2.new(0, 220, 0, 30)
beliLabel.Position = UDim2.new(0, 10, 0, 10)
beliLabel.BackgroundTransparency = 1
beliLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
beliLabel.TextStrokeTransparency = 0
beliLabel.Font = Enum.Font.GothamBold
beliLabel.TextScaled = true
beliLabel.Parent = screenGui

local fruitLabel = Instance.new("TextLabel")
fruitLabel.Name = "FruitLabel"
fruitLabel.Size = UDim2.new(0, 220, 0, 30)
fruitLabel.Position = UDim2.new(0, 10, 0, 45)
fruitLabel.BackgroundTransparency = 1
fruitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fruitLabel.TextStrokeTransparency = 0
fruitLabel.Font = Enum.Font.GothamBold
fruitLabel.TextScaled = true
fruitLabel.Parent = screenGui

local helpLabel = Instance.new("TextLabel")
helpLabel.Name = "HelpLabel"
helpLabel.Size = UDim2.new(0, 420, 0, 60)
helpLabel.Position = UDim2.new(0, 10, 0, 80)
helpLabel.BackgroundTransparency = 1
helpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
helpLabel.Font = Enum.Font.Gotham
helpLabel.TextXAlignment = Enum.TextXAlignment.Left
helpLabel.TextScaled = true
helpLabel.Text = "Type [FruitName] in chat to buy/equip a fruit.\nClick an enemy to attack them. Fruit:"
helpLabel.Parent = screenGui

local FruitData = require(ReplicatedStorage:WaitForChild("FruitData"))

ReplicateBeli.OnClientEvent:Connect(function(beli)
	beliLabel.Text = "Beli: " .. tostring(beli)
end)

ReplicateFruit.OnClientEvent:Connect(function(fruitKey)
	local fruit = FruitData.Fruits[fruitKey]
	fruitLabel.Text = "Fruit: " .. (fruit and fruit.DisplayName or fruitKey)
end)

ReplicateNotify.OnClientEvent:Connect(function(message)
	print("[BloxFruits] " .. message)
end)

-- Damage popup.
local function spawnDamageText(damage, attackerName, fruitName)
	local popup = Instance.new("TextLabel")
	popup.Size = UDim2.new(0, 160, 0, 30)
	popup.BackgroundTransparency = 1
	popup.TextColor3 = Color3.fromRGB(255, 80, 80)
	popup.TextStrokeTransparency = 0
	popup.Font = Enum.Font.GothamBold
	popup.TextScaled = true
	popup.Text = "-" .. tostring(damage) .. " (" .. fruitName .. ")"
	popup.ZIndex = 5
	popup.Parent = screenGui

	local startPosition = UDim2.new(0.5, -80, 0.4, 0)
	popup.Position = startPosition
	coroutine.wrap(function()
		for i = 1, 60 do
			popup.Position = startPosition + UDim2.new(0, 0, 0, -i)
			popup.TextTransparency = i / 60
			if not popup.Parent then
				return
			end
			task.wait(1 / 60)
		end
		popup:Destroy()
	end)()
end

ReplicateDamage.OnClientEvent:Connect(function(damage, attackerName, fruitName)
	spawnDamageText(damage, attackerName, fruitName)
end)

-- Click-based combat: click a character to attack.
local function getMouseTarget()
	local m = nil
	pcall(function()
		m = player:GetMouse()
	end)
	if m and m.Target then
		return m.Target
	end
	return nil
end

local function onMouseClick(target)
	if not target then
		return
	end
	local targetChar = target.Parent
	if not targetChar then
		return
	end
	local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
	if not targetPlayer or targetPlayer == player then
		return
	end
	CombatRequest:FireServer(targetPlayer)
end

ContextActionService:BindAction(
	"AttackClick",
	function(actionName, inputState, inputObject)
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		onMouseClick(getMouseTarget())
		return Enum.ContextActionResult.Pass
	end,
	false,
	Enum.KeyCode.ButtonL
)

print("BloxFruits client loaded.")
