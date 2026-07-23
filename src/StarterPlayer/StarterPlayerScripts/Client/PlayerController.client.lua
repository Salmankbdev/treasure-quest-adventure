local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local currentWeaponHandle = nil

-- Weapon visual data
local weaponVisuals = {
	sword = { shape = "block", color = Color3.fromRGB(200, 200, 210), size = Vector3.new(0.4, 2.5, 0.2), gripOffset = CFrame.new(0, -0.5, 0.5) },
	bow = { shape = "cylinder", color = Color3.fromRGB(160, 120, 80), size = Vector3.new(0.3, 2, 0.3), gripOffset = CFrame.new(0, -0.5, 0.3) },
	magic_staff = { shape = "cylinder", color = Color3.fromRGB(100, 100, 200), size = Vector3.new(0.4, 3, 0.4), gripOffset = CFrame.new(0, -1, 0.5) },
	hammer = { shape = "block", color = Color3.fromRGB(140, 140, 150), size = Vector3.new(0.8, 1.5, 0.8), gripOffset = CFrame.new(0, -0.3, 0.5) },
	spear = { shape = "cylinder", color = Color3.fromRGB(180, 160, 120), size = Vector3.new(0.3, 3, 0.3), gripOffset = CFrame.new(0, -1, 0.5) },
	dagger = { shape = "block", color = Color3.fromRGB(180, 180, 190), size = Vector3.new(0.3, 1.2, 0.1), gripOffset = CFrame.new(0, -0.2, 0.4) },
	axe = { shape = "wedge", color = Color3.fromRGB(160, 160, 170), size = Vector3.new(0.8, 1.5, 0.4), gripOffset = CFrame.new(0, -0.3, 0.5) },
	crossbow = { shape = "block", color = Color3.fromRGB(120, 80, 60), size = Vector3.new(0.6, 1.2, 0.3), gripOffset = CFrame.new(0, -0.3, 0.3) },
	necromancer_staff = { shape = "cylinder", color = Color3.fromRGB(100, 50, 120), size = Vector3.new(0.4, 3, 0.4), gripOffset = CFrame.new(0, -1, 0.5) },
	-- New weapons
	katana = { shape = "block", color = Color3.fromRGB(220, 210, 200), size = Vector3.new(0.3, 2.8, 0.15), gripOffset = CFrame.new(0, -0.8, 0.5) },
	scythe = { shape = "cylinder", color = Color3.fromRGB(120, 80, 60), size = Vector3.new(0.3, 2.5, 0.3), gripOffset = CFrame.new(0, -0.5, 0.6) },
	whip = { shape = "cylinder", color = Color3.fromRGB(180, 140, 80), size = Vector3.new(0.2, 2, 0.2), gripOffset = CFrame.new(0, -0.5, 0.5) },
}

function createWeaponHandle(char, weaponId, weaponLevel)
	if currentWeaponHandle then
		currentWeaponHandle:Destroy()
		currentWeaponHandle = nil
	end
	
	if not weaponId then return end
	
	local visData = weaponVisuals[weaponId]
	if not visData then
		visData = { shape = "block", color = Color3.fromRGB(200, 200, 200), size = Vector3.new(0.5, 1, 0.5), gripOffset = CFrame.new(0, -0.3, 0.3) }
	end
	
	local attachment = char:FindFirstChild("RightHand")
	if not attachment then
		attachment = char:FindFirstChild("Right Arm")
	end
	if not attachment then
		attachment = char:FindFirstChild("HumanoidRootPart") or char
	end
	
	local weapon = Instance.new("Part")
	weapon.Name = "WeaponHandle"
	
	if visData.shape == "cylinder" then
		weapon.Shape = Enum.PartType.Cylinder
	elseif visData.shape == "ball" then
		weapon.Shape = Enum.PartType.Ball
	else
		weapon.Shape = Enum.PartType.Block
	end
	
	weapon.Size = visData.size
	weapon.Color = visData.color
	weapon.Material = Enum.Material.Metal
	weapon.Anchored = false
	weapon.CanCollide = false
	weapon.Parent = char
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = attachment
	weld.Part1 = weapon
	weld.Parent = weapon
	
	weapon.CFrame = attachment.CFrame * (visData.gripOffset or CFrame.new(0, -0.5, 0.5))
	
	-- Weapon glow based on level
	if weaponLevel then
		if weaponLevel >= 3 then
			local glow = Instance.new("SelectionBox")
			glow.Adornee = weapon
			glow.Color3 = weaponLevel >= 5 and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(100, 200, 255)
			glow.LineThickness = 0.1
			glow.Parent = weapon
		end
		if weaponLevel >= 5 then
			local particle = Instance.new("ParticleEmitter")
			particle.Rate = 5
			particle.Lifetime = NumberRange.new(0.5, 1)
			particle.Speed = NumberRange.new(1, 3)
			particle.SpreadAngle = Vector2.new(360, 360)
			particle.Color = ColorSequence.new(Color3.fromRGB(255, 200, 50))
			particle.Texture = "rbxassetid://2842055869"
			particle.Enabled = true
			particle.Parent = weapon
		end
	end
	
	currentWeaponHandle = weapon
