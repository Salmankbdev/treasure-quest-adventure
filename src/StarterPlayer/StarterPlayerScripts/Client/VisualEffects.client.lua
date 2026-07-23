local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Weapons = ReplicatedStorage and require(ReplicatedStorage.Shared.Weapons) or {}

-- ============ SOUND SYSTEM ============

function playSoundAtPosition(soundId, position)
	if not soundId or not position then return end
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = position
	anchor.Parent = Workspace
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.6
	sound.Parent = anchor
	sound:Play()
	Debris:AddItem(anchor, 7)
end

-- Listen for PlaySound remote from server
local playSoundRemote = ReplicatedStorage:FindFirstChild("PlaySound")
if playSoundRemote then
	playSoundRemote.OnClientEvent:Connect(function(soundId, position)
		playSoundAtPosition(soundId, position)
	end)
end

-- ============ ATTACK EFFECTS (Hit Impacts + Projectiles) ============

-- Create hit impact sparks at position based on weapon type and element
function createHitImpact(position, weaponType, isCrit)
	local colors = {
		physical = Color3.fromRGB(255, 200, 150),
		fire = Color3.fromRGB(255, 100, 50),
		dark = Color3.fromRGB(150, 50, 200),
	}
	
	-- Determine element from weapon (Weapons is cached at module scope)
	local wData = Weapons[weaponType or ""]
	local color = wData and colors[wData.element] or colors.physical
	if isCrit then color = Color3.fromRGB(255, 255, 100) end
	
	-- Impact flash
	local impact = Instance.new("Part")
	impact.Size = Vector3.new(0.8, 0.8, 0.8)
	impact.Position = position
	impact.Anchored = true
	impact.CanCollide = false
	impact.Color = color
	impact.Material = Enum.Material.Neon
	impact.Shape = Enum.PartType.Ball
	impact.Transparency = 0.1
	impact.Parent = Workspace
	Debris:AddItem(impact, 0.3)
	
	-- Spark particles
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = isCrit and 60 or 30
	emitter.Lifetime = NumberRange.new(0.2, 0.5)
	emitter.Speed = NumberRange.new(3, 8)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Color = ColorSequence.new(color)
	emitter.Texture = "rbxassetid://2842055869"
	emitter.Enabled = true
	emitter.Parent = impact
	task.delay(0.1, function() if emitter then emitter.Enabled = false end end)
	
	-- Crit ring
	if isCrit then
		createRing(position, Color3.fromRGB(255, 255, 100), 8, 3)
	end
end

-- Create weapon swing arc effect
function createSwingArc(fromPos, toPos, weaponType)
	local wData = Weapons[weaponType or ""]
	local color = Color3.fromRGB(200, 200, 255)
	if wData and wData.element == "fire" then
		color = Color3.fromRGB(255, 150, 50)
	elseif wData and wData.element == "dark" then
		color = Color3.fromRGB(120, 50, 180)
	end
	
	-- Arc trail particles
	local count = 6
	for i = 1, count do
		local t = i / count
		local pos = fromPos:Lerp(toPos, t)
		pos = pos + Vector3.new(math.sin(t * math.pi) * 2, math.sin(t * math.pi) * 1.5, 0)
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.3, 0.3, 0.3)
		p.Position = pos
		p.Anchored = true
		p.CanCollide = false
		p.Transparency = 0.2 + t * 0.3
		p.Color = color
		p.Material = Enum.Material.Neon
		p.Shape = Enum.PartType.Ball
		p.Parent = Workspace
		Debris:AddItem(p, 0.3 + t * 0.2)
	end
end

