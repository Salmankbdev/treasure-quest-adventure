local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Enemies = require(ReplicatedStorage.Shared.Enemies)
local Weapons = require(ReplicatedStorage.Shared.Weapons)
local Characters = require(ReplicatedStorage.Shared.Characters)
local Config = require(ReplicatedStorage.Shared.Config)

local Events = {
	DealDamage = ReplicatedStorage:FindFirstChild("DealDamage"),
	EnemyHit = ReplicatedStorage:FindFirstChild("EnemyHit"),
	EnemyDamagePlayer = ReplicatedStorage:FindFirstChild("EnemyDamagePlayer"),
	UseAbility = ReplicatedStorage:FindFirstChild("UseAbility"),
	UpdateHUD = ReplicatedStorage:FindFirstChild("UpdateHUD"),
	CharacterSpawned = ReplicatedStorage:FindFirstChild("CharacterSpawned"),
	AbilityActivated = ReplicatedStorage:FindFirstChild("AbilityActivated"),
	PlayerDamaged = ReplicatedStorage:FindFirstChild("PlayerDamaged"),
	PlaySound = ReplicatedStorage:FindFirstChild("PlaySound"),
	AttackEffect = ReplicatedStorage:FindFirstChild("AttackEffect"),
}

-- Create PlaySound event for client-side sound playback
if not PlaySound then
	Events.PlaySound = Instance.new("RemoteEvent")
	Events.PlaySound.Name = "PlaySound"
	Events.PlaySound.Parent = ReplicatedStorage
end

-- Create PlayerDamaged if missing
local existingPD = ReplicatedStorage:FindFirstChild("PlayerDamaged")
if not existingPD then
	Events.PlayerDamaged = Instance.new("RemoteEvent")
	Events.PlayerDamaged.Name = "PlayerDamaged"
	Events.PlayerDamaged.Parent = ReplicatedStorage
else
	Events.PlayerDamaged = existingPD
end

function getWeaponDisplayName(weaponId, level)
	local wData = Weapons[weaponId]
	if not wData then return "Fists" end
	local tier = wData.tiers and wData.tiers[level]
	if tier then return tier.name end
	return wData.name
end

function getTieredWeaponDamage(weaponId, level)
	local wData = Weapons[weaponId]
	if not wData then return 5, 0 end
	
	local baseDamage = wData.damage
	local critChance = wData.critChance or 0
	
	if wData.tiers and wData.tiers[level] then
		baseDamage = wData.tiers[level].damage
		critChance = wData.tiers[level].critChance or critChance
	end
	
	return baseDamage, critChance
end

--- Play a sound to all players in an island (for auditory feedback)
function playGlobalSound(soundId, position)
	if not Events.PlaySound then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			Events.PlaySound:FireClient(player, soundId, position)
		end
	end
end

--- Full damage calculation
function calculateDamage(player, targetDefense)
	local pd = _G.PlayerData[player.UserId]
	if not pd then return 0, false, "normal" end
	
	local weaponId = pd.weapon
	local weaponLevel = pd.weaponLevel or 1
	
	local baseDmg, critChance = getTieredWeaponDamage(weaponId, weaponLevel)
	
	local charData = Characters[pd.character]
	local charBonus = charData and charData.baseDamage * 0.4 or 0
	
	local levelBonus = (pd.level - 1) * 2
	local total = baseDmg + charBonus + levelBonus
	
	local effects = pd.activeEffects or {}
	if effects.damage then
		total = total * effects.damage
	end
	
	local wData = Weapons[weaponId]
	if wData and wData.element == "dark" then
		total = total * 1.1
	end
	
	if targetDefense and targetDefense > 0 then
		local reduction = targetDefense / (targetDefense + 50)
		total = total * (1 - reduction)
	end
	
	local isCrit = false
	if math.random() < critChance then
		local critMulti = (wData and wData.critMultiplier) or 2
		total = total * critMulti
		isCrit = true
	end
	
	local variance = 0.9 + math.random() * 0.2
	total = total * variance
	
	return math.max(1, math.floor(total)), isCrit, (wData and wData.element) or "physical"
end

