local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Enemies = require(ReplicatedStorage.Shared.Enemies)
local Islands = require(ReplicatedStorage.Shared.Islands)

_G.ActiveEnemies = {}

-- Enhanced enemy visuals
local enemyVisuals = {
	goblin = { shape = "cylinder", color = Color3.fromRGB(60, 180, 60), size = Vector3.new(2, 3.5, 2), eyeColor = Color3.fromRGB(255, 50, 50), mat = Enum.Material.SmoothPlastic, accentColor = Color3.fromRGB(80, 60, 40) },
	giant_spider = { shape = "sphere", color = Color3.fromRGB(40, 80, 40), size = Vector3.new(3, 2, 3), eyeColor = Color3.fromRGB(255, 100, 0), mat = Enum.Material.Wood, accentColor = Color3.fromRGB(60, 40, 20) },
	skeleton_warrior = { shape = "cylinder", color = Color3.fromRGB(200, 200, 200), size = Vector3.new(2, 4, 2), eyeColor = Color3.fromRGB(255, 50, 50), mat = Enum.Material.SmoothPlastic, accentColor = Color3.fromRGB(120, 120, 120) },
	mummy = { shape = "cylinder", color = Color3.fromRGB(200, 180, 140), size = Vector3.new(2, 4, 2), eyeColor = Color3.fromRGB(255, 200, 100), mat = Enum.Material.Fabric, accentColor = Color3.fromRGB(160, 140, 100) },
	scorpion = { shape = "block", color = Color3.fromRGB(160, 120, 60), size = Vector3.new(3, 1.5, 2), eyeColor = Color3.fromRGB(255, 50, 50), mat = Enum.Material.SmoothPlastic, accentColor = Color3.fromRGB(120, 80, 40) },
	ice_monster = { shape = "cylinder", color = Color3.fromRGB(100, 200, 255), size = Vector3.new(2.5, 4, 2.5), eyeColor = Color3.fromRGB(200, 255, 255), mat = Enum.Material.Ice, accentColor = Color3.fromRGB(60, 140, 200) },
	fire_dragon = { shape = "cylinder", color = Color3.fromRGB(200, 60, 20), size = Vector3.new(3, 5, 3), eyeColor = Color3.fromRGB(255, 200, 50), mat = Enum.Material.SmoothPlastic, accentColor = Color3.fromRGB(255, 100, 0) },
	shadow_knight = { shape = "cylinder", color = Color3.fromRGB(30, 20, 50), size = Vector3.new(2.5, 4.5, 2.5), eyeColor = Color3.fromRGB(150, 50, 255), mat = Enum.Material.SmoothPlastic, accentColor = Color3.fromRGB(80, 30, 100) },
	-- New enemies
	bat = { shape = "sphere", color = Color3.fromRGB(60, 40, 80), size = Vector3.new(1.5, 1, 1.5), eyeColor = Color3.fromRGB(255, 50, 50), mat = Enum.Material.SmoothPlastic, accentColor = Color3.fromRGB(100, 60, 120) },
	fire_elemental = { shape = "ball", color = Color3.fromRGB(255, 120, 20), size = Vector3.new(2.5, 2.5, 2.5), eyeColor = Color3.fromRGB(255, 255, 100), mat = Enum.Material.Neon, accentColor = Color3.fromRGB(255, 200, 50) },
	golem = { shape = "block", color = Color3.fromRGB(120, 110, 100), size = Vector3.new(3.5, 4, 3.5), eyeColor = Color3.fromRGB(100, 200, 255), mat = Enum.Material.Slate, accentColor = Color3.fromRGB(80, 70, 60) },
	dark_wizard = { shape = "cylinder", color = Color3.fromRGB(50, 30, 80), size = Vector3.new(2, 4, 2), eyeColor = Color3.fromRGB(200, 50, 255), mat = Enum.Material.SmoothPlastic, accentColor = Color3.fromRGB(100, 40, 140) },
}

