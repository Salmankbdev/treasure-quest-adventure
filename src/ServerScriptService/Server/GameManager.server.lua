local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Characters = require(ReplicatedStorage.Shared.Characters)
local Islands = require(ReplicatedStorage.Shared.Islands)

_G.PlayerData = {}

local function createEvent(name, class)
	local e = Instance.new(class or "RemoteEvent")
	e.Name = name
	e.Parent = ReplicatedStorage
	return e
end

local Events = {
	SelectCharacter = createEvent("SelectCharacter"),
	CharacterSpawned = createEvent("CharacterSpawned"),
	UpdateHUD = createEvent("UpdateHUD"),
	LevelUp = createEvent("LevelUp"),
	ChestReward = createEvent("ChestReward"),
	CrystalCollected = createEvent("CrystalCollected"),
	AbilityActivated = createEvent("AbilityActivated"),
	CollectCoin = createEvent("CollectCoin"),
	CollectGem = createEvent("CollectGem"),
	CollectXP = createEvent("CollectXP"),
	OpenChest = createEvent("OpenChest"),
	CollectCrystal = createEvent("CollectCrystal"),
	DealDamage = createEvent("DealDamage"),
	EnemyHit = createEvent("EnemyHit"),
	EnemyDamagePlayer = createEvent("EnemyDamagePlayer"),
	UseAbility = createEvent("UseAbility"),
	RequestRespawn = createEvent("RequestRespawn"),
	TeleportToIsland = createEvent("TeleportToIsland"),
	PlaySound = createEvent("PlaySound"),
	BossSpawned = Instance.new("RemoteEvent"),
	PlayerDamaged = createEvent("PlayerDamaged"),
}
Events.BossSpawned.Name = "BossSpawned"
Events.BossSpawned.Parent = ReplicatedStorage
Events.AttackEffect = createEvent("AttackEffect")

function createPlayerData()
	return {
		character = nil,
		weapon = nil,
		weaponLevel = 1,
		health = 100, maxHealth = 100,
		energy = 100, maxEnergy = 100,
		coins = 0, gems = 0, xp = 0, level = 1,
		crystals = {},
		islandsUnlocked = 1,
		inventory = {},
		powerups = {},
		activeEffects = {},
		stats = { deaths = 0, kills = 0, chestsOpened = 0, puzzlesSolved = 0 },
		settings = { difficulty = "Normal" },
	}
end

function spawnCharacter(player, charId)
	local charData = Characters[charId]
	if not charData then return end
	local pd = _G.PlayerData[player.UserId]
	if not pd then return end
	pd.character = charId
	pd.maxHealth = charData.baseHealth
	pd.health = charData.baseHealth
	pd.maxEnergy = charData.baseEnergy
	pd.energy = charData.baseEnergy
	pd.weapon = charData.weapon or charData.weaponId
	pd.weaponLevel = 1
	Events.CharacterSpawned:FireClient(player, charData)
	local hudData = { health = pd.health, maxHealth = pd.maxHealth, energy = pd.energy, maxEnergy = pd.maxEnergy, coins = pd.coins, gems = pd.gems, level = pd.level, xp = pd.xp }
	Events.UpdateHUD:FireClient(player, hudData)
end

Events.SelectCharacter.OnServerEvent:Connect(function(player, charId)
	spawnCharacter(player, charId)
end)

local getIslands = Instance.new("RemoteFunction")
getIslands.Name = "GetIslands"
getIslands.Parent = ReplicatedStorage
getIslands.OnServerInvoke = function() return Islands end

Players.PlayerAdded:Connect(function(player)
	_G.PlayerData[player.UserId] = createPlayerData()
end)

Players.PlayerRemoving:Connect(function(player)
	_G.PlayerData[player.UserId] = nil
end)