function applyDamageToEnemy(player, enemyPartName, enemyType, enemyId, damage, isCrit, element)
	if not enemyPartName then return end
	
	local enemyState = _G.ActiveEnemies and _G.ActiveEnemies[enemyPartName]
	if not enemyState then
		for id, state in pairs(_G.ActiveEnemies or {}) do
			if state.enemyType == enemyType and state.hp > 0 then
				enemyState = state
				enemyPartName = id
				break
			end
		end
	end
	if not enemyState or enemyState.hp <= 0 then return end
	
	enemyState.hp = enemyState.hp - damage
	
	-- Update HP label
	if enemyState.part and enemyState.part:FindFirstChild("EnemyLabel") then
		local billboard = enemyState.part:FindFirstChild("EnemyLabel")
		local hpLabel = billboard and billboard:FindFirstChild("HPTag")
		if hpLabel then
			local hpPercent = math.max(0, enemyState.hp / enemyState.maxHp)
			hpLabel.Text = "❤️ " .. math.max(0, enemyState.hp) .. "/" .. enemyState.maxHp
			if hpPercent < 0.25 then
				hpLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			elseif hpPercent < 0.5 then
				hpLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
			else
				hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end
	
	-- Play hit sound
	local enemyData = enemyState.data
	if enemyData and enemyData.hitSound then
		playGlobalSound(enemyData.hitSound, enemyState.part and enemyState.part.Position)
	end
	
	-- Fire EnemyHit for client damage numbers
	if Events.EnemyHit then
		Events.EnemyHit:FireAllClients(enemyPartName, damage, isCrit, element, enemyType)
	end
	
	-- Enemy died
	if enemyState.hp <= 0 then
		handleEnemyDeath(player, enemyState)
	end
end

function handleEnemyDeath(player, enemyState)
	if not enemyState then return end
	enemyState.hp = 0
	
	local pd = _G.PlayerData[player.UserId]
	local enemyData = enemyState.data
	local enemyPartName = enemyState.part and enemyState.part.Name or ""
	
	if enemyState.part then
		local deathColor = enemyState.part.Color or Color3.fromRGB(255, 100, 0)
		if _G.createDeathEffect then
			_G.createDeathEffect(enemyState.part.Position, deathColor, enemyData and enemyData.isBoss or false)
		end
		
		-- Play death sound
		if enemyData and enemyData.deathSound then
			playGlobalSound(enemyData.deathSound, enemyState.part.Position)
		end
		
		enemyState.part:SetAttribute("IsAlive", false)
		enemyState.part.Transparency = 0.8
		local billboard = enemyState.part:FindFirstChild("EnemyLabel")
		if billboard then billboard.Enabled = false end
		
		for _, child in ipairs(enemyState.part:GetChildren()) do
			if child.Name == "EyeGlow" then
				child.Transparency = 1
			end
		end
	end
	
	if pd and enemyData then
		local coinMult = 1
		if pd.activeEffects and pd.activeEffects.coin_multiplier then
			coinMult = pd.activeEffects.coin_multiplier
		end
		
		local coins = math.floor((enemyData.coinReward or 10) * coinMult)
		local bonusGems = enemyData.isBoss and math.random(3, 10) or 0
		
		pd.coins = (pd.coins or 0) + coins
		pd.gems = (pd.gems or 0) + bonusGems
		pd.stats.kills = (pd.stats.kills or 0) + 1
		
		local bossMultiplier = enemyData.isBoss and 3 or 1
		if _G.awardXP then
			_G.awardXP(player, (enemyData.xpReward or 10) * bossMultiplier)
		end
		
		local coinEvent = ReplicatedStorage:FindFirstChild("CollectCoin")
		if coinEvent then
			coinEvent:FireClient(player, coins)
		end
		
		if enemyData.isBoss then
			local crystalEvent = ReplicatedStorage:FindFirstChild("CrystalCollected")
			if crystalEvent then
				crystalEvent:FireClient(player, "Boss Defeated: " .. enemyData.name)
			end
			-- Boss kill sound
			playGlobalSound(Config.Sounds.BossDefeat, player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new())
		end
	end
	
	if enemyData and not enemyData.isBoss then
		task.delay(20, function()
			if enemyState.part and enemyState.part.Parent then
				enemyState.hp = enemyData.health
				enemyState.maxHp = enemyData.health
				enemyState.part.Transparency = 0
				enemyState.part:SetAttribute("IsAlive", true)
				enemyState.part.Position = enemyState.spawnPos
				enemyState.aggroTarget = nil
				enemyState.lastAttack = 0
				
				-- Reset accent band visibility
				for _, child in ipairs(enemyState.part:GetChildren()) do
					if child.Name == "EyeGlow" then
						child.Transparency = 0
					end
				end
				
				local billboard = enemyState.part:FindFirstChild("EnemyLabel")
				if billboard then
					billboard.Enabled = true
					local hpLabel = billboard:FindFirstChild("HPTag")
					if hpLabel then
						hpLabel.Text = "❤️ " .. enemyData.health .. "/" .. enemyData.health
						hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end
			end
		end)
	elseif enemyData and enemyData.isBoss then
		task.delay(120, function()
			if enemyState.part and enemyState.part.Parent then
				enemyState.hp = enemyData.health
				enemyState.maxHp = enemyData.health
				enemyState.part.Transparency = 0
				enemyState.part:SetAttribute("IsAlive", true)
				enemyState.part.Position = enemyState.spawnPos
				enemyState.aggroTarget = nil
				enemyState.lastAttack = 0
				local billboard = enemyState.part:FindFirstChild("EnemyLabel")
				if billboard then billboard.Enabled = true end
			end
		end)
	end