-- Listen for AttackEffect from server (broadcast to all clients)
local attackEffectRemote = ReplicatedStorage:FindFirstChild("AttackEffect")
if attackEffectRemote then
	attackEffectRemote.OnClientEvent:Connect(function(hitPosition, weaponType, attackerPosition)
		if not hitPosition then return end
		
		-- Determine if this hit is near the player (for damage number positioning)
		local char = player.Character
		local isLocalPlayerHit = false
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (hitPosition - root.Position).Magnitude
				-- Only show effects for hits near the local player
				-- This prevents effects from other islands
				if dist < 200 then
					isLocalPlayerHit = true
				end
			end
		end
		
		if not isLocalPlayerHit then return end
		
		-- Create swing arc between attacker and hit position
		if attackerPosition then
			createSwingArc(attackerPosition, hitPosition, weaponType or "sword")
		end
		
		-- Create hit impact
		createHitImpact(hitPosition, weaponType or "sword", false)
		
		-- Play hit sound locally for immediate feedback
		playSoundAtPosition("rbxassetid://160005893", hitPosition)
	end)
end

-- ============ ABILITY EFFECTS ============

local abActivated = ReplicatedStorage:FindFirstChild("AbilityActivated")
if not abActivated then
	-- If no ability activated event, the script still needs to load entirely
	-- but we don't need to return early, the AmbientWeather section still runs
end

function createExplosion(position, color, size, duration)
	local part = Instance.new("Part")
	part.Size = Vector3.new(size, size, size)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.3
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Shape = Enum.PartType.Ball
	part.Parent = workspace
	
	local emission = Instance.new("ParticleEmitter")
	emission.Rate = 50
	emission.Lifetime = NumberRange.new(0.5, 1)
	emission.Speed = NumberRange.new(5, 15)
	emission.SpreadAngle = Vector2.new(180, 180)
	emission.Color = ColorSequence.new(color)
	emission.Texture = "rbxassetid://2842055869"
	emission.Enabled = true
	emission.Parent = part
	
	Debris:AddItem(part, duration or 1.5)
	task.delay(0.1, function() if emission then emission.Enabled = false end end)
end

function createRing(position, color, count, radius)
	for i = 1, count do
		local angle = (i / count) * math.pi * 2
		local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.4, 0.4, 0.4)
		p.Position = position + offset
		p.Anchored = true
		p.CanCollide = false
		p.Transparency = 0.2
		p.Color = color
		p.Material = Enum.Material.Neon
		p.Shape = Enum.PartType.Ball
		p.Parent = workspace
		Debris:AddItem(p, 1)
	end
end

function createBeam(fromPos, toPos, color)
	local part = Instance.new("Part")
	part.Size = Vector3.new(0.3, 0.3, (fromPos - toPos).Magnitude)
	part.CFrame = CFrame.lookAt(fromPos, toPos) * CFrame.new(0, 0, -part.Size.Z / 2)
	part.Anchored = true
	part.CanCollide = false
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Transparency = 0.2
	part.Parent = workspace
	Debris:AddItem(part, 0.5)
end

function createHealGlow(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local part = Instance.new("Part")
	part.Size = Vector3.new(4, 4, 4)
	part.Position = root.Position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.5
	part.Color = Color3.fromRGB(100, 255, 100)
	part.Material = Enum.Material.Neon
	part.Shape = Enum.PartType.Ball
	part.Parent = workspace
	
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = 30
	emitter.Lifetime = NumberRange.new(0.8, 1.5)
	emitter.Speed = NumberRange.new(2, 6)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Color = ColorSequence.new(Color3.fromRGB(100, 255, 100))
	emitter.Texture = "rbxassetid://2842055869"
	emitter.Enabled = true
	emitter.Parent = part
	
	Debris:AddItem(part, 2.5)
	task.delay(0.3, function() if emitter then emitter.Enabled = false end end)
end

function createTeleportTrail(fromPos, toPos)
	local count = 8
	for i = 1, count do
		local t = i / count
		local pos = fromPos:Lerp(toPos, t)
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.8, 0.8, 0.8)
		p.Position = pos
		p.Anchored = true
		p.CanCollide = false
		p.Transparency = 0.3
		p.Color = Color3.fromRGB(80, 80, 200)
		p.Material = Enum.Material.Neon
		p.Shape = Enum.PartType.Ball
		p.Parent = workspace
		Debris:AddItem(p, 0.5 + t * 0.3)
	end
