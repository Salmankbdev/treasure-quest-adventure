local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local Islands = require(ReplicatedStorage.Shared.Islands)
local Config = require(ReplicatedStorage.Shared.Config)

_G.WorldManager = _G.WorldManager or {}
local islandZones = {}

-- Cache mesh assets from packs for decoration
local assetMeshes = {}
local function cacheAssetMeshes()
	local assetsFolder = ReplicatedStorage:FindFirstChild("Assets")
	if not assetsFolder then return end
	for _, pack in ipairs(assetsFolder:GetChildren()) do
		local function scan(inst)
			if inst:IsA("MeshPart") then
				local name = inst.Name:lower()
				if name:find("tree") or name:find("pine") or name:find("beech") or name:find("birch") then
					table.insert(assetMeshes, { inst = inst, type = "tree" })
				elseif name:find("rock") or name:find("boulder") or name:find("stone") then
					table.insert(assetMeshes, { inst = inst, type = "rock" })
				elseif name:find("bush") or name:find("shrub") or name:find("hedge") then
					table.insert(assetMeshes, { inst = inst, type = "bush" })
				elseif name:find("flower") or name:find("mushroom") or name:find("plant") then
					table.insert(assetMeshes, { inst = inst, type = "flower" })
				elseif name:find("pillar") or name:find("column") or name:find("obelisk") then
					table.insert(assetMeshes, { inst = inst, type = "pillar" })
				end
			end
			for _, child in ipairs(inst:GetChildren()) do
				scan(child)
			end
		end
		scan(pack)
	end
	print("[WorldManager] Cached " .. #assetMeshes .. " mesh assets")
end
cacheAssetMeshes()

local function getAssetByType(meshType)
	local matches = {}
	for _, entry in ipairs(assetMeshes) do
		if entry.type == meshType then
			table.insert(matches, entry.inst)
		end
	end
	if #matches > 0 then
		return matches[math.random(#matches)]
	end
	return nil
end

-- Skybox asset IDs per island theme
local skyboxes = {
	forest = {
		bk = "rbxassetid://159356387",
		dn = "rbxassetid://159356387",
		ft = "rbxassetid://159356387",
		lf = "rbxassetid://159356387",
		rt = "rbxassetid://159356387",
		up = "rbxassetid://159356387",
	},
	desert = {
		bk = "rbxassetid://159356387",
		dn = "rbxassetid://159356387",
		ft = "rbxassetid://159356387",
		lf = "rbxassetid://159356387",
		rt = "rbxassetid://159356387",
		up = "rbxassetid://159356387",
	},
	snow_mountain = {
		bk = "rbxassetid://159356387",
		dn = "rbxassetid://159356387",
		ft = "rbxassetid://159356387",
		lf = "rbxassetid://159356387",
		rt = "rbxassetid://159356387",
		up = "rbxassetid://159356387",
	},
	volcano = {
		bk = "rbxassetid://159356387",
		dn = "rbxassetid://159356387",
		ft = "rbxassetid://159356387",
		lf = "rbxassetid://159356387",
		rt = "rbxassetid://159356387",
		up = "rbxassetid://159356387",
	},
	dark_castle = {
		bk = "rbxassetid://159356387",
		dn = "rbxassetid://159356387",
		ft = "rbxassetid://159356387",
		lf = "rbxassetid://159356387",
		rt = "rbxassetid://159356387",
		up = "rbxassetid://159356387",
	},
	crystal_cave = {
		bk = "rbxassetid://159356387",
		dn = "rbxassetid://159356387",
		ft = "rbxassetid://159356387",
		lf = "rbxassetid://159356387",
		rt = "rbxassetid://159356387",
		up = "rbxassetid://159356387",
	},
	sky_temple = {
		bk = "rbxassetid://159356387",
		dn = "rbxassetid://159356387",
		ft = "rbxassetid://159356387",
		lf = "rbxassetid://159356387",
		rt = "rbxassetid://159356387",
		up = "rbxassetid://159356387",
	},
}

function createIslandZone(islandData, index)
	local zoneFolder = Instance.new("Folder")
	zoneFolder.Name = islandData.id .. "_Zone"
	zoneFolder.Parent = Workspace
	
	local offsetX = (index - 1) * 600
	local islandCenter = Vector3.new(offsetX, 0, 0)
	
	-- Main terrain platform
	local terrain = Instance.new("Part")
	terrain.Name = islandData.id .. "_Terrain"
	terrain.Size = Vector3.new(200, 10, 200)
	terrain.Position = islandCenter + Vector3.new(0, -5, 0)
	terrain.Anchored = true
	terrain.Locked = true
	
	if islandData.id == "forest" then
		terrain.Material = Enum.Material.Grass
		terrain.Color = Color3.fromRGB(40, 120, 40)
	elseif islandData.id == "desert" then
		terrain.Material = Enum.Material.Sand
		terrain.Color = Color3.fromRGB(194, 178, 128)
	elseif islandData.id == "snow_mountain" then
		terrain.Material = Enum.Material.Snow
		terrain.Color = Color3.fromRGB(220, 230, 245)
	elseif islandData.id == "volcano" then
		terrain.Material = Enum.Material.Slate
		terrain.Color = Color3.fromRGB(60, 40, 40)
	elseif islandData.id == "dark_castle" then
		terrain.Material = Enum.Material.Slate
		terrain.Color = Color3.fromRGB(25, 20, 35)
	elseif islandData.id == "crystal_cave" then
		terrain.Material = Enum.Material.Slate
		terrain.Color = Color3.fromRGB(30, 25, 45)
	elseif islandData.id == "sky_temple" then
		terrain.Material = Enum.Material.Limestone
		terrain.Color = Color3.fromRGB(160, 150, 140)
	end
	terrain.Parent = zoneFolder
	
	-- Portal / entrance marker
	local portal = Instance.new("Part")
	portal.Name = islandData.id .. "_Portal"
	portal.Size = Vector3.new(16, 4, 16)
	portal.Position = islandCenter + Vector3.new(0, 2, 110)
	portal.Anchored = true
	portal.CanCollide = false
	portal.Transparency = 0.3
	portal.Color = Color3.fromRGB(100, 100, 255)
	portal.Material = Enum.Material.Neon
	portal.Parent = zoneFolder
	
	local portalNameTag = Instance.new("BillboardGui")
	portalNameTag.Name = "PortalLabel"
	portalNameTag.Size = UDim2.new(0, 200, 0, 50)
	portalNameTag.StudsOffset = Vector3.new(0, 6, 0)
	portalNameTag.AlwaysOnTop = true
	portalNameTag.Parent = portal
	
	local portalLabel = Instance.new("TextLabel")
	portalLabel.Size = UDim2.new(1, 0, 1, 0)
	portalLabel.BackgroundTransparency = 1
	portalLabel.Text = islandData.emoji .. " " .. islandData.name .. " [" .. islandData.difficulty .. "]"
	portalLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	portalLabel.TextScaled = true
	portalLabel.Font = Enum.Font.GothamBold
	portalLabel.Parent = portalNameTag
	portal:SetAttribute("PortalId", islandData.id)
	portal:SetAttribute("PortalDifficulty", islandData.difficulty)
	
	-- Decorate island with theme-appropriate objects
	decorateIsland(islandData.id, islandCenter)
	
	islandZones[islandData.id] = {
		folder = zoneFolder,
		center = islandCenter,
		env = islandData.environment,
	}
	
	print("[WorldManager] Created zone: " .. islandData.name)
end

function decorateIsland(islandId, center)
	if islandId == "forest" then
		-- Forest trees
		for i = 1, 15 do
			local angle = math.random() * math.pi * 2
			local radius = 10 + math.random() * 80
			decorateTree(center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius), nil, Color3.fromRGB(40, 140, 40))
		end
		-- Forest bushes
		for i = 1, 8 do
			local angle = math.random() * math.pi * 2
			local radius = 15 + math.random() * 70
			decorateBush(center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius))
		end
		-- Forest rocks
		for i = 1, 6 do
			local angle = math.random() * math.pi * 2
			local radius = 20 + math.random() * 70
			decorateRock(center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius))
		end
		-- Flowers
		for i = 1, 12 do
			local angle = math.random() * math.pi * 2
			local radius = 5 + math.random() * 85
			decorateFlower(center + Vector3.new(math.cos(angle) * radius, 0.5, math.sin(angle) * radius))
		end
		
	elseif islandId == "desert" then
		-- Desert pillars
		for i = 1, 8 do
			local angle = math.random() * math.pi * 2
			local radius = 20 + math.random() * 70
			decoratePillar(center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius))
		end
		-- Desert rocks
		for i = 1, 10 do
			local angle = math.random() * math.pi * 2
			local radius = 10 + math.random() * 80
			local size = 1.5 + math.random() * 3
			local rock = Instance.new("Part")
			rock.Name = "DesertRock"
			rock.Size = Vector3.new(size, size * 0.5, size)
			rock.Position = center + Vector3.new(math.cos(angle) * radius, 0.5, math.sin(angle) * radius)
			rock.Anchored = true
			rock.Locked = true
			rock.Color = Color3.fromRGB(160 + math.random(40), 140 + math.random(30), 100 + math.random(30))
			rock.Material = Enum.Material.Sandstone
			rock.Shape = Enum.PartType.Ball
			rock.Parent = workspace
		end
		-- Cacti
		for i = 1, 6 do
			local angle = math.random() * math.pi * 2
			local radius = 15 + math.random() * 75
			local pos = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local trunk = Instance.new("Part")
			trunk.Name = "Cactus"
			trunk.Size = Vector3.new(0.8, 2 + math.random() * 2, 0.8)
			trunk.Position = pos + Vector3.new(0, 1 + math.random(), 0)
			trunk.Anchored = true
			trunk.Locked = true
			trunk.Color = Color3.fromRGB(50, 140, 50)
			trunk.Material = Enum.Material.SmoothPlastic
			trunk.Parent = workspace
		end
		
	elseif islandId == "snow_mountain" then
		-- Snowy pine trees
		for i = 1, 12 do
			local angle = math.random() * math.pi * 2
			local radius = 10 + math.random() * 80
			local pos = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local trunk = Instance.new("Part")
			trunk.Name = "SnowTreeTrunk"
			trunk.Size = Vector3.new(0.5, 3, 0.5)
			trunk.Position = pos + Vector3.new(0, 1.5, 0)
			trunk.Anchored = true
			trunk.Locked = true
			trunk.Color = Color3.fromRGB(80, 60, 40)
			trunk.Material = Enum.Material.Wood
			trunk.Parent = workspace
			local foliage = Instance.new("Part")
			foliage.Name = "SnowTreeFoliage"
			foliage.Size = Vector3.new(4, 3, 4)
			foliage.Position = pos + Vector3.new(0, 4.5, 0)
			foliage.Anchored = true
			foliage.Locked = true
			foliage.Color = Color3.fromRGB(200, 215, 230)
			foliage.Material = Enum.Material.Snow
			foliage.Shape = Enum.PartType.Ball
			foliage.Parent = workspace
		end
		-- Ice crystals
		for i = 1, 8 do
			local angle = math.random() * math.pi * 2
			local radius = 15 + math.random() * 75
			local pos = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local crystal = Instance.new("Part")
			crystal.Name = "IceCrystal"
			crystal.Size = Vector3.new(0.6, 1.5 + math.random(), 0.6)
			crystal.Position = pos + Vector3.new(0, 0.75 + math.random() * 0.5, 0)
			crystal.Anchored = true
			crystal.Locked = true
			crystal.Color = Color3.fromRGB(180, 220, 255)
			crystal.Material = Enum.Material.Ice
			crystal.Parent = workspace
			-- Glow particle
			local p = Instance.new("ParticleEmitter")
			p.Rate = 3
			p.Lifetime = NumberRange.new(0.5, 1)
			p.Speed = NumberRange.new(0.5, 1.5)
			p.SpreadAngle = Vector2.new(30, 30)
			p.Color = ColorSequence.new(Color3.fromRGB(180, 220, 255))
			p.Texture = "rbxassetid://2842055869"
			p.Enabled = true
			p.Parent = crystal
		end
		
	elseif islandId == "volcano" then
		-- Lava pools
		for i = 1, 5 do
			local angle = math.random() * math.pi * 2
			local radius = 15 + math.random() * 60
			local pos = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local lava = Instance.new("Part")
			lava.Name = "LavaPool"
			lava.Size = Vector3.new(6 + math.random() * 4, 0.5, 5 + math.random() * 4)
			lava.Position = pos + Vector3.new(0, -0.25, 0)
			lava.Anchored = true
			lava.Locked = true
			lava.Color = Color3.fromRGB(255, 100, 0)
			lava.Material = Enum.Material.Neon
			lava.Parent = workspace
			-- Lava particles
			local p = Instance.new("ParticleEmitter")
			p.Rate = 10
			p.Lifetime = NumberRange.new(0.5, 1.5)
			p.Speed = NumberRange.new(1, 2)
			p.SpreadAngle = Vector2.new(30, 30)
			p.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
			p.Texture = "rbxassetid://2842055869"
			p.Enabled = true
			p.Parent = lava
		end
		-- Volcanic rocks
		for i = 1, 12 do
			local angle = math.random() * math.pi * 2
			local radius = 10 + math.random() * 80
			local size = 1 + math.random() * 2.5
			local rock = Instance.new("Part")
			rock.Name = "VolcanicRock"
			rock.Size = Vector3.new(size, size * 0.7, size)
			rock.Position = center + Vector3.new(math.cos(angle) * radius, 0.5, math.sin(angle) * radius)
			rock.Anchored = true
			rock.Locked = true
			rock.Color = Color3.fromRGB(40 + math.random(20), 30 + math.random(20), 30 + math.random(20))
			rock.Material = Enum.Material.Slate
			rock.Shape = Enum.PartType.Ball
			rock.Parent = workspace
		end
		
	elseif islandId == "dark_castle" then
		-- Castle walls
		for i = 1, 8 do
			local angle = (i / 8) * math.pi * 2
			local radius = 40
			local wall = Instance.new("Part")
			wall.Name = "CastleWall"
			wall.Size = Vector3.new(2, 8, 15)
			wall.Position = center + Vector3.new(math.cos(angle) * radius, 4, math.sin(angle) * radius)
			wall.Anchored = true
			wall.Locked = true
			wall.Color = Color3.fromRGB(40, 35, 50)
			wall.Material = Enum.Material.Slate
			wall.CFrame = CFrame.lookAt(wall.Position, center)
			wall.Parent = workspace
			-- Torches on walls
			if i % 2 == 0 then
				decorateTorch(wall.Position + Vector3.new(0, 4, 2))
			end
		end
		-- Dark pillars
		for i = 1, 6 do
			local angle = math.random() * math.pi * 2
			local radius = 20 + math.random() * 30
			decoratePillar(center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius))
		end
		-- Floor torches
		for i = 1, 4 do
			local angle = (i / 4) * math.pi * 2
			decorateTorch(center + Vector3.new(math.cos(angle) * 25, 0, math.sin(angle) * 25))
		end
		
	elseif islandId == "crystal_cave" then
		-- Large crystals
		for i = 1, 10 do
			local angle = math.random() * math.pi * 2
			local radius = 15 + math.random() * 75
			local pos = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local colors = {Color3.fromRGB(100, 200, 255), Color3.fromRGB(200, 100, 255), Color3.fromRGB(255, 200, 100), Color3.fromRGB(100, 255, 200)}
			local c = colors[math.random(#colors)]
			local height = 2 + math.random() * 4
			local crystal = Instance.new("Part")
			crystal.Name = "Crystal"
			crystal.Size = Vector3.new(0.8, height, 0.8)
			crystal.Position = pos + Vector3.new(0, height / 2, 0)
			crystal.Anchored = true
			crystal.Locked = true
			crystal.Color = c
			crystal.Material = Enum.Material.Glass
			crystal.Parent = workspace
			-- Crystal glow
			local p = Instance.new("ParticleEmitter")
			p.Rate = 5
			p.Lifetime = NumberRange.new(0.5, 1)
			p.Speed = NumberRange.new(0.5, 1.5)
			p.SpreadAngle = Vector2.new(20, 20)
			p.Color = ColorSequence.new(c)
			p.Texture = "rbxassetid://2842055869"
			p.Enabled = true
			p.Parent = crystal
		end
		-- Glowing mushrooms
		for i = 1, 8 do
			local angle = math.random() * math.pi * 2
			local radius = 20 + math.random() * 60
			local pos = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local mushroom = Instance.new("Part")
			mushroom.Name = "GlowMushroom"
			mushroom.Size = Vector3.new(1.5, 0.5, 1.5)
			mushroom.Position = pos + Vector3.new(0, 0.25, 0)
			mushroom.Anchored = true
			mushroom.Locked = true
			mushroom.Color = Color3.fromRGB(50, 200, 150)
			mushroom.Material = Enum.Material.Neon
			mushroom.Shape = Enum.PartType.Ball
			mushroom.Parent = workspace
		end
		
	elseif islandId == "sky_temple" then
		-- Floating islands / clouds
		for i = 1, 3 do
			local angle = math.random() * math.pi * 2
			local radius = 25 + math.random() * 40
			local height = 15 + math.random() * 20
			local cloud = Instance.new("Part")
			cloud.Name = "CloudPlatform"
			cloud.Size = Vector3.new(15 + math.random() * 10, 2, 12 + math.random() * 8)
			cloud.Position = center + Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
			cloud.Anchored = true
			cloud.Locked = true
			cloud.Color = Color3.fromRGB(200, 200, 220)
			cloud.Material = Enum.Material.Limestone
			cloud.Parent = workspace
			-- Cloud border glow
			local border = Instance.new("Part")
			border.Name = "CloudGlow"
			border.Size = cloud.Size + Vector3.new(3, 1, 3)
			border.Position = cloud.Position
			border.Anchored = true
			border.Locked = true
			border.Color = Color3.fromRGB(180, 180, 255)
			border.Material = Enum.Material.Neon
			border.Transparency = 0.7
			border.Parent = workspace
		end
		-- Temple pillars
		for i = 1, 6 do
			local angle = (i / 6) * math.pi * 2
			local radius = 25
			local pos = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local pillar = Instance.new("Part")
			pillar.Name = "TemplePillar"
			pillar.Size = Vector3.new(2, 10, 2)
			pillar.Position = pos + Vector3.new(0, 5, 0)
			pillar.Anchored = true
			pillar.Locked = true
			pillar.Color = Color3.fromRGB(180, 170, 150)
			pillar.Material = Enum.Material.Limestone
			pillar.Parent = workspace
		end
		-- Wind particles (ambient)
		local windEmitter = Instance.new("Part")
		windEmitter.Name = "WindParticles"
		windEmitter.Size = Vector3.new(1, 1, 1)
		windEmitter.Position = center
		windEmitter.Anchored = true
		windEmitter.CanCollide = false
		windEmitter.Transparency = 1
		windEmitter.Parent = workspace
		local p = Instance.new("ParticleEmitter")
		p.Rate = 15
		p.Lifetime = NumberRange.new(2, 4)
		p.Speed = NumberRange.new(5, 15)
		p.SpreadAngle = Vector2.new(30, 30)
		p.VelocityInheritance = 0
		p.Acceleration = Vector3.new(0, -1, 0)
		p.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255))
		p.Texture = "rbxassetid://4629858649"
		p.Enabled = true
		p.Size = NumberSequence.new(0.2, 0.5)
		p.Parent = windEmitter
	end