function addEyeGlow(part, color, enemySize)
	local eye1 = Instance.new("Part")
	eye1.Name = "EyeGlow"
	eye1.Size = Vector3.new(0.5, 0.5, 0.5)
	eye1.CFrame = part.CFrame * CFrame.new(-0.8, 0.5, enemySize.Z / 2 + 0.3)
	eye1.Anchored = false
	eye1.CanCollide = false
	eye1.Color = color
	eye1.Material = Enum.Material.Neon
	eye1.Shape = Enum.PartType.Ball
	
	local weld1 = Instance.new("WeldConstraint")
	weld1.Part0 = part
	weld1.Part1 = eye1
	weld1.Parent = eye1
	eye1.Parent = part
	
	local eye2 = eye1:Clone()
	eye2.CFrame = part.CFrame * CFrame.new(0.8, 0.5, enemySize.Z / 2 + 0.3)
	local weld2 = eye2:FindFirstChildOfClass("WeldConstraint") or Instance.new("WeldConstraint")
	weld2.Part0 = part
	weld2.Part1 = eye2
	weld2.Parent = eye2
	eye2.Parent = part
	
	for _, eye in ipairs({ eye1, eye2 }) do
		local p = Instance.new("ParticleEmitter")
		p.Rate = 10
		p.Lifetime = NumberRange.new(0.3, 0.6)
		p.Speed = NumberRange.new(0.5, 1)
		p.SpreadAngle = Vector2.new(30, 30)
		p.Color = ColorSequence.new(color)
		p.Texture = "rbxassetid://2842055869"
		p.Enabled = true
		p.Parent = eye
	end
end

-- Helper: weld a limb to the main body
function attachLimb(parent, size, offset, color, material, shape, name)
	local limb = Instance.new("Part")
	limb.Name = name or "Limb"
	limb.Size = size
	limb.CFrame = parent.CFrame * CFrame.new(offset.X, offset.Y, offset.Z)
	limb.Anchored = false
	limb.CanCollide = false
	limb.Locked = true
	limb.Color = color or parent.Color
	limb.Material = material or parent.Material
	if shape then limb.Shape = shape end
	limb.Parent = parent.Parent
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = parent
	weld.Part1 = limb
	weld.Parent = limb
	
	return limb
end

