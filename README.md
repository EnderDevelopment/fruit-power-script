# Blox Fruits Scripts

A collection of Roblox Studio Luau scripts for a Blox Fruits-style game. This project provides a complete server-client framework for a popular anime-inspired adventure game, including fruit purchasing and equipping, currency management, combat systems, player bounties, sea events, and data persistence. Each script is self-contained and can be placed in the Roblox Studio hierarchy as described below.

## Install

1. Open Roblox Studio and create a new place (or open your existing Blox Fruits game).
2. Insert each script into the game as described below.
3. Test the game with `F5`.

## Use

### Scripts and placement

#### `src/BloxFruitsCore.server.lua` — Server Core
Contains the server-side logic for fruits, in-game currency, and data.

**Place at:** `ServerScriptService` (as a regular Script).

#### `src/BloxFruitsClient.client.lua` — Client Core
Handles UI, local controls, and client-side visual effects.

**Place at:** `StarterPlayer > StarterPlayerScripts` (as a LocalScript).

#### `src/FruitData.server.lua` — Fruit Definitions
Config table of all fruits, their stats, prices, and visual colors. Used by the server core.

**Place at:** `ReplicatedStorage` (as a ModuleScript).

#### `src/BountyRefresh.server.lua` — Bounty System
Handles player bounties and passive stat rewards.

**Place at:** `ServerScriptService` (as a regular Script).

#### `src/SeaEvents.server.lua` — Sea Events
Spawns random sea events (treasure, bosses) on a timer.

**Place at:** `ServerScriptService` (as a regular Script).

### Required objects

After placing the scripts, create these objects in the game:

- **`ReplicatedStorage.BloxData`** (ModuleScript, leave empty) — seasonal data storage.
- **`ServerStorage.PlayerData`** (Folder, leave empty) — data store fallback.

### Gameplay features

- **Buying/equipping fruit:** type the fruit name in brackets in chat, e.g. `[Flame]` or `[Dragon]`. You start with `1000` Beli.
- **Attacking:** left-click a player character to deal damage with your equipped fruit.
- **Bounties:** awarded for downing other players (see `BountyRefresh.server.lua`); they grant passive health regen.
- **Sea events:** treasure chests and sea bosses spawn every 120 seconds (configurable in `SeaEvents.server.lua`).

All colors, prices, and stats are editable in `src/FruitData.server.lua` under the `FruitData` table. The script is fully playable without Roblox DataStore permissions; persistence is optional and must be enabled in the Roblox dashboard.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/718b764c-e55f-443c-928a-a65230d84bf7?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=718b764c-e55f-443c-928a-a65230d84bf7
