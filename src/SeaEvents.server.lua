--[[
	SeaEvents.server.lua
	Spawns random sea events (treasure drops and boss raids)
	on a timed loop in the world.
	Located at: ServerScriptService (regular Script)
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- An invisible folder to hold spawned events.
local eventFolder = Instance.new("Folder")
eventFolder.Name = "SeaEvents"
eventFolder.Parent = Workspace

local EventInterval = 120 -- seconds between events.

local function randomPlayer()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
			return player
		end
	end
	return nil
end

-- Spawn a treasure chest model (a simple part) near a random player.
local function spawnTreasure()
	local player = randomPlayer()
	if not player then
		return
	end
	local char = player.Character
	local origin = char:GetPivot().Position

	local chest = Instance.new("Part")
	chest.Name = "TreasureChest"
	chest.Anchored = false
	chest.Size = Vector3.new(3, 2, 2)
	chest.Color = Color3.fromRGB(255, 200, 60)
	chest.Material = Enum.Material.Wood
	chest.Position = origin + Vector3.new(math.random(-30, 30), 5, math.random(-30, 30))
	chest.Parent = eventFolder

	-- Store pickup data via attributes.
	chest:SetAttribute("Beli", 200 + math.random(0, 500))

	-- Give it a simple click-to-collect behaviour using a proximity prompt.
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CollectPrompt"
	prompt.ActionText = "Collect Beli"
	prompt.MaxActivationDistance = 10
	prompt.Parent = chest

	print("[SeaEvents] A treasure chest has appeared near " .. player.Name .. ".")
end

-- Spawn a boss model (a tall red part) that harms nearby players.
local function spawnBoss()
	local player = randomPlayer()
	if not player then
		return
	end
	local char = player.Character
	local origin = char:GetPivot().Position

	local boss = Instance.new("Part")
	boss.Name = "SeaBoss"
	boss.Anchored = true
	boss.Size = Vector3.new(6, 12, 6)
	boss.Color = Color3.fromRGB(120, 10, 10)
	boss.Material = Enum.Material.Concrete
	boss.Position = origin + Vector3.new(math.random(-40, 40), 6, math.random(-40, 40))
	boss.Parent = eventFolder

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "BossPrompt"
	prompt.ActionText = "Defeat the Sea Boss"
	prompt.MaxActivationDistance = 12
	prompt.Parent = boss

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 500
	humanoid.Health = 500
	humanoid.Parent = boss

	local healthBar = Instance.new("HumanoidHealthBar")
	healthBar.Parent = boss

	print("[SeaEvents] A Sea Boss has appeared near " .. player.Name .. ".")
end

-- Handle proximity prompt triggers.
eventFolder.ChildAdded:Connect(function(child)
	local prompt = child:FindFirstChild("CollectPrompt")
	if prompt then
		prompt.Triggered:Connect(function(activator)
			local beli = child:GetAttribute("Beli") or 0
			child:Destroy()
			print("[SeaEvents] " .. activator.Name .. " collected " .. beli .. " Beli.")
		end)
	end
end)

-- Event loop.
task.spawn(function()
	task.wait(EventInterval)
	while true do
		local choice = math.random(1, 2)
		if choice == 1 then
			spawnTreasure()
		else
			spawnBoss()
		end
		task.wait(EventInterval)
	end
end)

print("Sea events system loaded.")