end

local SPAWN_RESPAWN_DELAY = 20

--- DEALDAMAGE: Player attacks an enemy
Events.DealDamage.OnServerEvent:Connect(function(player, enemyIdStr, _, enemyType)
	local pd = _G.PlayerData[player.UserId]
	if not pd then return end
	
	local damage, isCrit, element = calculateDamage(player, 0)
	
	-- Broadcast attack effect
	local char = player.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			Events.AttackEffect:FireAllClients(root.Position, pd.weapon or "sword", root.Position)
		end
	end
	
	-- Play sound for the attacker
	if isCrit then
		playGlobalSound(Config.Sounds.CritHit, char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or Vector3.new())
	else
		playGlobalSound(Config.Sounds.Hit, char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or Vector3.new())
	end
	
	applyDamageToEnemy(player, enemyIdStr, enemyType, nil, damage, isCrit, element)
end)

--- Shared function: apply enemy damage to a player
function _G.applyEnemyDamageToPlayer(player, enemyType)
	local pd = _G.PlayerData[player.UserId]
	if not pd then return end
	
	local enemyData = Enemies[enemyType]
	if not enemyData then return end
	
	if pd.activeEffects and pd.activeEffects.invincible then return end
	
	local diffConfig = Config.Levels[(pd.settings or {}).difficulty or "Normal"] or {}
	local baseDmg = enemyData.damage
	local dmg = math.floor(baseDmg * (diffConfig.damageMultiplier or 1))
	
	local charData = Characters[pd.character]
	local defense = charData and charData.baseDefense or 0
	if defense > 0 then
		local reduction = defense / (defense + 30)
		dmg = math.floor(dmg * (1 - reduction))
	end
	
	pd.health = math.max(0, pd.health - dmg)
	
	if Events.PlayerDamaged then
		Events.PlayerDamaged:FireClient(player, dmg, enemyType)
	end
	
	if pd.health <= 0 then
		pd.health = 0
		pd.stats.deaths = (pd.stats.deaths or 0) + 1
		
		task.wait(Config.RespawnTime or 3)
		pd.health = pd.maxHealth
		pd.energy = pd.maxEnergy
		local charData = Characters[pd.character]
		if charData and Events.CharacterSpawned then
			Events.CharacterSpawned:FireClient(player, charData)
		end
	end
	
	if Events.UpdateHUD then
		Events.UpdateHUD:FireClient(player, {
			health = pd.health, maxHealth = pd.maxHealth,
			energy = pd.energy, maxEnergy = pd.maxEnergy,
			coins = pd.coins, gems = pd.gems,
			level = pd.level, xp = pd.xp,
		})
	end
end