end

-- Decoration helper functions
function decorateTree(pos, size, foliageColor)
	size = size or 4
	foliageColor = foliageColor or Color3.fromRGB(40, 140, 40)
	local mesh = getAssetByType("tree")
	if mesh then
		local clone = mesh:Clone()
		clone.Position = pos + Vector3.new(0, math.random() * 2, 0)
		local scale = 0.5 + math.random()
		clone.Size = clone.Size * scale
		clone.Anchored = true
		clone.Parent = workspace
		return
	end
	local trunk = Instance.new("Part")
	trunk.Name = "TreeTrunk"
	trunk.Size = Vector3.new(0.5, size, 0.5)
	trunk.Position = pos + Vector3.new(0, size / 2, 0)
	trunk.Anchored = true
	trunk.Locked = true
	trunk.Color = Color3.fromRGB(120, 80, 40)
	trunk.Material = Enum.Material.Wood
	trunk.Parent = workspace
	
	local foliage = Instance.new("Part")
	foliage.Name = "TreeFoliage"
	foliage.Size = Vector3.new(size * 0.9, size * 0.5, size * 0.9)
	foliage.Position = pos + Vector3.new(0, size + size * 0.25, 0)
	foliage.Anchored = true
	foliage.Locked = true
	foliage.Color = foliageColor
	foliage.Material = Enum.Material.Grass
	foliage.Shape = Enum.PartType.Ball
	foliage.Parent = workspace