-- Island teleportation
Events.TeleportToIsland.OnServerEvent:Connect(function(player, islandId)
	local pd = _G.PlayerData[player.UserId]
	if not pd then return end
	
	local islandData = nil
	for _, isl in ipairs(Islands) do
		if isl.id == islandId then
			islandData = isl
			break
		end
	end
	if not islandData then return end
	
	local requiredCount = islandData.requiredCrystals or 0
	local playerCrystals = 0
	if pd.crystals then
		for _, _ in pairs(pd.crystals) do
			playerCrystals = playerCrystals + 1
		end
	end
	if playerCrystals < requiredCount then
		warn("[GameManager] " .. player.Name .. " doesn't have enough crystals for " .. islandId)
		return
	end
	
	local char = player.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local zoneFolder = Workspace:FindFirstChild(islandId .. "_Zone")
			if zoneFolder then
				local terrain = zoneFolder:FindFirstChild(islandId .. "_Terrain")
				if terrain then
					local spawnPos = terrain.Position + Vector3.new(0, 5, 0)
					root.CFrame = CFrame.new(spawnPos)
					
					if _G.WorldManager and _G.WorldManager.applyIslandEnvironment then
						_G.WorldManager.applyIslandEnvironment(islandId)
					end
					
					-- Play teleport sound
					if Events.PlaySound then
						Events.PlaySound:FireClient(player, "rbxassetid://161006044", spawnPos)
					end
					
					print("[GameManager] Teleported " .. player.Name .. " to " .. islandId)
				end
			end
		end
	end
end)

-- Respawn to hub
Events.RequestRespawn.OnServerEvent:Connect(function(player)
	local pd = _G.PlayerData[player.UserId]
	if pd then
		pd.health = pd.maxHealth
		pd.energy = pd.maxEnergy
		local charData = Characters[pd.character]
		if charData then
			Events.CharacterSpawned:FireClient(player, charData)
		end
		if _G.WorldManager and _G.WorldManager.resetToHubLighting then
			_G.WorldManager.resetToHubLighting()
		end
	end
end)

-- Shared level-up utility
function _G.awardXP(player, amount)
	local pd = _G.PlayerData[player.UserId]
	if not pd then return false end
	
	pd.xp = (pd.xp or 0) + (amount or 0)
	local leveled = false
	while pd.xp >= (pd.level or 1) * 100 do
		pd.xp = pd.xp - pd.level * 100
		pd.level = (pd.level or 1) + 1
		pd.maxHealth = (pd.maxHealth or 100) + 10
		pd.maxEnergy = (pd.maxEnergy or 100) + 5
		pd.health = pd.maxHealth
		leveled = true
	end
	
	local hudEvent = ReplicatedStorage:FindFirstChild("UpdateHUD")
	if hudEvent then
		hudEvent:FireClient(player, {
			health = pd.health, maxHealth = pd.maxHealth,
			energy = pd.energy, maxEnergy = pd.maxEnergy,
			coins = pd.coins, gems = pd.gems,
			level = pd.level, xp = pd.xp,
		})
	end
	if leveled then
		local lvlEvent = ReplicatedStorage:FindFirstChild("LevelUp")
		if lvlEvent then lvlEvent:FireClient(player, pd.level) end
		-- Play level-up sound
		if Events.PlaySound then
			local char = player.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				if root then
					Events.PlaySound:FireClient(player, "rbxassetid://138232555", root.Position)
				end
			end
		end
	end
	return leveled
end

_G.GameEvents = Events

local function safeRequire(name)
	local mod = script.Parent:FindFirstChild(name)
	if not mod then
		warn("[GameManager] Module not found: " .. name)
		return nil
	end
	local success, result = pcall(function() return require(mod) end)
	if success then
		print("[GameManager] Loaded: " .. name)
	else
		warn("[GameManager] FAILED to load " .. name .. ": " .. tostring(result))
	end
	return result
end

safeRequire("WorldManager")
safeRequire("CombatManager")
safeRequire("RewardManager")
safeRequire("ShopManager")
safeRequire("EnemySpawner")

-- Ensure PlayerDamaged exists
if not ReplicatedStorage:FindFirstChild("PlayerDamaged") then
	local pEvent = Instance.new("RemoteEvent")
	pEvent.Name = "PlayerDamaged"
	pEvent.Parent = ReplicatedStorage
end

print("[Treasure Quest] All systems initialized")