Events.EnemyDamagePlayer.OnServerEvent:Connect(function(player, enemyType)
	_G.applyEnemyDamageToPlayer(player, enemyType)
end)

--- USEABILITY: All character abilities
Events.UseAbility.OnServerEvent:Connect(function(player)
	local pd = _G.PlayerData[player.UserId]
	if not pd or not pd.character then return end
	
	local charData = Characters[pd.character]
	if not charData or not charData.ability then return end
	
	local energyCost = 20
	if pd.energy < energyCost then return end
	pd.energy = pd.energy - energyCost
	
	local ability = charData.ability
	pd.activeEffects = pd.activeEffects or {}
	
	-- Play ability sound
	if ability.sound then
		playGlobalSound(ability.sound, player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or Vector3.new())
	end
	
	-- Handle each ability
	if ability.effect == "damage_boost" then
		pd.activeEffects.damage = 1 + ability.value
		task.delay(ability.duration, function()
			if pd.activeEffects then pd.activeEffects.damage = nil end
		end)
		
	elseif ability.effect == "aoe_attack" then
		local aoeRange = 15
		local aoeDamage = ability.value * 10
		for id, state in pairs(_G.ActiveEnemies or {}) do
			if state.hp > 0 and state.part and state.part.Parent then
				local char = player.Character
				if char then
					local root = char:FindFirstChild("HumanoidRootPart")
					if root then
						local dist = (state.part.Position - root.Position).Magnitude
						if dist <= aoeRange then
							applyDamageToEnemy(player, id, state.enemyType, nil, aoeDamage, false, "physical")
						end
					end
				end
			end
		end
		
	elseif ability.effect == "massive_damage" then
		local nearestId, nearestDist = nil, 30
		for id, state in pairs(_G.ActiveEnemies or {}) do
			if state.hp > 0 and state.part and state.part.Parent then
				local char = player.Character
				if char then
					local root = char:FindFirstChild("HumanoidRootPart")
					if root then
						local dist = (state.part.Position - root.Position).Magnitude
						if dist < nearestDist then
							nearestDist = dist
							nearestId = id
						end
					end
				end
			end
		end
		if nearestId then
			local state = _G.ActiveEnemies[nearestId]
			applyDamageToEnemy(player, nearestId, state and state.enemyType, nil, ability.value * 25, true, "fire")
		end
		
	elseif ability.effect == "teleport_strike" then
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local nearestId, nearestState = nil, nil
				for id, state in pairs(_G.ActiveEnemies or {}) do
					if state.hp > 0 and state.part and state.part.Parent then
						local dist = (state.part.Position - root.Position).Magnitude
						if dist < 30 then
							nearestId = id
							nearestState = state
							break
						end
					end
				end
				if nearestState then
					local behind = nearestState.part.Position - nearestState.part.CFrame.LookVector * 4
					root.CFrame = CFrame.lookAt(behind, nearestState.part.Position)
					applyDamageToEnemy(player, nearestId, nearestState.enemyType, nil, ability.value * 15, true, "dark")
				end
			end
		end
		
	elseif ability.effect == "reveal_treasure" then
		-- Handled client-side
		
	elseif ability.effect == "heal_and_holy" then
		pd.health = math.min(pd.maxHealth, pd.health + math.floor(pd.maxHealth * ability.value))
		for id, state in pairs(_G.ActiveEnemies or {}) do
			if state.hp > 0 and state.part and state.part.Parent then
				local char = player.Character
				if char then
					local root = char:FindFirstChild("HumanoidRootPart")
					if root then
						local dist = (state.part.Position - root.Position).Magnitude
						if dist <= 15 then
							applyDamageToEnemy(player, id, state.enemyType, nil, 20, false, "fire")
						end
					end
				end
			end
		end
		
	elseif ability.effect == "thorn_vines" then
		for id, state in pairs(_G.ActiveEnemies or {}) do
			if state.hp > 0 and state.part and state.part.Parent then
				local char = player.Character
				if char then
					local root = char:FindFirstChild("HumanoidRootPart")
					if root then
						local dist = (state.part.Position - root.Position).Magnitude
						if dist <= 18 then
							local tickDmg = 8
							applyDamageToEnemy(player, id, state.enemyType, nil, tickDmg * 2, false, "physical")
							for tick = 1, 3 do
								task.delay(tick * 1.5, function()
									if _G.ActiveEnemies[id] and _G.ActiveEnemies[id].hp > 0 then
										applyDamageToEnemy(player, id, state.enemyType, nil, tickDmg, false, "physical")
									end
								end)
							end
						end
					end
				end
			end
		end
		
	elseif ability.effect == "berserk_mode" then
		local sacrifice = math.floor(pd.maxHealth * 0.3)
		pd.health = math.max(1, pd.health - sacrifice)
		pd.activeEffects.damage = 1 + ability.value
		pd.activeEffects.lifesteal = 0.2
		task.delay(ability.duration, function()
			if pd.activeEffects then
				pd.activeEffects.damage = nil
				pd.activeEffects.lifesteal = nil
			end
		end)
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				for id, state in pairs(_G.ActiveEnemies or {}) do
					if state.hp > 0 and state.part and state.part.Parent then
						local dist = (state.part.Position - root.Position).Magnitude
						if dist < 12 then
							applyDamageToEnemy(player, id, state.enemyType, nil, 30, true, "physical")
							break
						end
					end
				end
			end
		end
		
	elseif ability.effect == "cannon_barrage" then
		local aoeRange = 20
		local baseDmg = 25
		for id, state in pairs(_G.ActiveEnemies or {}) do
			if state.hp > 0 and state.part and state.part.Parent then
				local char = player.Character
				if char then
					local root = char:FindFirstChild("HumanoidRootPart")
					if root then
						local dist = (state.part.Position - root.Position).Magnitude
						if dist <= aoeRange then
							local falloff = 1 - (dist / aoeRange) * 0.5
							applyDamageToEnemy(player, id, state.enemyType, nil, math.floor(baseDmg * falloff), math.random() < 0.3, "physical")
						end
					end
				end
			end
		end
		
	-- NEW ABILITY: Blade Storm (Samurai)
	elseif ability.effect == "blade_storm" then
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				-- 5 rapid hits to nearby enemies
				for hit = 1, 5 do
					task.delay((hit - 1) * 0.15, function()
						for id, state in pairs(_G.ActiveEnemies or {}) do
							if state.hp > 0 and state.part and state.part.Parent then
								local dist = (state.part.Position - root.Position).Magnitude
								if dist <= 12 then
									local dmg = 10 + hit * 3
									applyDamageToEnemy(player, id, state.enemyType, nil, dmg, hit == 5 and math.random() < 0.5, "physical")
								end
							end
						end
					end)
				end
			end
		end
		
	-- NEW ABILITY: Blood Drain (Vampire)
	elseif ability.effect == "blood_drain" then
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local totalDrain = 0
				local drainRange = 16
				local drainTick = 0
				for id, state in pairs(_G.ActiveEnemies or {}) do
					if state.hp > 0 and state.part and state.part.Parent then
						local dist = (state.part.Position - root.Position).Magnitude
						if dist <= drainRange then
							drainTick = drainTick + 1
							-- Initial burst
							applyDamageToEnemy(player, id, state.enemyType, nil, 15, false, "dark")
							-- Drain over time
							for t = 1, 4 do
								task.delay(t * 0.8, function()
									if _G.ActiveEnemies[id] and _G.ActiveEnemies[id].hp > 0 then
										applyDamageToEnemy(player, id, state.enemyType, nil, 10, false, "dark")
									end
								end)
							end
						end
					end
				end
				-- Heal for 50% of initial burst
				local healAmount = 15 * drainTick * ability.value
				pd.health = math.min(pd.maxHealth, pd.health + math.floor(healAmount))
			end
		end
	end
	
	if Events.UpdateHUD then
		Events.UpdateHUD:FireClient(player, {
			health = pd.health, maxHealth = pd.maxHealth,
			energy = pd.energy, maxEnergy = pd.maxEnergy,
			coins = pd.coins, gems = pd.gems,
			level = pd.level, xp = pd.xp,
		})
	end
	
	if Events.AbilityActivated then
		Events.AbilityActivated:FireClient(player, ability)
	end
end)

print("[CombatManager] Loaded — full engine with sounds and new abilities active")
return {}