end

function createPoisonCloud(position)
	for i = 1, 6 do
		local offset = Vector3.new(math.random(-6, 6), 0.5, math.random(-6, 6))
		local p = Instance.new("Part")
		p.Size = Vector3.new(1.5, 1.5, 1.5)
		p.Position = position + offset
		p.Anchored = true
		p.CanCollide = false
		p.Transparency = 0.4
		p.Color = Color3.fromRGB(50, 200, 50)
		p.Material = Enum.Material.Neon
		p.Shape = Enum.PartType.Ball
		p.Parent = workspace
		Debris:AddItem(p, 1.5)
		
		coroutine.wrap(function()
			for i = 1, 15 do
				task.wait(0.1)
				if not p.Parent then break end
				p.Position = p.Position + Vector3.new(0, 0.3, 0)
				p.Transparency = p.Transparency + 0.04
			end
			if p and p.Parent then p:Destroy() end
		end)()
	end
end

function createBloodEffect(position)
	for i = 1, 10 do
		local offset = Vector3.new(math.random(-4, 4), math.random(0, 2), math.random(-4, 4))
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.3, 0.3, 0.3)
		p.Position = position + offset
		p.Anchored = true
		p.CanCollide = false
		p.Color = Color3.fromRGB(140, 20, 30)
		p.Material = Enum.Material.Neon
		p.Shape = Enum.PartType.Ball
		p.Parent = workspace
		Debris:AddItem(p, 1.2)
	end
end

function createSlashEffect(position, direction)
	local count = 5
	for i = 1, count do
		local t = i / count
		local pos = position + direction * t * 8
		local p = Instance.new("Part")
		p.Size = Vector3.new(0.3, 0.3, 0.3)
		p.Position = pos
		p.Anchored = true
		p.CanCollide = false
		p.Transparency = 0.2
		p.Color = Color3.fromRGB(255, 220, 150)
		p.Material = Enum.Material.Neon
		p.Shape = Enum.PartType.Ball
		p.Parent = workspace
		Debris:AddItem(p, 0.6)
	end
end