end

function decorateBush(pos)
	local mesh = getAssetByType("bush")
	if mesh then
		local clone = mesh:Clone()
		clone.Position = pos
		clone.Anchored = true
		clone.Parent = workspace
		return
	end
	local bush = Instance.new("Part")
	bush.Name = "Bush"
	local size = 1.5 + math.random() * 1.5
	bush.Size = Vector3.new(size, size * 0.6, size)
	bush.Position = pos + Vector3.new(0, size * 0.3, 0)
	bush.Anchored = true
	bush.Locked = true
	bush.Color = Color3.fromRGB(30 + math.random(30), 100 + math.random(60), 30 + math.random(30))
	bush.Material = Enum.Material.Grass
	bush.Shape = Enum.PartType.Ball
	bush.Parent = workspace
end

function decorateRock(pos)
	local mesh = getAssetByType("rock")
	if mesh then
		local clone = mesh:Clone()
		clone.Position = pos
		clone.Anchored = true
		clone.Parent = workspace
		return
	end
	local rock = Instance.new("Part")
	rock.Name = "Rock"
	local size = 1 + math.random() * 2.5
	rock.Size = Vector3.new(size, size * 0.6, size)
	rock.Position = pos + Vector3.new(0, size * 0.3, 0)
	rock.Anchored = true
	rock.Locked = true
	rock.Color = Color3.fromRGB(100 + math.random(30), 90 + math.random(20), 80 + math.random(20))
	rock.Material = Enum.Material.Slate
	rock.Shape = Enum.PartType.Ball
	rock.Parent = workspace
