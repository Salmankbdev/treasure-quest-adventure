local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.Shared.Items)
local Weapons = require(ReplicatedStorage.Shared.Weapons)
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage.Shared.Config)

local shopData = {
	items = {
		{ id = "health_potion", price = 50, currency = "coins" },
		{ id = "energy_potion", price = 40, currency = "coins" },
		{ id = "mana_potion", price = 60, currency = "coins" },
		{ id = "big_health_potion", price = 120, currency = "coins" },
		{ id = "bomb", price = 100, currency = "coins" },
		{ id = "xp_boost_potion", price = 200, currency = "gems" },
	},
	weapons = {
		{ id = "sword", price = 0, currency = "coins" },
		{ id = "bow", price = 300, currency = "coins" },
		{ id = "magic_staff", price = 500, currency = "gems" },
		{ id = "hammer", price = 400, currency = "coins" },
		{ id = "spear", price = 350, currency = "coins" },
		{ id = "dagger", price = 250, currency = "coins" },
		{ id = "axe", price = 450, currency = "coins" },
		{ id = "crossbow", price = 400, currency = "coins" },
		{ id = "whip", price = 350, currency = "coins" },
		{ id = "katana", price = 500, currency = "gems" },
		{ id = "scythe", price = 600, currency = "gems" },
		{ id = "necromancer_staff", price = 800, currency = "gems" },
	},
	upgrades = {
		{ type = "weapon", price = 200, currency = "coins" },
		{ type = "weapon", price = 500, currency = "coins" },
		{ type = "weapon", price = 1000, currency = "coins" },
		{ type = "weapon", price = 2500, currency = "coins" },
	},
}

local getShop = Instance.new("RemoteFunction")
getShop.Name = "GetShopData"
getShop.Parent = ReplicatedStorage
getShop.OnServerInvoke = function() return shopData end

local buyRemote = Instance.new("RemoteEvent")
buyRemote.Name = "BuyItem"
buyRemote.Parent = ReplicatedStorage
buyRemote.OnServerEvent:Connect(function(player, itemId, itemType)
	local pd = _G.PlayerData[player.UserId]
	if not pd then return end
	
	local hudEvent = ReplicatedStorage:FindFirstChild("UpdateHUD")
	
	if itemType == "weapon" then
		if not Weapons[itemId] then return end
		local cost = nil
		for _, w in ipairs(shopData.weapons) do
			if w.id == itemId then
				cost = w
				break
			end
		end
		if cost and cost.price > 0 then
			local c = cost.currency
			local p = cost.price
			if c == "coins" and (pd.coins or 0) < p then return end
			if c == "gems" and (pd.gems or 0) < p then return end
			if c == "coins" then pd.coins = pd.coins - p end
			if c == "gems" then pd.gems = pd.gems - p end
		end
		pd.weapon = itemId
		pd.weaponLevel = 1
		
	elseif itemType == "item" then
		local itemData = Items[itemId]
		if not itemData or not itemData.buyPrice then return end
		local bp = itemData.buyPrice
		if (pd.coins or 0) < bp then return end
		pd.coins = pd.coins - bp
		pd.inventory = pd.inventory or {}
		local found = false
		for _, invItem in ipairs(pd.inventory) do
			if invItem.id == itemId then
				invItem.count = (invItem.count or 1) + 1
				found = true
				break
			end
		end
		if not found then
			table.insert(pd.inventory, { id = itemId, count = 1 })
		end
		
	elseif itemType == "upgrade" then
		local wData = Weapons[pd.weapon]
		if not wData then return end
		local lvl = pd.weaponLevel or 1
		if lvl >= wData.maxLevel then return end
		local cost = wData.upgradeCosts
		if (pd.coins or 0) < cost.coins or (pd.gems or 0) < cost.gems then return end
		pd.coins = pd.coins - cost.coins
		pd.gems = pd.gems - cost.gems
		pd.weaponLevel = lvl + 1
	end
	
	-- Play purchase sound
	local soundEvent = ReplicatedStorage:FindFirstChild("PlaySound")
	if soundEvent and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			soundEvent:FireClient(player, Config.Sounds.Purchase, root.Position)
		end
	end
	
	if hudEvent then
		hudEvent:FireClient(player, {
			health = pd.health, maxHealth = pd.maxHealth,
			energy = pd.energy, maxEnergy = pd.maxEnergy,
			coins = pd.coins, gems = pd.gems,
			level = pd.level, xp = pd.xp,
		})
	end
end)

-- Create UseItem remote for consumable usage
local useItemEvent = Instance.new("RemoteEvent")
useItemEvent.Name = "UseItem"
useItemEvent.Parent = ReplicatedStorage
useItemEvent.OnServerEvent:Connect(function(player, itemId)
	local pd = _G.PlayerData[player.UserId]
	if not pd or not pd.inventory then return end
	
	local itemIndex = nil
	for i, invItem in ipairs(pd.inventory) do
		if invItem.id == itemId then
			itemIndex = i
			break
		end
	end
	if not itemIndex then return end
	
	local itemData = Items[itemId]
	if not itemData then return end
	
	-- Apply consumable effects
	if itemData.healAmount then
		pd.health = math.min(pd.maxHealth, pd.health + itemData.healAmount)
	elseif itemData.energyAmount then
		pd.energy = math.min(pd.maxEnergy, pd.energy + itemData.energyAmount)
	elseif itemData.damageAmount then
		-- Bomb: damage nearby enemies
		if player.Character then
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				for id, state in pairs(_G.ActiveEnemies or {}) do
					if state.hp > 0 and state.part and state.part.Parent then
						local dist = (state.part.Position - root.Position).Magnitude
						if dist <= 12 then
							if _G.CombatManager and _G.CombatManager.applyDamageToEnemy then
								_G.CombatManager.applyDamageToEnemy(player, id, state.enemyType, nil, itemData.damageAmount, false, "fire")
							end
						end
					end
				end
			end
		end
	end
	
	-- Remove consumed item
	pd.inventory[itemIndex].count = (pd.inventory[itemIndex].count or 1) - 1
	if pd.inventory[itemIndex].count <= 0 then
		table.remove(pd.inventory, itemIndex)
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
end)

print("[ShopManager] Loaded with new items and purchase sounds")
return shopData