end

-- Listen for character spawn
local spawnRemote = ReplicatedStorage:FindFirstChild("CharacterSpawned")
if spawnRemote then
	spawnRemote.OnClientEvent:Connect(function(charData)
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and charData then
			hum.WalkSpeed = charData.speed or 16
		end
		
		local weaponId = charData.weapon or charData.weaponId
		if weaponId then
			createWeaponHandle(char, weaponId, 1)
		end
		
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local spawns = Workspace:FindFirstChild("SpawnLocations")
			if spawns then
				local sp = spawns:FindFirstChild("SpawnLocation1")
				if sp then
					root.CFrame = sp.CFrame + Vector3.new(0, 2, 0)
				end
			end
		end
	end)
end

-- Movement trail particles
local lastFootstepTime = 0
local renderSteppedConnection = nil

local function onCharacterAdded(char)
	task.wait(0.5)
	
	-- Disconnect previous RenderStepped to avoid duplicates on respawn
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
	
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 16
		hum.UseJumpPower = false
		hum.JumpHeight = 7
	end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		local spawns = Workspace:FindFirstChild("SpawnLocations")
		if spawns then
			local sp = spawns:FindFirstChild("SpawnLocation1")
			if sp then
				root.CFrame = sp.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end
	
	-- Footstep particles while moving
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if not hum or not root or not char then return end
		if hum.MoveDirection.Magnitude > 0.5 and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
			local now = tick()
			if now - lastFootstepTime > 0.3 then
				lastFootstepTime = now
				local footstep = Instance.new("Part")
				footstep.Name = "FootstepDust"
				footstep.Size = Vector3.new(0.3, 0.3, 0.3)
				footstep.Position = root.Position - Vector3.new(0, root.Size.Y / 2, 0) + Vector3.new(0, -0.5, 0)
				footstep.Anchored = true
				footstep.CanCollide = false
				footstep.Transparency = 0.6
				footstep.Color = Color3.fromRGB(180, 170, 160)
				footstep.Material = Enum.Material.Neon
				footstep.Shape = Enum.PartType.Ball
				footstep.Parent = Workspace
				Debris:AddItem(footstep, 0.5)
			end
		end
	end)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- Listen for attack effect to flash the weapon (visual animation)
local attackEffectRemote = ReplicatedStorage:FindFirstChild("AttackEffect")
if attackEffectRemote then
	attackEffectRemote.OnClientEvent:Connect(function(hitPosition, weaponType, attackerPosition)
		-- Only animate for the local player's attacks
		if not attackerPosition or not currentWeaponHandle then return end
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		
		local dist = (attackerPosition - root.Position).Magnitude
		if dist > 5 then return end -- Not our attack
		
		-- Flash the weapon handle (WeldConstraint prevents CFrame animation)
		local weapon = currentWeaponHandle
		if weapon and weapon.Parent then
			local origColor = weapon.Color
			local origSize = weapon.Size
			weapon.Color = Color3.fromRGB(255, 255, 200)
			weapon.Size = origSize * Vector3.new(1.2, 1.2, 1.2)
			task.delay(0.1, function()
				if weapon and weapon.Parent then
					weapon.Color = origColor
					weapon.Size = origSize
				end
			end)
		end
	end)
end

print("[PlayerController] Loaded with weapon visualization, swing animation, and movement effects")