-- Create multi-part enemy body (head, legs, arms, special features)
function decorateEnemyBody(part, enemyType, enemyData, vis)
	local size = part.Size
	local col = vis.color
	local mat = vis.mat
	local isBoss = enemyData.isBoss
	local scale = isBoss and 2 or 1
	
	-- Build different body structures based on shape type
	if vis.shape == "cylinder" then
		-- Humanoid-type enemies (goblin, skeleton, mummy, etc.): add head + legs
		-- Head (sphere on top)
		local headSize = size * Vector3.new(0.5, 0.3, 0.5) * scale
		attachLimb(part, headSize, Vector3.new(0, size.Y/2 + headSize.Y/2, 0), col, mat, Enum.PartType.Ball, "Head")
		
		-- Left leg
		local legSize = Vector3.new(0.3, 0.8, 0.3) * scale
		attachLimb(part, legSize, Vector3.new(-size.X/4, -size.Y/2 - legSize.Y/2, 0), col, mat, Enum.PartType.Cylinder, "LeftLeg")
		-- Right leg
		attachLimb(part, legSize, Vector3.new(size.X/4, -size.Y/2 - legSize.Y/2, 0), col, mat, Enum.PartType.Cylinder, "RightLeg")
		
		-- Arms for specific types
		if enemyType ~= "mummy" and enemyType ~= "ice_monster" then
			local armSize = Vector3.new(0.25, 0.7, 0.25) * scale
			-- Left arm
			attachLimb(part, armSize, Vector3.new(-size.X/2 - armSize.X/2, size.Y/4, 0), col, mat, Enum.PartType.Cylinder, "LeftArm")
			-- Right arm
			attachLimb(part, armSize, Vector3.new(size.X/2 + armSize.X/2, size.Y/4, 0), col, mat, Enum.PartType.Cylinder, "RightArm")
		end
		
	elseif vis.shape == "sphere" or vis.shape == "ball" then
		-- Spider-type or floating enemies
		if enemyType == "giant_spider" or enemyType == "bat" then
			-- Add leg pairs
			for i = 1, 4 do
				local angle = (i / 4) * math.pi * 2
				local legSize = Vector3.new(0.2, 0.6, 0.2) * scale
				local legOffset = Vector3.new(math.cos(angle) * size.X/2, -size.Y/2, math.sin(angle) * size.Z/2)
				attachLimb(part, legSize, legOffset, vis.accentColor, mat, Enum.PartType.Cylinder, "Leg" .. i)
			end
		end
		
		if enemyType == "bat" then
			-- Wings
			local wingSize = Vector3.new(1.5, 0.1, 0.5) * scale
			attachLimb(part, wingSize, Vector3.new(-1, 0, 0), col, Enum.Material.Fabric, nil, "LeftWing")
			attachLimb(part, wingSize, Vector3.new(1, 0, 0), col, Enum.Material.Fabric, nil, "RightWing")
		end
		
		-- Fire elemental: no limbs, just particles
		
	elseif vis.shape == "block" then
		-- Quadruped-type enemies (scorpion) or boxy enemies (golem)
		if enemyType == "scorpion" then
			-- Tail
			local tailSize = Vector3.new(0.3, 0.5, 0.3) * scale
			local tail = attachLimb(part, tailSize, Vector3.new(0, 0.2, -size.Z/2 - tailSize.Z/2), vis.accentColor, mat, Enum.PartType.Cylinder, "Tail")
			-- Stinger
			local stingerSize = Vector3.new(0.4, 0.4, 0.4) * scale
			attachLimb(tail, stingerSize, Vector3.new(0, 0.3, -tailSize.Z/2 - 0.2), Color3.fromRGB(255, 100, 0), Enum.Material.Neon, Enum.PartType.Ball, "Stinger")
			
			-- Legs
			for i = 1, 6 do
				local angle = (i / 6) * math.pi * 2
				local legSize = Vector3.new(0.2, 0.4, 0.2) * scale
				local legOffset = Vector3.new(math.cos(angle) * size.X/2 + 0.2, -size.Y/2, math.sin(angle) * size.Z/2 + 0.2)
				attachLimb(part, legSize, legOffset, vis.accentColor, mat, Enum.PartType.Cylinder, "Leg" .. i)
			end
			
		elseif enemyType == "golem" then
			-- Head
			local headSize = Vector3.new(1.2, 0.8, 1.2) * scale
			attachLimb(part, headSize, Vector3.new(0, size.Y/2 + headSize.Y/2, 0), col, Enum.Material.Slate, Enum.PartType.Ball, "Head")
			-- Legs (sturdy)
			local legSize = Vector3.new(0.6, 0.6, 0.6) * scale
			attachLimb(part, legSize, Vector3.new(-0.8, -size.Y/2 - 0.3, 0), col, Enum.Material.Slate, Enum.PartType.Block, "LeftLeg")
			attachLimb(part, legSize, Vector3.new(0.8, -size.Y/2 - 0.3, 0), col, Enum.Material.Slate, Enum.PartType.Block, "RightLeg")
			-- Arms
			local armSize = Vector3.new(0.8, 0.5, 0.5) * scale
			attachLimb(part, armSize, Vector3.new(-size.X/2 - armSize.X/2, 0.5, 0), col, Enum.Material.Slate, Enum.PartType.Block, "LeftArm")
			attachLimb(part, armSize, Vector3.new(size.X/2 + armSize.X/2, 0.5, 0), col, Enum.Material.Slate, Enum.PartType.Block, "RightArm")
		end
	end
end

