local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage.Shared.Config)

local Events = {
	CollectCoin = ReplicatedStorage:FindFirstChild("CollectCoin"),
	CollectGem = ReplicatedStorage:FindFirstChild("CollectGem"),
	CollectXP = ReplicatedStorage:FindFirstChild("CollectXP"),
	OpenChest = ReplicatedStorage:FindFirstChild("OpenChest"),
	CollectCrystal = ReplicatedStorage:FindFirstChild("CollectCrystal"),
	UpdateHUD = ReplicatedStorage:FindFirstChild("UpdateHUD"),
	LevelUp = ReplicatedStorage:FindFirstChild("LevelUp"),
	ChestReward = ReplicatedStorage:FindFirstChild("ChestReward"),
	CrystalCollected = ReplicatedStorage:FindFirstChild("CrystalCollected"),
	PlaySound = ReplicatedStorage:FindFirstChild("PlaySound"),
}

local function getPd(player)
	return _G.PlayerData[player.UserId]
end

local function pushHUD(player)
	local pd = getPd(player)
	if not pd or not Events.UpdateHUD then return end
	Events.UpdateHUD:FireClient(player, {
		health = pd.health, maxHealth = pd.maxHealth,
		energy = pd.energy, maxEnergy = pd.maxEnergy,
		coins = pd.coins, gems = pd.gems,
		level = pd.level, xp = pd.xp,
	})
end

local function playSoundToPlayer(player, soundId)
	if Events.PlaySound and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			Events.PlaySound:FireClient(player, soundId, root.Position)
		end
	end
end

Events.CollectCoin.OnServerEvent:Connect(function(player, amount)
	local pd = getPd(player)
	if not pd then return end
	local mult = 1
	if pd.activeEffects and pd.activeEffects.coin_multiplier then mult = pd.activeEffects.coin_multiplier end
	local earned = math.floor(amount * mult)
	pd.coins = (pd.coins or 0) + earned
	playSoundToPlayer(player, Config.Sounds.CoinCollect)
	pushHUD(player)
end)

Events.CollectGem.OnServerEvent:Connect(function(player, amount)
	local pd = getPd(player)
	if not pd then return end
	pd.gems = (pd.gems or 0) + (amount or 1)
	playSoundToPlayer(player, Config.Sounds.CrystalCollect)
	pushHUD(player)
end)

Events.CollectXP.OnServerEvent:Connect(function(player, amount)
	local pd = getPd(player)
	if not pd then return end
	pd.xp = (pd.xp or 0) + (amount or 10)
	local leveled = false
	while pd.xp >= (pd.level or 1) * 100 do
		pd.xp = pd.xp - pd.level * 100
		pd.level = (pd.level or 1) + 1
		pd.maxHealth = (pd.maxHealth or 100) + 10
		pd.health = pd.maxHealth
		leveled = true
	end
	if leveled and Events.LevelUp then
		Events.LevelUp:FireClient(player, pd.level)
		playSoundToPlayer(player, Config.Sounds.LevelUp)
	end
	pushHUD(player)
end)

Events.OpenChest.OnServerEvent:Connect(function(player, chestType)
	local pd = getPd(player)
	if not pd then return end
	local coins = math.random(20, 100)
	local gems = math.random(1, 5)
	-- Chance for bonus items
	if math.random() < 0.2 then
		gems = gems + math.random(1, 3)
	end
	pd.coins = (pd.coins or 0) + coins
	pd.gems = (pd.gems or 0) + gems
	if pd.stats then pd.stats.chestsOpened = (pd.stats.chestsOpened or 0) + 1 end
	if Events.ChestReward then Events.ChestReward:FireClient(player, coins, gems) end
	playSoundToPlayer(player, Config.Sounds.ChestOpen)
	pushHUD(player)
end)

Events.CollectCrystal.OnServerEvent:Connect(function(player, islandId, crystalName)
	local pd = getPd(player)
	if not pd then return end
	pd.crystals = pd.crystals or {}
	if pd.crystals[islandId] then return end
	pd.crystals[islandId] = crystalName
	pd.islandsUnlocked = (pd.islandsUnlocked or 1) + 1
	local islands = require(ReplicatedStorage.Shared.Islands)
	for _, isl in ipairs(islands) do
		if isl.id == islandId and isl.completionReward then
			local r = isl.completionReward
			pd.coins = (pd.coins or 0) + r.coins
			pd.gems = (pd.gems or 0) + r.gems
			pd.xp = (pd.xp or 0) + r.xp
		end
	end
	if Events.CrystalCollected then Events.CrystalCollected:FireClient(player, crystalName) end
	playSoundToPlayer(player, Config.Sounds.CrystalCollect)
	pushHUD(player)
end)

print("[RewardManager] Loaded with sound feedback")
return {}
