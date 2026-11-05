--[[
	BountyRefresh.server.lua
	Bounty system: each player has a bounty that grows with PvP and grants
	passive health regen while active.
	Located at: ServerScriptService (regular Script)

	Other server scripts can award a bounty via the shared global:
		_G.BloxBounty.registerKill(player)
]]

local Players = game:GetService("Players")

local BountyPerKill = 500
local MaxBounty = 1000000

local bounties = {}

local public = {}

function public.registerKill(player)
	local p = bounties[player]
	if not p then
		return
	end
	p.Kills = p.Kills + 1
	p.Bounty = math.min(p.Bounty + BountyPerKill, MaxBounty)
	print("[Bounty] " .. player.Name .. " bounty is now " .. p.Bounty)
end

Players.PlayerAdded:Connect(function(player)
	bounties[player] = { Bounty = 0, Kills = 0 }
end)

Players.PlayerRemoving:Connect(function(player)
	bounties[player] = nil
end)

-- Passive regen while a bounty is active, runs every 5 seconds.
task.spawn(function()
	while true do
		task.wait(5)
		for player, data in pairs(bounties) do
			if data.Bounty > 0 and player.Parent then
				local char = player.Character
				if char then
					local humanoid = char:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid.Health < humanoid.MaxHealth then
						local regen = 2 + math.floor(data.Bounty / 50000)
						humanoid.Health = math.min(humanoid.Health + regen, humanoid.MaxHealth)
					end
				end
			end
		end
	end
end)

-- Share the API globally so the core combat script can award bounties.
_G.BloxBounty = public

print("Bounty system loaded.")