end

function decorateFlower(pos)
	local mesh = getAssetByType("flower")
	if mesh then
		local clone = mesh:Clone()
		clone.Position = pos
		clone.Anchored = true
		clone.Parent = workspace
		Debris:AddItem(clone, 120)
		return
	end
	local colors = {Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 255, 100), Color3.fromRGB(255, 150, 200), Color3.fromRGB(150, 100, 255)}
	local flower = Instance.new("Part")
	flower.Name = "Flower"
	flower.Size = Vector3.new(0.4, 0.4, 0.4)
	flower.Position = pos
	flower.Anchored = true
	flower.Locked = true
	flower.Color = colors[math.random(#colors)]
	flower.Material = Enum.Material.SmoothPlastic
	flower.Shape = Enum.PartType.Ball
	flower.Parent = workspace
end

function decoratePillar(pos)
	local mesh = getAssetByType("pillar")
	if mesh then
		local clone = mesh:Clone()
		clone.Position = pos
		clone.Anchored = true
		clone.Parent = workspace
		return
	end
	local pillar = Instance.new("Part")
	pillar.Name = "Pillar"
	local height = 3 + math.random() * 4
	pillar.Size = Vector3.new(1.5, height, 1.5)
	pillar.Position = pos + Vector3.new(0, height / 2, 0)
	pillar.Anchored = true
	pillar.Locked = true
	pillar.Color = Color3.fromRGB(130 + math.random(30), 120 + math.random(20), 100 + math.random(20))
	pillar.Material = Enum.Material.Sandstone
	pillar.Parent = workspace
end

function decorateTorch(pos)
	local post = Instance.new("Part")
	post.Name = "TorchPost"
	post.Size = Vector3.new(0.4, 3, 0.4)
	post.Position = pos + Vector3.new(0, 1.5, 0)
	post.Anchored = true
	post.Locked = true
	post.Color = Color3.fromRGB(80, 60, 40)
	post.Material = Enum.Material.Wood
	post.Parent = workspace
	
	local flame = Instance.new("Part")
	flame.Name = "TorchFlame"
	flame.Size = Vector3.new(0.6, 0.6, 0.6)
	flame.Position = pos + Vector3.new(0, 3.5, 0)
	flame.Anchored = true
	flame.Locked = true
	flame.Color = Color3.fromRGB(255, 150, 50)
	flame.Material = Enum.Material.Neon
	flame.Shape = Enum.PartType.Ball
	flame.Parent = workspace
	
	local p = Instance.new("ParticleEmitter")
	p.Rate = 8
	p.Lifetime = NumberRange.new(0.5, 1)
	p.Speed = NumberRange.new(1, 3)
	p.SpreadAngle = Vector2.new(60, 60)
	p.Color = ColorSequence.new(Color3.fromRGB(255, 150, 50))
	p.Texture = "rbxassetid://2842055869"
	p.Enabled = true
	p.Parent = flame
end

-- Create all island zones
for idx, islandData in ipairs(Islands) do
	createIslandZone(islandData, idx)
end

-- Create hub spawn area
local spawnFolder = Instance.new("Folder")
spawnFolder.Name = "SpawnLocations"
spawnFolder.Parent = Workspace

for i = 1, 8 do
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "SpawnLocation" .. i
	spawnLocation.Size = Vector3.new(4, 1, 4)
	spawnLocation.Position = Vector3.new((i - 4.5) * 8, 3, 0)
	spawnLocation.Anchored = true
	spawnLocation.Duration = 0
	spawnLocation.Neutral = true
	spawnLocation.Parent = Workspace
end

-- Sky setup
local sky = Instance.new("Sky")
sky.SkyboxBk = "rbxassetid://159356387"
sky.SkyboxDn = "rbxassetid://159356387"
sky.SkyboxFt = "rbxassetid://159356387"
sky.SkyboxLf = "rbxassetid://159356387"
sky.SkyboxRt = "rbxassetid://159356387"
sky.SkyboxUp = "rbxassetid://159356387"
sky.CelestialBodiesShown = true
sky.SunAngularSize = 8
sky.Parent = Workspace

-- Default lighting
Lighting.TimeOfDay = "12:00:00"
Lighting.Ambient = Color3.fromRGB(100, 100, 120)
Lighting.Brightness = 2
Lighting.FogEnd = 500
Lighting.FogColor = Color3.fromRGB(120, 120, 130)

function applyIslandEnvironment(islandId)
	local zone = islandZones[islandId]
	if not zone or not zone.env then return end
	
	local env = zone.env
	
	if env.weather == "clear" then
		Lighting.FogEnd = 400
	elseif env.weather == "sandstorm" then
		Lighting.FogEnd = 80
	elseif env.weather == "blizzard" then
		Lighting.FogEnd = 60
	elseif env.weather == "ash_storm" then
		Lighting.FogEnd = 50
	elseif env.weather == "storm" then
		Lighting.FogEnd = 40
	else
		Lighting.FogEnd = 300
	end
	
	local timeMap = {
		day = "12:00:00",
		dusk = "18:00:00",
		night = "00:00:00",
	}
	Lighting.TimeOfDay = timeMap[env.timeOfDay] or "12:00:00"
	
	if env.fogColor then
		Lighting.FogColor = env.fogColor
	end
	if env.ambientColor then
		Lighting.Ambient = env.ambientColor
	end
	
	if env.timeOfDay == "night" then
		Lighting.Brightness = 0.8
	elseif env.timeOfDay == "dusk" then
		Lighting.Brightness = 1.4
	else
		Lighting.Brightness = 2
	end
	
	print("[WorldManager] Applied environment for " .. islandId)
end

function resetToHubLighting()
	Lighting.TimeOfDay = "12:00:00"
	Lighting.Ambient = Color3.fromRGB(100, 100, 120)
	Lighting.Brightness = 2
	Lighting.FogEnd = 500
	Lighting.FogColor = Color3.fromRGB(120, 120, 130)
end

_G.WorldManager.applyIslandEnvironment = applyIslandEnvironment
_G.WorldManager.resetToHubLighting = resetToHubLighting
_G.WorldManager.islandZones = islandZones

function decorateHub()
	-- Trees around spawn
	local treePositions = {
		Vector3.new(-30, 0, -25), Vector3.new(25, 0, 30),
		Vector3.new(-20, 0, 30), Vector3.new(35, 0, -20),
		Vector3.new(-35, 0, 20), Vector3.new(20, 0, -35),
		Vector3.new(-40, 0, -15), Vector3.new(40, 0, 15),
	}
	for _, pos in ipairs(treePositions) do
		decorateTree(pos)
	end
	
	-- Bushes
	for i = 1, 8 do
		local angle = math.random() * math.pi * 2
		local radius = 10 + math.random() * 40
		decorateBush(Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius))
	end
	
	-- Rocks
	for i = 1, 6 do
		local angle = math.random() * math.pi * 2
		local radius = 15 + math.random() * 40
		decorateRock(Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius))
	end
	
	-- Torches around spawn
	for i = 1, 6 do
		local angle = (i / 6) * math.pi * 2
		local radius = 22
		local pos = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		decorateTorch(pos)
	end
	
	-- Welcome sign
	local signPost = Instance.new("Part")
	signPost.Name = "WelcomeSign"
	signPost.Size = Vector3.new(0.3, 5, 0.3)
	signPost.Position = Vector3.new(-15, 2.5, -35)
	signPost.Anchored = true
	signPost.Locked = true
	signPost.Color = Color3.fromRGB(80, 60, 40)
	signPost.Material = Enum.Material.Wood
	signPost.Parent = workspace
	
	local signBoard = Instance.new("Part")
	signBoard.Name = "SignBoard"
	signBoard.Size = Vector3.new(6, 3, 0.3)
	signBoard.Position = Vector3.new(-15, 5, -34)
	signBoard.Anchored = true
	signBoard.Locked = true
	signBoard.Color = Color3.fromRGB(120, 80, 40)
	signBoard.Material = Enum.Material.Wood
	signBoard.Parent = workspace
	
	-- Welcome billboard
	local welcomeGui = Instance.new("BillboardGui")
	welcomeGui.Name = "WelcomeLabel"
	welcomeGui.Size = UDim2.new(0, 300, 0, 60)
	welcomeGui.StudsOffset = Vector3.new(0, 8, 0)
	welcomeGui.AlwaysOnTop = true
	welcomeGui.Parent = signPost
	
	local welcomeLabel = Instance.new("TextLabel")
	welcomeLabel.Size = UDim2.new(1, 0, 1, 0)
	welcomeLabel.BackgroundTransparency = 1
	welcomeLabel.Text = "🏠 Welcome to Treasure Quest!\nSelect a character and explore the islands!"
	welcomeLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
	welcomeLabel.Font = Enum.Font.GothamBold
	welcomeLabel.TextScaled = true
	welcomeLabel.TextStrokeTransparency = 0.3
	welcomeLabel.Parent = welcomeGui
	
	print("[WorldManager] Hub decorated with welcome sign")
end

-- Decorate hub after the function is defined
decorateHub()

print("[WorldManager] World created with " .. #Islands .. " island zones")
return _G.WorldManager
