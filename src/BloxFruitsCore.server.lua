--[[
	BloxFruitsCore.server.lua
	Server-side core: player data, Beli economy, fruit equipping and combat.
	Located at: ServerScriptService (regular Script)
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local FruitData = require(ReplicatedStorage:WaitForChild("FruitData"))

-- Remote events used to talk to the client.
local remotes = Instance.new("Folder")
remotes.Name = "BloxRemotes"
remotes.Parent = ReplicatedStorage

local ReplicateBeli = Instance.new("RemoteEvent")
ReplicateBeli.Name = "ReplicateBeli"
ReplicateBeli.Parent = remotes

local ReplicateFruit = Instance.new("RemoteEvent")
ReplicateFruit.Name = "ReplicateFruit"
ReplicateFruit.Parent = remotes

local ReplicateDamage = Instance.new("RemoteEvent")
ReplicateDamage.Name = "ReplicateDamage"
ReplicateDamage.Parent = remotes

local ReplicateNotify = Instance.new("RemoteEvent")
ReplicateNotify.Name = "ReplicateNotify"
ReplicateNotify.Parent = remotes

local CombatRequest = Instance.new("RemoteEvent")
CombatRequest.Name = "CombatRequest"
CombatRequest.Parent = remotes

-- Store per-player state: Beli, level, equipped fruit, XP.
local profileStore = {}
local dataStore

-- Optional: enable datastore if a key is supplied by the developer.
local DataStoreKeys = {
	Enabled = false,
	Key = "BloxFruits_Season1"
}

local function setupDataStore()
	if not DataStoreKeys.Enabled then
		return
	end
	local success, store = pcall(function()
		return DataStoreService:GetDataStore(DataStoreKeys.Key)
	end)
	if success then
		dataStore = store
	end
end

local function newProfile()
	return {
		Beli = FruitData.StartBeli,
		Level = 1,
		XP = 0,
		Equipped = "Flame"
	}
end

local function loadProfile(playerId)
	if dataStore then
		local success, data = pcall(function()
			return dataStore:GetAsync(tostring(playerId))
		end)
		if success and type(data) == "table" then
			local profile = newProfile()
			profile.Beli = data.Beli or profile.Beli
			profile.Level = data.Level or profile.Level
			profile.XP = data.XP or profile.XP
			profile.Equipped = data.Equipped or profile.Equipped
			return profile
		end
	end
	return newProfile()
end

local function saveProfile(playerId, profile)
	if not dataStore then
		return
	end
	pcall(function()
		dataStore:SetAsync(tostring(playerId), profile)
	end)
end

local function maxXPForLevel(level)
	return 100 + (level - 1) * 50
end

local function notify(player, message)
	ReplicateNotify:FireClient(player, message)
end

local function grantXP(player, profile, amount)
	profile.XP = profile.XP + amount
	while profile.XP >= maxXPForLevel(profile.Level) do
		profile.XP = profile.XP - maxXPForLevel(profile.Level)
		profile.Level = profile.Level + 1
		notify(player, "Level up! You are now level " .. profile.Level .. ".")
	end
end

Players.PlayerAdded:Connect(function(player)
	local profile = loadProfile(player.UserId)
	profileStore[player] = profile

	ReplicateBeli:FireClient(player, profile.Beli)
	ReplicateFruit:FireClient(player, profile.Equipped)
	notify(player, "Welcome, " .. player.Name .. "! Your fruit is " .. profile.Equipped .. ".")
end)

Players.PlayerRemoving:Connect(function(player)
	local profile = profileStore[player]
	if profile then
		saveProfile(player.UserId, profile)
		profileStore[player] = nil
	end
end)

-- Buy a fruit from the shop. Syntax: [FruitName]
game.Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		local profile = profileStore[player]
		if not profile then
			return
		end

		local fruitName = message:match("^%[(.-)%]$")
		if not fruitName then
			return
		end

		-- Normalize fruit name (case-insensitive)
		local fruit = nil
		for key, value in pairs(FruitData.Fruits) do
			if key:lower() == fruitName:lower() then
				fruit = { key = key, data = value }
				break
			end
		end

		if not fruit then
			notify(player, "Unknown fruit: " .. fruitName)
			return
		end

		if profile.Beli < fruit.data.Price then
			notify(player, "Not enough Beli. You need " .. fruit.data.Price .. ".")
			return
		end

		profile.Beli = profile.Beli - fruit.data.Price
		profile.Equipped = fruit.key
		ReplicateBeli:FireClient(player, profile.Beli)
		ReplicateFruit:FireClient(player, fruit.key)
		notify(player, "Equipped " .. fruit.key .. "!")
	end)
end)

-- Combat request from client: [target] attacks the target character.
CombatRequest.OnServerEvent:Connect(function(player, target)
	local profile = profileStore[player]
	if not profile then
		return
	end

	local fruit = FruitData.Fruits[profile.Equipped]
	if not fruit then
		return
	end

	local targetProfile = profileStore[target]
	if not targetProfile then
		return
	end

	-- Basic line-of-sight / distance check.
	local attacker = player.Character
	local victim = target.Character
	if not attacker or not victim then
		return
	end

	local attackPivot = attacker:GetPivot()
	local victimPivot = victim:GetPivot()
	if (attackPivot.Position - victimPivot.Position).Magnitude > 25 then
		return
	end

	local damage = FruitData.BaseDamage * fruit.Power * (1 + profile.Level / FruitData.LevelFactor)
	damage = math.floor(damage)

	-- Apply damage server-side to the victim's humanoid.
	local victimHumanoid = victim:FindFirstChildOfClass("Humanoid")
	if victimHumanoid then
		victimHumanoid:TakeDamage(damage)
	end

	ReplicateDamage:FireClient(target, damage, player.Name, fruit.DisplayName)
	ReplicateDamage:FireClient(player, damage, player.Name, fruit.DisplayName)

	-- Award XP to the attacker for a successful hit.
	grantXP(player, profile, 25)

	-- Award a bounty kill if the victim is downed.
	if victimHumanoid and victimHumanoid.Health <= 0 and _G.BloxBounty then
		_G.BloxBounty.registerKill(player)
	end
end)

setupDataStore()
print("BloxFruits Core server loaded.")
