--[[
	FruitData.server.lua
	A ModuleScript defining all fruits, their stats, prices and colors.
	Located at: ReplicatedStorage
]]

local FruitData = {}

-- Each fruit entry:
--   DisplayName : string shown in UI
--   Color       : Color3 used for effects and UI
--   Price       : cost in Beli
--   Power       : damage multiplier
--   Archetype   : "sword", "melee", "light", "dark", "fire", "ice", "mythical"
--   Description : short flavour text
FruitData.Fruits = {
	Chop = {
		DisplayName = "Chop",
		Color = Color3.fromRGB(120, 170, 120),
		Price = 5000,
		Power = 1.0,
		Archetype = "sword",
		Description = "A simple blade of great old times."
	},
	Spin = {
		DisplayName = "Spin",
		Color = Color3.fromRGB(180, 180, 220),
		Price = 7500,
		Power = 1.1,
		Archetype = "melee",
		Description = "A whirling wind that sends foes flying."
	},
	Flame = {
		DisplayName = "Flame",
		Color = Color3.fromRGB(255, 80, 20),
		Price = 15000,
		Power = 1.4,
		Archetype = "fire",
		Description = "Burns enemies with an endless blaze."
	},
	Ice = {
		DisplayName = "Ice",
		Color = Color3.fromRGB(120, 190, 255),
		Price = 25000,
		Power = 1.5,
		Archetype = "ice",
		Description = "Freezes the sea and your foes."
	},
	Light = {
		DisplayName = "Light",
		Color = Color3.fromRGB(255, 245, 160),
		Price = 100000,
		Power = 2.0,
		Archetype = "light",
		Description = "The fastest fruit known to man."
	},
	Dark = {
		DisplayName = "Dark",
		Color = Color3.fromRGB(90, 30, 140),
		Price = 120000,
		Power = 2.2,
		Archetype = "dark",
		Description = "A pulsing orb of eternal shadow."
	},
	Dragon = {
		DisplayName = "Dragon",
		Color = Color3.fromRGB(60, 220, 60),
		Price = 3500000,
		Power = 4.5,
		Archetype = "mythical",
		Description = "The rarest fruit of all. Legendary power."
	}
}

-- How much Beli a player starts with.
FruitData.StartBeli = 1000

-- Base damage of the equipped fruit without power scaling.
FruitData.BaseDamage = 25

-- Damage scaling per level: damage = BaseDamage * Power * (1 + level / 10)
FruitData.LevelFactor = 10

-- Passive stat gained per level of the player.
FruitData.HealthPerLevel = 10
FruitData.DamagePerLevel = 0.15

return FruitData