-- Listen for AbilityActivated
abActivated.OnClientEvent:Connect(function(ability)
	if not ability or not ability.effect then return end
	
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local pos = root.Position
	if not pos then return end
	
	if ability.effect == "damage_boost" then
		createExplosion(pos, Color3.fromRGB(255, 80, 80), 6, 1.5)
		createRing(pos, Color3.fromRGB(255, 150, 50), 12, 8)
		playSoundAtPosition("rbxassetid://130844619", pos)
		
	elseif ability.effect == "aoe_attack" then
		createRing(pos, Color3.fromRGB(100, 255, 100), 20, 14)
		createExplosion(pos + Vector3.new(0, 5, 0), Color3.fromRGB(80, 200, 80), 4, 1)
		playSoundAtPosition("rbxassetid://130844619", pos)
		
	elseif ability.effect == "massive_damage" then
		createExplosion(pos, Color3.fromRGB(255, 100, 0), 10, 2)
		createRing(pos, Color3.fromRGB(255, 200, 50), 16, 12)
		local dir = root.CFrame.LookVector
		createBeam(pos, pos + dir * 20, Color3.fromRGB(255, 150, 0))
		playSoundAtPosition("rbxassetid://130844619", pos)
		
	elseif ability.effect == "teleport_strike" then
		createTeleportTrail(pos, pos + root.CFrame.LookVector * 8)
		createExplosion(pos + root.CFrame.LookVector * 8, Color3.fromRGB(60, 60, 100), 5, 1)
		playSoundAtPosition("rbxassetid://130844619", pos)
		
	elseif ability.effect == "reveal_treasure" then
		createRing(pos, Color3.fromRGB(255, 200, 50), 24, 20)
		createExplosion(pos, Color3.fromRGB(255, 220, 100), 3, 1.5)
		
	elseif ability.effect == "heal_and_holy" then
		createHealGlow(char)
		createRing(pos, Color3.fromRGB(255, 255, 200), 16, 12)
		createExplosion(pos, Color3.fromRGB(255, 255, 150), 5, 1.5)
		playSoundAtPosition("rbxassetid://130844619", pos)
		
	elseif ability.effect == "thorn_vines" then
		createPoisonCloud(pos)
		createRing(pos, Color3.fromRGB(50, 180, 50), 12, 16)
		playSoundAtPosition("rbxassetid://130844619", pos)
		
	elseif ability.effect == "berserk_mode" then
		createExplosion(pos, Color3.fromRGB(180, 0, 0), 8, 2)
		createRing(pos, Color3.fromRGB(255, 50, 50), 20, 10)
		for i = 1, 10 do
			local offset = Vector3.new(math.random(-8, 8), math.random(0, 4), math.random(-8, 8))
			local p = Instance.new("Part")
			p.Size = Vector3.new(0.4, 0.4, 0.4)
			p.Position = pos + offset
			p.Anchored = true
			p.CanCollide = false
			p.Color = Color3.fromRGB(200, 30, 30)
			p.Material = Enum.Material.Neon
			p.Shape = Enum.PartType.Ball
			p.Parent = workspace
			Debris:AddItem(p, 1.2)
		end
		playSoundAtPosition("rbxassetid://130844619", pos)
		
	elseif ability.effect == "cannon_barrage" then
		createExplosion(pos, Color3.fromRGB(255, 150, 50), 12, 2)
		createRing(pos, Color3.fromRGB(255, 200, 100), 20, 18)
		for i = 1, 5 do
			local angle = (i / 5) * math.pi * 2
			local offset = Vector3.new(math.cos(angle) * 10, 0, math.sin(angle) * 10)
			task.delay(0.15 * i, function()
				createExplosion(pos + offset, Color3.fromRGB(255, 100, 0), 4, 1)
			end)
		end
		playSoundAtPosition("rbxassetid://130844619", pos)
		
	elseif ability.effect == "blade_storm" then
		local dir = root.CFrame.LookVector
		for i = 1, 5 do
			task.delay((i - 1) * 0.15, function()
				local angle = (i / 5) * math.pi * 2 - math.pi
				local offset = Vector3.new(math.cos(angle) * 4, 0.5, math.sin(angle) * 4)
				createSlashEffect(pos + offset, dir)
				createExplosion(pos + offset, Color3.fromRGB(255, 200, 150), 3, 0.8)
			end)
		end
		createRing(pos, Color3.fromRGB(255, 220, 180), 16, 12)
		playSoundAtPosition("rbxassetid://130844619", pos)
		
	elseif ability.effect == "blood_drain" then
		createExplosion(pos, Color3.fromRGB(140, 20, 40), 8, 2)
		createRing(pos, Color3.fromRGB(200, 30, 50), 14, 14)
		createBloodEffect(pos)
		for i = 1, 6 do
			local offset = Vector3.new(math.random(-5, 5), 1, math.random(-5, 5))
			local p = Instance.new("Part")
			p.Size = Vector3.new(1.5, 1.5, 1.5)
			p.Position = pos + offset
			p.Anchored = true
			p.CanCollide = false
			p.Transparency = 0.4
			p.Color = Color3.fromRGB(60, 10, 30)
			p.Material = Enum.Material.Neon
			p.Shape = Enum.PartType.Ball
			p.Parent = workspace
			Debris:AddItem(p, 1.5)
		end
		playSoundAtPosition("rbxassetid://130844619", pos)
	end
end)

-- Ambient weather effects by detecting island zones in workspace
-- Uses zone folder names (set server-side) to determine which island the player is on

-- Track which weather is currently active to avoid recreating it every frame
local currentWeatherIsland = nil