function spawnEnemyInZone(islandId, enemyType, spawnPos, index)
	local enemyData = Enemies[enemyType]
	if not enemyData then return nil end
	
	local zoneFolder = Workspace:FindFirstChild(islandId .. "_Zone")
	if not zoneFolder then return nil end
	
	local vis = enemyVisuals[enemyType] or { shape = "block", color = Color3.fromRGB(200, 50, 50), size = Vector3.new(2, 3, 2), mat = Enum.Material.SmoothPlastic, accentColor = Color3.fromRGB(150, 50, 50) }
	
	local part = Instance.new("Part")
	part.Name = enemyType .. "_" .. index
	part.Size = enemyData.isBoss and vis.size * 2 or vis.size
	part.Position = spawnPos
	part.Anchored = false
	part.CanCollide = true
	part.Locked = true
	part.Color = vis.color
	part.Material = vis.mat
	
	if vis.shape == "cylinder" then
		part.Shape = Enum.PartType.Cylinder
	elseif vis.shape == "sphere" or vis.shape == "ball" then
		part.Shape = Enum.PartType.Ball
	else
		part.Shape = Enum.PartType.Block
	end
	
	part.Parent = zoneFolder
	
	-- Build multi-part body
	decorateEnemyBody(part, enemyType, enemyData, vis)
	
	-- Eyes
	addEyeGlow(part, vis.eyeColor or Color3.fromRGB(255, 0, 0), part.Size)
	
	-- Accent band (visual distinction) - only on humanoids
	local accent = Instance.new("Part")
	accent.Name = "AccentBand"
	accent.Size = Vector3.new(part.Size.X + 0.2, 0.3, part.Size.Z + 0.2)
	accent.Position = part.Position - Vector3.new(0, part.Size.Y / 2 - 0.5, 0)
	accent.Anchored = false
	accent.CanCollide = false
	accent.Color = vis.accentColor
	accent.Material = Enum.Material.Neon
	accent.Transparency = 0.3
	local weldAccent = Instance.new("WeldConstraint")
	weldAccent.Part0 = part
	weldAccent.Part1 = accent
	weldAccent.Parent = accent
	accent.Parent = part
	
	-- Billboard nameplate
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyLabel"
	billboard.Size = UDim2.new(0, 140, 0, 50)
	billboard.StudsOffset = Vector3.new(0, part.Size.Y + 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameTag"
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = enemyData.emoji .. " " .. enemyData.name
	nameLabel.TextColor3 = enemyData.isBoss and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(255, 80, 80)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Parent = billboard
	
	local hpLabel = Instance.new("TextLabel")
	hpLabel.Name = "HPTag"
	hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
	hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = "❤️ " .. enemyData.health
	hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpLabel.Font = Enum.Font.Gotham
	hpLabel.TextScaled = true
	hpLabel.Parent = billboard
	
	-- Boss effects
	if enemyData.isBoss then
		local glow = Instance.new("SelectionBox")
		glow.Name = "BossGlow"
		glow.Adornee = part
		glow.Color3 = Color3.fromRGB(255, 200, 50)
		glow.LineThickness = 0.3
		glow.Transparency = 0.2
		glow.Parent = part
		
		local aura = Instance.new("ParticleEmitter")
		aura.Rate = 15
		aura.Lifetime = NumberRange.new(1, 2)
		aura.Speed = NumberRange.new(1, 3)
		aura.SpreadAngle = Vector2.new(360, 360)
		aura.Color = ColorSequence.new(Color3.fromRGB(255, 200, 50))
		aura.Texture = "rbxassetid://2842055869"
		aura.Enabled = true
		aura.Parent = part
		
		billboard.Size = UDim2.new(0, 200, 0, 70)
		hpLabel.TextSize = 14
		nameLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		nameLabel.Text = "👑 " .. enemyData.name
	end
	
	-- Special ambient particles for certain enemy types
	if enemyType == "fire_dragon" or enemyType == "fire_elemental" then
		local p = Instance.new("ParticleEmitter")
		p.Rate = 8
		p.Lifetime = NumberRange.new(0.8, 1.5)
		p.Speed = NumberRange.new(1, 3)
		p.SpreadAngle = Vector2.new(360, 360)
		p.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
		p.Texture = "rbxassetid://2842055869"
		p.Enabled = true
		p.Parent = part
	elseif enemyType == "ice_monster" then
		local p = Instance.new("ParticleEmitter")
		p.Rate = 6
		p.Lifetime = NumberRange.new(0.5, 1.5)
		p.Speed = NumberRange.new(0.5, 2)
		p.SpreadAngle = Vector2.new(360, 360)
		p.Color = ColorSequence.new(Color3.fromRGB(180, 220, 255))
		p.Texture = "rbxassetid://2842055869"
		p.Enabled = true
		p.Parent = part
	elseif enemyType == "shadow_knight" or enemyType == "dark_wizard" then
		local p = Instance.new("ParticleEmitter")
		p.Rate = 5
		p.Lifetime = NumberRange.new(0.5, 1)
		p.Speed = NumberRange.new(0.5, 1.5)
		p.SpreadAngle = Vector2.new(360, 360)
		p.Color = ColorSequence.new(Color3.fromRGB(80, 30, 120))
		p.Texture = "rbxassetid://2842055869"
		p.Enabled = true
		p.Parent = part
	end
	
	part:SetAttribute("EnemyType", enemyType)
	part:SetAttribute("EnemyId", part.Name)
	part:SetAttribute("IsBoss", enemyData.isBoss or false)
	part:SetAttribute("IsAlive", true)
	
	local enemyState = {
		part = part,
		enemyType = enemyType,
		data = enemyData,
		hp = enemyData.health,
		maxHp = enemyData.health,
		islandId = islandId,
		spawnPos = spawnPos,
		aggroTarget = nil,
		aggroRange = enemyData.detectRange or 20,
		attackRange = enemyData.attackRange or 4,
		attackCooldown = enemyData.attackCooldown or 2,
		lastAttack = 0,
		state = "idle",
		wanderTarget = nil,
		lastStateChange = 0,
	}
	
	_G.ActiveEnemies[part.Name] = enemyState
	return enemyState
end

function spawnIslandEnemies(islandId)
	local islandData = nil
	for _, isl in ipairs(Islands) do
		if isl.id == islandId then
			islandData = isl
			break
		end
	end
	if not islandData or not islandData.enemies then return end
	
	local zoneFolder = Workspace:FindFirstChild(islandId .. "_Zone")
	if not zoneFolder then return end
	
	local terrain = zoneFolder:FindFirstChild(islandId .. "_Terrain")
	if not terrain then return end
	
	local center = terrain.Position
	local count = 0
	local seed = 0
	
	for _, enemyType in ipairs(islandData.enemies) do
		local enemyData = Enemies[enemyType]
		if enemyData and not enemyData.isBoss then
			local spawnCount = math.random(4, 7)
			for i = 1, spawnCount do
				seed = seed + 1
				local angle = math.random() * math.pi * 2
				local radius = math.random(20, 85)
				local pos = center + Vector3.new(math.cos(angle) * radius, 3, math.sin(angle) * radius)
				spawnEnemyInZone(islandId, enemyType, pos, seed)
				count = count + 1
			end
		end
	end
	
	if islandData.boss then
		local bossType = nil
		for eType, eData in pairs(Enemies) do
			if eData.isBoss and eData.name == islandData.boss then
				bossType = eType
				break
			end
		end
		if bossType then
			seed = seed + 1
			local bossPos = center + Vector3.new(0, 3, 0)
			spawnEnemyInZone(islandId, bossType, bossPos, 999)
			count = count + 1
			-- Boss spawn effect broadcast
			local bossSpawnEvent = ReplicatedStorage:FindFirstChild("BossSpawned")
			if bossSpawnEvent then
				bossSpawnEvent:FireAllClients(bossType, center)
			end
		end
	end
	
	print("[EnemySpawner] Spawned " .. count .. " enemies in " .. islandId)
end

function clearIslandEnemies(islandId)
	local toRemove = {}
	for id, state in pairs(_G.ActiveEnemies) do
		if state.islandId == islandId then
			table.insert(toRemove, id)
		end
	end
	for _, id in ipairs(toRemove) do
		if _G.ActiveEnemies[id] and _G.ActiveEnemies[id].part then
			_G.ActiveEnemies[id].part:Destroy()
		end
		_G.ActiveEnemies[id] = nil
	end
end

function updateEnemyAI(enemyState, dt)
	if not enemyState or not enemyState.part or not enemyState.part.Parent then
		_G.ActiveEnemies[enemyState and enemyState.part and enemyState.part.Name or ""] = nil
		return
	end
	
	local part = enemyState.part
	local enemyData = enemyState.data
	
	if enemyState.hp <= 0 then
		if part.Transparency < 0.8 then
			part.Transparency = 0.8
		end
		return
	end
	
	part.Transparency = 0
	
	local closestPlayer = nil
	local closestDist = enemyState.aggroRange
	
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (root.Position - part.Position).Magnitude
				if dist < closestDist then
					local playerIsland = getPlayerIsland(player)
					if playerIsland == enemyState.islandId then
						closestDist = dist
						closestPlayer = player
					end
				end
			end
		end
	end
	
	enemyState.aggroTarget = closestPlayer
	
	if closestPlayer then
		local char = closestPlayer.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (root.Position - part.Position).Magnitude
				local direction = (root.Position - part.Position).Unit
				local moveSpeed = enemyData.speed or 16
				part.CFrame = CFrame.lookAt(part.Position, root.Position)
				if dist > enemyState.attackRange then
					part.Position = part.Position + direction * moveSpeed * dt * 0.5
				end
				
				-- Idle bobbing effect
				part.CFrame = part.CFrame * CFrame.new(0, math.sin(tick() * 3 + enemyState.lastAttack) * 0.05, 0)
				
				local now = tick()
				if dist <= enemyState.attackRange and now - enemyState.lastAttack >= enemyState.attackCooldown then
					enemyState.lastAttack = now
					-- Attack visual: flash red
					part.Color = Color3.fromRGB(255, 50, 50)
					task.delay(0.15, function()
						if part and part.Parent then
							local vis = enemyVisuals[enemyState.enemyType] or {}
							part.Color = vis.color or Color3.fromRGB(200, 50, 50)
						end
					end)
					if _G.applyEnemyDamageToPlayer then
						_G.applyEnemyDamageToPlayer(closestPlayer, enemyState.enemyType)
					end
				end
			end
		end
	else
		local distFromSpawn = (part.Position - enemyState.spawnPos).Magnitude
		if distFromSpawn > 2 then
			local direction = (enemyState.spawnPos - part.Position).Unit
			local moveSpeed = enemyData.speed or 16
			part.Position = part.Position + direction * moveSpeed * dt * 0.2
			part.CFrame = CFrame.lookAt(part.Position, enemyState.spawnPos)
			-- Idle bobbing
			part.CFrame = part.CFrame * CFrame.new(0, math.sin(tick() * 2) * 0.03, 0)
		end
	end
end

function getPlayerIsland(player)
	if not player or not player.Character then return "hub" end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return "hub" end
	
	local pos = root.Position
	for islandId, zone in pairs(_G.WorldManager and _G.WorldManager.islandZones or {}) do
		local center = zone.center
		if center and (pos - center).Magnitude < 150 then
			return islandId
		end
	end
	return "hub"
end

-- Enhanced death effect with particles and sound
function createDeathEffect(position, color, isBoss)
	local p = Instance.new("Part")
	p.Size = Vector3.new(1, 1, 1)
	p.Position = position
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 0.2
	p.Color = color
	p.Material = Enum.Material.Neon
	p.Shape = Enum.PartType.Ball
	p.Parent = workspace
	Debris:AddItem(p, 1.5)
	
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = isBoss and 80 or 40
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.Speed = NumberRange.new(3, 8)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Color = ColorSequence.new(color)
	emitter.Texture = "rbxassetid://2842055869"
	emitter.Enabled = true
	emitter.Parent = p
	task.delay(0.15, function() if emitter then emitter.Enabled = false end end)
	
	if isBoss then
		-- Bigger boss death explosion
		task.delay(0.1, function()
			for i = 1, 8 do
				local angle = (i / 8) * math.pi * 2
				local offset = Vector3.new(math.cos(angle) * 6, 0, math.sin(angle) * 6)
				local ringPart = Instance.new("Part")
				ringPart.Size = Vector3.new(1, 1, 1)
				ringPart.Position = position + offset
				ringPart.Anchored = true
				ringPart.CanCollide = false
				ringPart.Color = color
				ringPart.Material = Enum.Material.Neon
				ringPart.Shape = Enum.PartType.Ball
				ringPart.Parent = workspace
				Debris:AddItem(ringPart, 1)
			end
		end)
	end
end

_G.createDeathEffect = createDeathEffect

RunService.Heartbeat:Connect(function(dt)
	dt = math.min(dt, 0.1)
	
	for id, state in pairs(_G.ActiveEnemies) do
		task.spawn(function()
			updateEnemyAI(state, dt)
		end)
	end
end)

task.delay(2, function()
	for _, islandData in ipairs(Islands) do
		spawnIslandEnemies(islandData.id)
	end
	print("[EnemySpawner] All island enemies spawned")
end)

_G.EnemySpawner = {
	spawnIslandEnemies = spawnIslandEnemies,
	clearIslandEnemies = clearIslandEnemies,
	spawnEnemyInZone = spawnEnemyInZone,
	getPlayerIsland = getPlayerIsland,
}

print("[EnemySpawner] Loaded with enhanced visuals and ambient effects")
return _G.EnemySpawner