RunService.Heartbeat:Connect(function()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local pos = root.Position
	
	-- Find which island the player is closest to by checking zone folders in workspace
	local islandFound = false
	for _, zoneFolder in ipairs(Workspace:GetChildren()) do
		-- Zone folders are named like "forest_Zone", "desert_Zone", etc.
		if zoneFolder:IsA("Folder") and zoneFolder.Name:match("_Zone$") then
			local terrain = zoneFolder:FindFirstChild(zoneFolder.Name:gsub("_Zone", "") .. "_Terrain")
			if terrain then
				local dist = (pos - terrain.Position).Magnitude
				if dist < 150 then
					local islandId = zoneFolder.Name:gsub("_Zone", "")
					if currentWeatherIsland ~= islandId then
						currentWeatherIsland = islandId
						createAmbientWeather(islandId)
					end
					islandFound = true
					break
				end
			end
		end
	end
	
	if not islandFound then
		if currentWeatherIsland ~= nil then
			currentWeatherIsland = nil
			-- Clean up ambient weather
			for _, v in ipairs(workspace:GetChildren()) do
				if v.Name == "AmbientWeather" then
					v:Destroy()
				end
			end
		end
	end
end)

function createAmbientWeather(islandId)
	-- Clean up old ambient effects
	for _, v in ipairs(workspace:GetChildren()) do
		if v.Name == "AmbientWeather" then
			v:Destroy()
		end
	end
	
	local ambientPart = Instance.new("Part")
	ambientPart.Name = "AmbientWeather"
	ambientPart.Size = Vector3.new(1, 1, 1)
	ambientPart.Position = Vector3.new(0, 50, 0)
	ambientPart.Anchored = true
	ambientPart.CanCollide = false
	ambientPart.Transparency = 1
	ambientPart.Parent = Workspace
	
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(2, 5)
	emitter.Speed = NumberRange.new(2, 8)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.VelocityInheritance = 0
	emitter.Texture = "rbxassetid://2842055869"
	emitter.Enabled = true
	emitter.Parent = ambientPart
	
	if islandId == "forest" then
		emitter.Rate = 10
		emitter.Color = ColorSequence.new(Color3.fromRGB(80, 200, 80))
		emitter.Size = NumberSequence.new(0.1, 0.3)
	elseif islandId == "desert" then
		emitter.Rate = 20
		emitter.Color = ColorSequence.new(Color3.fromRGB(194, 178, 128))
		emitter.Size = NumberSequence.new(0.05, 0.15)
		emitter.Speed = NumberRange.new(5, 15)
	elseif islandId == "snow_mountain" then
		emitter.Rate = 30
		emitter.Color = ColorSequence.new(Color3.fromRGB(220, 230, 250))
		emitter.Size = NumberSequence.new(0.1, 0.3)
		emitter.Speed = NumberRange.new(1, 5)
		emitter.Lifetime = NumberRange.new(3, 8)
	elseif islandId == "volcano" then
		emitter.Rate = 15
		emitter.Color = ColorSequence.new(Color3.fromRGB(100, 50, 50))
		emitter.Size = NumberSequence.new(0.1, 0.3)
		emitter.Speed = NumberRange.new(1, 4)
	elseif islandId == "dark_castle" then
		emitter.Rate = 20
		emitter.Color = ColorSequence.new(Color3.fromRGB(40, 30, 50))
		emitter.Size = NumberSequence.new(0.2, 0.5)
		emitter.Speed = NumberRange.new(1, 3)
	elseif islandId == "crystal_cave" then
		emitter.Rate = 8
		emitter.Color = ColorSequence.new(Color3.fromRGB(150, 100, 255))
		emitter.Size = NumberSequence.new(0.05, 0.15)
	elseif islandId == "sky_temple" then
		emitter.Rate = 25
		emitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255))
		emitter.Size = NumberSequence.new(0.05, 0.15)
		emitter.Speed = NumberRange.new(8, 20)
	end
end

print("[VisualEffects] Loaded with sound system and enhanced effects")
