local success, err = pcall(function()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Weapons = require(ReplicatedStorage.Shared.Weapons)
local Characters = require(ReplicatedStorage.Shared.Characters)

print("[Treasure Quest HUD] Starting...")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TreasureQuestHUD"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 1
screenGui.Parent = playerGui

local function New(c, p)
	local o = Instance.new(c)
	for k, v in pairs(p) do o[k] = v end
	return o
end

local colors = {
	health = Color3.fromRGB(220, 50, 50),
	healthDark = Color3.fromRGB(40, 15, 15),
	energy = Color3.fromRGB(50, 150, 220),
	energyDark = Color3.fromRGB(10, 25, 45),
	xp = Color3.fromRGB(150, 80, 200),
	xpDark = Color3.fromRGB(30, 20, 40),
	accent = Color3.fromRGB(255, 200, 50),
	white = Color3.fromRGB(255, 255, 255),
	gold = Color3.fromRGB(255, 200, 50),
	dark = Color3.fromRGB(10, 10, 20),
	panelBg = Color3.fromRGB(5, 5, 15),
}

local hud = New("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = screenGui })

-- == TOP LEFT STATS PANEL ==
local statsPanel = New("Frame", {
	Size = UDim2.new(0, 240, 0, 95),
	Position = UDim2.new(0, 10, 0, 10),
	BackgroundColor3 = colors.panelBg,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	Parent = hud,
})
-- Panel corner accent
New("UIStroke", { Color = colors.accent, Thickness = 1, Transparency = 0.7, Parent = statsPanel })

-- Health bar
local healthBar = New("Frame", {
	Size = UDim2.new(1, -8, 0, 22),
	Position = UDim2.new(0, 4, 0, 4),
	BackgroundColor3 = colors.healthDark,
	BorderSizePixel = 0,
	Parent = statsPanel,
})
local healthFill = New("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = colors.health, BorderSizePixel = 0, Parent = healthBar })
New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = healthBar })
New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = healthFill })
local healthIcon = New("TextLabel", {
	Size = UDim2.new(0, 20, 1, 0),
	BackgroundTransparency = 1,
	Text = "❤️",
	TextScaled = true,
	Parent = healthBar,
})
local healthText = New("TextLabel", {
	Size = UDim2.new(1, -20, 1, 0),
	Position = UDim2.new(0, 20, 0, 0),
	BackgroundTransparency = 1,
	Text = "100/100",
	TextColor3 = colors.white,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = healthBar,
})

-- Energy bar
local energyBar = New("Frame", {
	Size = UDim2.new(1, -8, 0, 18),
	Position = UDim2.new(0, 4, 0, 28),
	BackgroundColor3 = colors.energyDark,
	BorderSizePixel = 0,
	Parent = statsPanel,
})
local energyFill = New("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = colors.energy, BorderSizePixel = 0, Parent = energyBar })
New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = energyBar })
New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = energyFill })
local energyIcon = New("TextLabel", {
	Size = UDim2.new(0, 18, 1, 0),
	BackgroundTransparency = 1,
	Text = "⚡",
	TextScaled = true,
	Parent = energyBar,
})
local energyText = New("TextLabel", {
	Size = UDim2.new(1, -18, 1, 0),
	Position = UDim2.new(0, 18, 0, 0),
	BackgroundTransparency = 1,
	Text = "100/100",
	TextColor3 = colors.white,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = energyBar,
})

-- XP bar
local xpBar = New("Frame", {
	Size = UDim2.new(1, -8, 0, 14),
	Position = UDim2.new(0, 4, 0, 48),
	BackgroundColor3 = colors.xpDark,
	BorderSizePixel = 0,
	Parent = statsPanel,
})
local xpFill = New("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = colors.xp, BorderSizePixel = 0, Parent = xpBar })
New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = xpBar })
New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = xpFill })
local xpText = New("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "Lv.1",
	TextColor3 = Color3.fromRGB(200, 180, 220),
	Font = Enum.Font.GothamBold,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Center,
	Parent = xpBar,
})

-- Coin & Gem row
local coinIcon = New("TextLabel", {
	Size = UDim2.new(0.5, -2, 0, 22),
	Position = UDim2.new(0, 4, 1, -24),
	BackgroundTransparency = 1,
	Text = "🪙 0",
	TextColor3 = colors.accent,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = statsPanel,
})
local gemIcon = New("TextLabel", {
	Size = UDim2.new(0.5, -2, 0, 22),
	Position = UDim2.new(0.5, 0, 1, -24),
	BackgroundTransparency = 1,
	Text = "💎 0",
	TextColor3 = Color3.fromRGB(100, 200, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = statsPanel,
})

-- == ACTION BUTTONS ==
-- Ability button (center bottom)
local abilityBtn = New("ImageButton", {
	Size = UDim2.new(0, 70, 0, 70),
	Position = UDim2.new(0.5, -145, 1, -85),
	BackgroundColor3 = Color3.fromRGB(40, 35, 60),
	BorderSizePixel = 0,
	Image = "rbxassetid://2842055869",
	ImageColor3 = Color3.fromRGB(40, 35, 60),
	ScaleType = Enum.ScaleType.Slice,
	Parent = hud,
})
New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = abilityBtn })
New("UIStroke", { Color = Color3.fromRGB(80, 70, 120), Thickness = 2, Transparency = 0.5, Parent = abilityBtn })
local abilityLabel = New("TextLabel", {
	Size = UDim2.new(1, 0, 0.7, 0),
	Position = UDim2.new(0, 0, 0, 4),
	BackgroundTransparency = 1,
	Text = "⚡\nAbility",
	TextColor3 = colors.white,
	Font = Enum.Font.GothamBold,
	TextSize = 9,
	Parent = abilityBtn,
})
-- Key hint label on ability button
New("TextLabel", {
	Size = UDim2.new(0.5, 0, 0.25, 0),
	Position = UDim2.new(1, -36, 1, -18),
	BackgroundColor3 = Color3.fromRGB(60, 50, 90),
	BackgroundTransparency = 0.3,
	Text = "[Q]",
	TextColor3 = Color3.fromRGB(180, 180, 200),
	Font = Enum.Font.GothamBold,
	TextSize = 9,
	Parent = abilityBtn,
})
New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = abilityLabel })
local abilCd = New("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 0.4,
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	Text = "",
	TextColor3 = colors.white,
	Font = Enum.Font.GothamBold,
	TextSize = 22,
	Visible = false,
	Parent = abilityBtn,
})
New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = abilCd })

-- Attack button (bottom right)
-- Attack button with cooldown overlay (bottom right)
local attackBtn = New("ImageButton", {
	Size = UDim2.new(0, 72, 0, 72),
	Position = UDim2.new(1, -82, 1, -82),
	BackgroundColor3 = Color3.fromRGB(180, 40, 40),
	BorderSizePixel = 0,
	Image = "rbxassetid://2842055869",
	ImageColor3 = Color3.fromRGB(180, 40, 40),
	ScaleType = Enum.ScaleType.Slice,
	Parent = hud,
})
New("UICorner", { CornerRadius = UDim.new(0, 36), Parent = attackBtn })
New("UIStroke", { Color = Color3.fromRGB(200, 80, 80), Thickness = 3, Transparency = 0.3, Parent = attackBtn })
local attackLabel = New("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "⚔️",
	TextColor3 = colors.white,
	Font = Enum.Font.GothamBold,
	TextSize = 28,
	Parent = attackBtn,
})
-- Attack cooldown overlay
local attackCd = New("Frame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.6,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 2,
	Parent = attackBtn,
})
New("UICorner", { CornerRadius = UDim.new(0, 36), Parent = attackCd })
local attackCdLabel = New("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = colors.white,
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	ZIndex = 3,
	Parent = attackCd,
})
-- Key hint label on attack button
New("TextLabel", {
	Size = UDim2.new(0.5, 0, 0.25, 0),
	Position = UDim2.new(1, -36, 1, -18),
	BackgroundColor3 = Color3.fromRGB(120, 30, 30),
	BackgroundTransparency = 0.3,
	Text = "[LMB]",
	TextColor3 = Color3.fromRGB(220, 180, 180),
	Font = Enum.Font.GothamBold,
	TextSize = 7,
	Parent = attackBtn,
})

-- == TARGETING RETICLE (center screen) ==
local aimReticle = New("Frame", {
	Size = UDim2.new(0, 40, 0, 40),
	Position = UDim2.new(0.5, -20, 0.5, -20),
	BackgroundTransparency = 1,
	ZIndex = 10,
	Visible = true,
	Parent = hud,
})
-- Reticle cross hair
local reticleH = New("Frame", {
	Size = UDim2.new(1, 0, 0, 2),
	Position = UDim2.new(0, 0, 0.5, -1),
	BackgroundColor3 = colors.accent,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	ZIndex = 11,
	Parent = aimReticle,
})
local reticleV = New("Frame", {
	Size = UDim2.new(0, 2, 1, 0),
	Position = UDim2.new(0.5, -1, 0, 0),
	BackgroundColor3 = colors.accent,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	ZIndex = 11,
	Parent = aimReticle,
})
-- Reticle dot (lights up when enemy targeted)
local reticleDot = New("Frame", {
	Size = UDim2.new(0, 8, 0, 8),
	Position = UDim2.new(0.5, -4, 0.5, -4),
	BackgroundColor3 = Color3.fromRGB(255, 80, 80),
	BackgroundTransparency = 0.5,
	BorderSizePixel = 0,
	ZIndex = 12,
	Parent = aimReticle,
})
New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = reticleDot })

-- Target info label (appears when enemy is targeted)
local targetLabel = New("TextLabel", {
	Size = UDim2.new(0, 200, 0, 20),
	Position = UDim2.new(0.5, -100, 0.5, 25),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Color3.fromRGB(255, 80, 80),
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextStrokeTransparency = 0.3,
	Visible = false,
	ZIndex = 10,
	Parent = hud,
})

-- Jump button (bottom right, above attack)
local jumpBtn = New("TextButton", {
	Size = UDim2.new(0, 55, 0, 40),
	Position = UDim2.new(1, -155, 1, -60),
	BackgroundColor3 = Color3.fromRGB(40, 40, 60),
	BorderSizePixel = 0,
	Text = "JUMP",
	TextColor3 = colors.white,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	Parent = hud,
})
-- Key hint label on jump button
New("TextLabel", {
	Size = UDim2.new(1, -4, 0.3, 0),
	Position = UDim2.new(0, 2, 0, 2),
	BackgroundTransparency = 1,
	Text = "[Space]",
	TextColor3 = Color3.fromRGB(140, 140, 180),
	Font = Enum.Font.Gotham,
	TextSize = 7,
	TextXAlignment = Enum.TextXAlignment.Right,
	Parent = jumpBtn,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = jumpBtn })

-- Sprint button (bottom right)
local sprintBtn = New("TextButton", {
	Size = UDim2.new(0, 55, 0, 40),
	Position = UDim2.new(1, -155, 1, -115),
	BackgroundColor3 = Color3.fromRGB(40, 40, 100),
	BorderSizePixel = 0,
	Text = "SPRINT",
	TextColor3 = colors.white,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	Parent = hud,
})
-- Key hint label on sprint button
New("TextLabel", {
	Size = UDim2.new(1, -4, 0.3, 0),
	Position = UDim2.new(0, 2, 0, 2),
	BackgroundTransparency = 1,
	Text = "[Shift]",
	TextColor3 = Color3.fromRGB(140, 140, 180),
	Font = Enum.Font.Gotham,
	TextSize = 7,
	TextXAlignment = Enum.TextXAlignment.Right,
	Parent = sprintBtn,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = sprintBtn })

-- Interact button (center bottom)
local interactBtn = New("TextButton", {
	Size = UDim2.new(0, 55, 0, 40),
	Position = UDim2.new(0.5, 90, 1, -60),
	BackgroundColor3 = Color3.fromRGB(50, 50, 80),
	BorderSizePixel = 0,
	Text = "✋",
	TextColor3 = colors.white,
	Font = Enum.Font.Gotham,
	TextSize = 20,
	Parent = hud,
})
-- Key hint label on interact button
New("TextLabel", {
	Size = UDim2.new(1, -4, 0.3, 0),
	Position = UDim2.new(0, 2, 0, 2),
	BackgroundTransparency = 1,
	Text = "[E]",
	TextColor3 = Color3.fromRGB(140, 140, 180),
	Font = Enum.Font.Gotham,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Right,
	Parent = interactBtn,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = interactBtn })

-- Shop toggle button (between ability and interact)
local shopBtn = New("TextButton", {
	Size = UDim2.new(0, 55, 0, 40),
	Position = UDim2.new(0.5, 30, 1, -60),
	BackgroundColor3 = Color3.fromRGB(60, 50, 30),
	BorderSizePixel = 0,
	Text = "🏪",
	TextColor3 = colors.white,
	Font = Enum.Font.Gotham,
	TextSize = 20,
	Parent = hud,
})
New("TextLabel", {
	Size = UDim2.new(1, -4, 0.3, 0),
	Position = UDim2.new(0, 2, 0, 2),
	BackgroundTransparency = 1,
	Text = "[B]",
	TextColor3 = Color3.fromRGB(180, 160, 120),
	Font = Enum.Font.Gotham,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Right,
	Parent = shopBtn,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = shopBtn })

-- == SHOP PANEL ==
local shopFrame = New("Frame", {
	Size = UDim2.new(0, 600, 0, 450),
	Position = UDim2.new(0.5, -300, 0.5, -225),
	BackgroundColor3 = Color3.fromRGB(15, 15, 30),
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 20,
	Parent = screenGui,
})
New("UICorner", { CornerRadius = UDim.new(0, 16), Parent = shopFrame })
New("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 35, 25)), ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 30)) }), Parent = shopFrame })
New("UIStroke", { Color = Color3.fromRGB(255, 200, 100), Thickness = 2, Transparency = 0.5, Parent = shopFrame })
-- Shop title
New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 40),
	Position = UDim2.new(0, 0, 0, 8),
	BackgroundTransparency = 1,
	Text = "🏪 SHOP",
	TextColor3 = Color3.fromRGB(255, 200, 100),
	Font = Enum.Font.GothamBold,
	TextSize = 22,
	Parent = shopFrame,
})
-- Close button
local shopCloseBtn = New("TextButton", {
	Size = UDim2.new(0, 30, 0, 30),
	Position = UDim2.new(1, -36, 0, 8),
	BackgroundColor3 = Color3.fromRGB(60, 40, 40),
	BorderSizePixel = 0,
	Text = "✕",
	TextColor3 = Color3.fromRGB(220, 100, 100),
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	Parent = shopFrame,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = shopCloseBtn })
shopCloseBtn.MouseButton1Click:Connect(function() shopFrame.Visible = false end)

-- Tab buttons
local shopWeaponTab = New("TextButton", {
	Size = UDim2.new(0.5, -4, 0, 30),
	Position = UDim2.new(0, 8, 0, 50),
	BackgroundColor3 = Color3.fromRGB(40, 35, 25),
	BorderSizePixel = 0,
	Text = "⚔️ Weapons",
	TextColor3 = Color3.fromRGB(255, 200, 100),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	Parent = shopFrame,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = shopWeaponTab })
local shopItemTab = New("TextButton", {
	Size = UDim2.new(0.5, -4, 0, 30),
	Position = UDim2.new(0.5, 4, 0, 50),
	BackgroundColor3 = Color3.fromRGB(25, 25, 45),
	BorderSizePixel = 0,
	Text = "🧪 Items",
	TextColor3 = Color3.fromRGB(180, 180, 190),
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	Parent = shopFrame,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = shopItemTab })

-- Shop list container
local shopList = New("ScrollingFrame", {
	Size = UDim2.new(1, -16, 1, -92),
	Position = UDim2.new(0, 8, 0, 84),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	Parent = shopFrame,
})

-- Currency display
local shopCoins = New("TextLabel", {
	Size = UDim2.new(0, 100, 0, 20),
	Position = UDim2.new(0, 8, 1, -24),
	BackgroundTransparency = 1,
	Text = "🪙 0",
	TextColor3 = Color3.fromRGB(255, 200, 50),
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = shopFrame,
})
local shopGems = New("TextLabel", {
	Size = UDim2.new(0, 100, 0, 20),
	Position = UDim2.new(0, 110, 1, -24),
	BackgroundTransparency = 1,
	Text = "💎 0",
	TextColor3 = Color3.fromRGB(100, 200, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = shopFrame,
})

-- Shop data
local shopData = nil
local getShopRF = ReplicatedStorage:FindFirstChild("GetShopData")
local buyRE = ReplicatedStorage:FindFirstChild("BuyItem")
if getShopRF then
	local ok, result = pcall(function() return getShopRF:InvokeServer() end)
	if ok and result then shopData = result end
end

local function refreshShopDisplay(tab)
	if not shopData then
		for _, c in ipairs(shopList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		local errLabel = New("TextLabel", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "Shop unavailable", TextColor3 = Color3.fromRGB(180, 80, 80), Font = Enum.Font.Gotham, TextSize = 14, Parent = shopList })
		shopList.CanvasSize = UDim2.new(0, 0, 0, 34)
		return
	end
	for _, c in ipairs(shopList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	local items = (tab == "weapons" and shopData.weapons) or (tab == "items" and shopData.items) or shopData.weapons
	local coins = myCurrency.coins or 0
	local gems = myCurrency.gems or 0
	local sy = 0
	for _, entry in ipairs(items or {}) do
		local itemId = entry.id or entry.type
		local name = itemId
		local price = entry.price or 0
		local currency = entry.currency or "coins"
		local wData = tab == "weapons" and Weapons[itemId]
		if wData then name = wData.emoji .. " " .. wData.name end
		local canAfford = (currency == "coins" and coins >= price) or (currency == "gems" and gems >= price)
		local btn = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundColor3 = Color3.fromRGB(25, 25, 45),
			BorderSizePixel = 0,
			Parent = shopList,
		})
		sy = sy + 48
		btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 45, 70) end)
		btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45) end)
		if tab == "weapons" and wData then
			local desc = (wData.description or "") .. " | DMG:" .. wData.damage .. " RNG:" .. wData.range
			New("TextLabel", { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = name, TextColor3 = colors.white, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
			New("TextLabel", { Size = UDim2.new(1, -80, 0, 16), Position = UDim2.new(0, 8, 0, 22), BackgroundTransparency = 1, Text = desc, TextColor3 = Color3.fromRGB(180, 180, 190), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
		elseif tab == "items" then
			local iData = (require(ReplicatedStorage.Shared.Items) or {})[itemId] or {}
			New("TextLabel", { Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = (iData.emoji or "📦") .. " " .. (iData.name or itemId), TextColor3 = colors.white, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
			New("TextLabel", { Size = UDim2.new(1, -80, 0, 16), Position = UDim2.new(0, 8, 0, 22), BackgroundTransparency = 1, Text = iData.description or "", TextColor3 = Color3.fromRGB(180, 180, 190), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
		end
		local priceStr = (currency == "coins" and "🪙" or "💎") .. " " .. price
		New("TextLabel", { Size = UDim2.new(0, 70, 1, 0), Position = UDim2.new(1, -76, 0, 0), BackgroundTransparency = 1, Text = priceStr, TextColor3 = canAfford and Color3.fromRGB(200, 200, 100) or Color3.fromRGB(200, 80, 80), Font = Enum.Font.GothamBold, TextSize = 12, Parent = btn })
		if canAfford and buyRE then
			btn.MouseButton1Click:Connect(function()
				buyRE:FireServer(itemId, tab == "weapons" and "weapon" or "item")
				if getShopRF then
					local ok2, res2 = pcall(function() return getShopRF:InvokeServer() end)
					if ok2 and res2 then shopData = res2 end
				end
				refreshShopDisplay(tab)
			end)
		end
	end
	shopList.CanvasSize = UDim2.new(0, 0, 0, sy + 4)
	shopCoins.Text = "🪙 " .. (coins or 0)
	shopGems.Text = "💎 " .. (gems or 0)
end

-- Shop visibility toggle
local shopOpen = false
local function toggleShop()
	shopOpen = not shopOpen
	shopFrame.Visible = shopOpen
	if shopOpen then
		if getShopRF then
			local ok, result = pcall(function() return getShopRF:InvokeServer() end)
			if ok and result then shopData = result end
		end
		refreshShopDisplay("weapons")
		shopWeaponTab.BackgroundColor3 = Color3.fromRGB(40, 35, 25)
		shopWeaponTab.TextColor3 = Color3.fromRGB(255, 200, 100)
		shopItemTab.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
		shopItemTab.TextColor3 = Color3.fromRGB(180, 180, 190)
	end
end
shopBtn.MouseButton1Click:Connect(toggleShop)
shopWeaponTab.MouseButton1Click:Connect(function()
	shopWeaponTab.BackgroundColor3 = Color3.fromRGB(40, 35, 25)
	shopWeaponTab.TextColor3 = Color3.fromRGB(255, 200, 100)
	shopItemTab.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
	shopItemTab.TextColor3 = Color3.fromRGB(180, 180, 190)
	refreshShopDisplay("weapons")
end)
shopItemTab.MouseButton1Click:Connect(function()
	shopItemTab.BackgroundColor3 = Color3.fromRGB(40, 35, 25)
	shopItemTab.TextColor3 = Color3.fromRGB(255, 200, 100)
	shopWeaponTab.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
	shopWeaponTab.TextColor3 = Color3.fromRGB(180, 180, 190)
	refreshShopDisplay("items")
end)

-- Keyboard shortcut
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.B then toggleShop() end
end)

-- == MINIMAP (top right) ==
local minimap = New("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	Size = UDim2.new(0, 150, 0, 150),
	Position = UDim2.new(1, -10, 0, 10),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.25,
	BorderSizePixel = 1,
	BorderColor3 = colors.accent,
	Parent = hud,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = minimap })
New("TextLabel", {
	Size = UDim2.new(1, -4, 0, 16),
	Position = UDim2.new(0, 2, 0, 2),
	BackgroundTransparency = 1,
	Text = "🗺️ MAP",
	TextColor3 = colors.accent,
	Font = Enum.Font.GothamBold,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = minimap,
})
-- Player indicator dot
local playerDot = New("Frame", {
	Size = UDim2.new(0, 6, 0, 6),
	Position = UDim2.new(0.5, -3, 0.5, -3),
	BackgroundColor3 = Color3.fromRGB(100, 200, 255),
	BorderSizePixel = 0,
	Parent = minimap,
})
New("UICorner", { CornerRadius = UDim.new(0, 3), Parent = playerDot })

-- == QUEST TRACKER (right side) ==
local questTracker = New("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	Size = UDim2.new(0, 200, 0, 110),
	Position = UDim2.new(1, -10, 0, 168),
	BackgroundColor3 = colors.panelBg,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	Parent = hud,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = questTracker })
New("UIStroke", { Color = colors.accent, Thickness = 1, Transparency = 0.8, Parent = questTracker })
local questTitle = New("TextLabel", {
	Size = UDim2.new(1, -10, 0, 20),
	Position = UDim2.new(0, 5, 0, 5),
	BackgroundTransparency = 1,
	Text = "📋 Current Quest",
	TextColor3 = colors.accent,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = questTracker,
})
local questDesc = New("TextLabel", {
	Size = UDim2.new(1, -10, 1, -28),
	Position = UDim2.new(0, 5, 0, 25),
	BackgroundTransparency = 1,
	Text = "Collect all 7 crystals\nto save the world!",
	TextColor3 = Color3.fromRGB(200, 200, 210),
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = questTracker,
})

-- == LEVEL UP NOTIFICATION ==
local upgradeNotice = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.new(0, 320, 0, 60),
	Position = UDim2.new(0.5, -160, 0.35, -30),
	BackgroundColor3 = Color3.fromRGB(40, 80, 40),
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 5,
	Parent = hud,
})
New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = upgradeNotice })
New("UIStroke", { Color = colors.accent, Thickness = 2, Transparency = 0.3, Parent = upgradeNotice })
local levelUpText = New("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "⬆️ LEVEL UP!",
	TextColor3 = colors.accent,
	Font = Enum.Font.GothamBold,
	TextSize = 24,
	Parent = upgradeNotice,
})

-- == CHEST REWARD NOTIFICATION ==
local chestNotice = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.new(0, 280, 0, 50),
	Position = UDim2.new(0.5, -140, 0.45, -25),
	BackgroundColor3 = Color3.fromRGB(50, 50, 20),
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 5,
	Parent = hud,
})
New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = chestNotice })
New("UIStroke", { Color = Color3.fromRGB(255, 200, 100), Thickness = 2, Transparency = 0.4, Parent = chestNotice })
local chestText = New("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "📦 Treasure Found!",
	TextColor3 = Color3.fromRGB(255, 200, 100),
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	Parent = chestNotice,
})

-- == CRYSTAL COLLECTED NOTIFICATION ==
local crystalNotice = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.new(0, 300, 0, 50),
	Position = UDim2.new(0.5, -150, 0.5, -25),
	BackgroundColor3 = Color3.fromRGB(40, 30, 80),
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = 6,
	Parent = hud,
})
New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = crystalNotice })
New("UIStroke", { Color = Color3.fromRGB(150, 100, 255), Thickness = 2, Transparency = 0.3, Parent = crystalNotice })
local crystalText = New("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "💎 Crystal Collected!",
	TextColor3 = Color3.fromRGB(150, 100, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	Parent = crystalNotice,
})

-- == ISLAND TELEPORT PANEL ==
local islandPanel = New("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Size = UDim2.new(0, 180, 0, 280),
	Position = UDim2.new(0, 10, 1, -10),
	BackgroundColor3 = colors.panelBg,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	Parent = hud,
})
New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = islandPanel })
New("UIStroke", { Color = colors.accent, Thickness = 1, Transparency = 0.8, Parent = islandPanel })
New("TextLabel", {
	Size = UDim2.new(1, -6, 0, 22),
	Position = UDim2.new(0, 3, 0, 3),
	BackgroundTransparency = 1,
	Text = "🗺️ ISLANDS",
	TextColor3 = colors.accent,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = islandPanel,
})
local islandList = New("ScrollingFrame", {
	Size = UDim2.new(1, -6, 1, -28),
	Position = UDim2.new(0, 3, 0, 25),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 3,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Parent = islandPanel,
})

local getIslands = ReplicatedStorage:FindFirstChild("GetIslands")
if getIslands then
	local islands = getIslands:InvokeServer()
	if islands then
		local islY = 0
		for _, islData in ipairs(islands) do
			islY = islY + 34
			local islBtn = New("TextButton", { 
				Size = UDim2.new(1, 0, 0, 34), 
				BackgroundColor3 = Color3.fromRGB(20, 20, 40), 
				BorderSizePixel = 0, 
				Parent = islandList,
			})
			islBtn.MouseEnter:Connect(function()
				islBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
			end)
			islBtn.MouseLeave:Connect(function()
				islBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
			end)
			local diffColor = islData.difficulty == "Easy" and Color3.fromRGB(80, 200, 80) 
				or islData.difficulty == "Normal" and Color3.fromRGB(200, 200, 80)
				or islData.difficulty == "Hard" and Color3.fromRGB(200, 100, 50)
				or Color3.fromRGB(200, 50, 80)
			New("TextLabel", { 
				Size = UDim2.new(1, -50, 1, 0), 
				Position = UDim2.new(0, 4, 0, 0),
				BackgroundTransparency = 1, 
				Text = islData.emoji .. " " .. islData.name, 
				TextColor3 = colors.white, 
				Font = Enum.Font.GothamBold, 
				TextSize = 9, 
				TextXAlignment = Enum.TextXAlignment.Left, 
				Parent = islBtn,
			})
			New("TextLabel", { 
				Size = UDim2.new(0, 46, 1, 0), 
				Position = UDim2.new(1, -48, 0, 0),
				BackgroundTransparency = 1, 
				Text = "[" .. islData.difficulty .. "]", 
				TextColor3 = diffColor, 
				Font = Enum.Font.GothamBold, 
				TextSize = 6, 
				Parent = islBtn,
			})
			islBtn.MouseButton1Click:Connect(function()
				local teleRemote = ReplicatedStorage:FindFirstChild("TeleportToIsland")
				if teleRemote then
					teleRemote:FireServer(islData.id)
					hintText.Text = "🌀 Teleporting to " .. islData.name .. "..."
				end
			end)
		end
		islandList.CanvasSize = UDim2.new(0, 0, 0, islY + 4)
	end
end

-- Hint text (center bottom)
local hintText = New("TextLabel", {
	Size = UDim2.new(0, 400, 0, 22),
	Position = UDim2.new(0.5, -200, 1, -320),
	BackgroundTransparency = 1,
	Text = "Select a character to begin your adventure!",
	TextColor3 = Color3.fromRGB(180, 180, 190),
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextStrokeTransparency = 0.5,
	Parent = hud,
})

-- == CHARACTER SELECT SCREEN ==
local charSelectFrame = New("Frame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.5,
	ZIndex = 10,
	Parent = screenGui,
})
local csBg = New("Frame", {
	Size = UDim2.new(0, 750, 0, 550),
	Position = UDim2.new(0.5, -375, 0.5, -275),
	BackgroundColor3 = Color3.fromRGB(15, 15, 30),
	BorderSizePixel = 0,
	Parent = charSelectFrame,
})
New("UICorner", { CornerRadius = UDim.new(0, 16), Parent = csBg })
New("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 30)) }), Parent = csBg })
New("UIStroke", { Color = colors.accent, Thickness = 2, Transparency = 0.5, Parent = csBg })
New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 50),
	Position = UDim2.new(0, 0, 0, 10),
	BackgroundTransparency = 1,
	Text = "⚔️ CHOOSE YOUR CHARACTER ⚔️",
	TextColor3 = colors.accent,
	Font = Enum.Font.GothamBold,
	TextSize = 24,
	Parent = csBg,
})
local csList = New("ScrollingFrame", {
	Size = UDim2.new(1, -20, 1, -110),
	Position = UDim2.new(0, 10, 0, 65),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	Parent = csBg,
})

-- Skip button
local skipBtn = New("TextButton", { 
	Size = UDim2.new(0, 100, 0, 28), 
	Position = UDim2.new(1, -110, 1, -38),
	BackgroundColor3 = Color3.fromRGB(40, 40, 60), 
	BorderSizePixel = 0, 
	Text = "✕ Skip", 
	TextColor3 = Color3.fromRGB(180, 180, 190), 
	Font = Enum.Font.Gotham, 
	TextSize = 12, 
	Parent = csBg,
})
New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = skipBtn })

local selectRemote = ReplicatedStorage:FindFirstChild("SelectCharacter")
local spawnRemote = ReplicatedStorage:FindFirstChild("CharacterSpawned")
local hudRemote = ReplicatedStorage:FindFirstChild("UpdateHUD")
local lvlUpRemote = ReplicatedStorage:FindFirstChild("LevelUp")
local myCurrency = { coins = 0, gems = 0 }
local crystalRemote = ReplicatedStorage:FindFirstChild("CrystalCollected")

if hudRemote then
	hudRemote.OnClientEvent:Connect(function(data)
		if not data then return end
		local hp = data.health or 100
		local mhp = data.maxHealth or 100
		local en = data.energy or 100
		local men = data.maxEnergy or 100
		local coins = data.coins or 0
		local gems = data.gems or 0
		myCurrency.coins = coins
		myCurrency.gems = gems
		local lvl = data.level or 1
		local xp = data.xp or 0
		-- Animated bar fill
		local hpTarget = UDim2.new(math.clamp(hp / mhp, 0, 1), 0, 1, 0)
		local enTarget = UDim2.new(math.clamp(en / men, 0, 1), 0, 1, 0)
		healthFill:TweenSize(hpTarget, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		energyFill:TweenSize(enTarget, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		healthText.Text = math.floor(hp) .. "/" .. mhp
		energyText.Text = math.floor(en) .. "/" .. men
		coinIcon.Text = "🪙 " .. coins
		gemIcon.Text = "💎 " .. gems
		xpText.Text = "Lv." .. lvl
		local xpNeeded = lvl * 100
		xpFill:TweenSize(UDim2.new(math.min(xp / xpNeeded, 1), 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
	end)
end

if lvlUpRemote then
	lvlUpRemote.OnClientEvent:Connect(function(level)
		levelUpText.Text = "⬆️ LEVEL " .. level .. "!"
		upgradeNotice.Visible = true
		hintText.Text = "🎉 Level " .. level .. "! Stats increased!"
		task.delay(3, function() upgradeNotice.Visible = false end)
	end)
end

if crystalRemote then
	crystalRemote.OnClientEvent:Connect(function(crystalName)
		crystalText.Text = "💎 " .. tostring(crystalName) .. " Collected!"
		crystalNotice.Visible = true
		hintText.Text = "🌟 Crystal collected! Keep going!"
		task.delay(3, function() crystalNotice.Visible = false end)
		task.delay(4, function()
			hintText.Text = "Use buttons to move, attack, and explore!"
		end)
	end)
end

-- Chest reward handler
local chestRewardRemote = ReplicatedStorage:FindFirstChild("ChestReward")
if chestRewardRemote then
	chestRewardRemote.OnClientEvent:Connect(function(coins, gems)
		chestText.Text = "📦 Found 🪙" .. coins .. " 💎" .. gems .. "!"
		chestNotice.Visible = true
		task.delay(2.5, function() chestNotice.Visible = false end)
	end)
end

local defaultCharId = "warrior"
local csY = 0
skipBtn.MouseButton1Click:Connect(function()
	if selectRemote then selectRemote:FireServer(defaultCharId) end
	charSelectFrame.Visible = false
	hintText.Text = "Select an island and start your quest!"
end)

for _, charData in pairs(Characters) do
	csY = csY + 72
	local btn = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundColor3 = Color3.fromRGB(25, 25, 45),
		BorderSizePixel = 0,
		Parent = csList,
	})
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 75)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
	end)
	New("TextLabel", { Size = UDim2.new(0, 50, 1, 0), BackgroundTransparency = 1, Text = charData.emoji, TextColor3 = colors.white, Font = Enum.Font.Gotham, TextSize = 28, Parent = btn })
	New("TextLabel", { Size = UDim2.new(0, 200, 0, 24), Position = UDim2.new(0, 55, 0, 5), BackgroundTransparency = 1, Text = charData.name, TextColor3 = colors.accent, Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	local statStr = string.format("❤️%d ⚡%d ⚔️%d 🛡️%d 💨%d", charData.baseHealth, charData.baseEnergy, charData.baseDamage, charData.baseDefense, charData.speed)
	New("TextLabel", { Size = UDim2.new(0, 300, 0, 15), Position = UDim2.new(0, 55, 0, 28), BackgroundTransparency = 1, Text = statStr, TextColor3 = Color3.fromRGB(140, 200, 255), Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	-- Ability info
	if charData.ability then
		New("TextLabel", { Size = UDim2.new(0, 500, 0, 14), Position = UDim2.new(0, 55, 0, 42), BackgroundTransparency = 1, Text = "⚡ " .. charData.ability.name .. ": " .. charData.ability.description, TextColor3 = Color3.fromRGB(160, 200, 255), Font = Enum.Font.Gotham, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	end
	New("TextLabel", { Size = UDim2.new(0, 400, 0, 16), Position = UDim2.new(0, 55, 0, 54), BackgroundTransparency = 1, Text = charData.description, TextColor3 = Color3.fromRGB(180, 180, 190), Font = Enum.Font.Gotham, TextSize = 9, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
	
	btn.MouseButton1Click:Connect(function()
		if selectRemote then
			selectRemote:FireServer(charData.id)
			charSelectFrame.Visible = false
			hintText.Text = "🌀 Spawning " .. charData.name .. "..."
		end
	end)
end
csList.CanvasSize = UDim2.new(0, 0, 0, csY + 8)

-- Damage number popup system
local dmgNumberFolder = Instance.new("Folder")
dmgNumberFolder.Name = "DamageNumbers"
dmgNumberFolder.Parent = hud

function showDamageNumber(pos, amount, isCrit, element)
	local color = isCrit and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(255, 255, 255)
	if element == "fire" then color = Color3.fromRGB(255, 150, 50)
	elseif element == "dark" then color = Color3.fromRGB(150, 80, 200) end
	
	local size = isCrit and 26 or 18
	local text = isCrit and ("💥 " .. amount) or tostring(amount)
	
	local dmgLabel = Instance.new("TextLabel")
	dmgLabel.Size = UDim2.new(0, 100, 0, 30)
	dmgLabel.Position = UDim2.new(0, pos.X - 50, 0, pos.Y - 15)
	dmgLabel.BackgroundTransparency = 1
	dmgLabel.Text = text
	dmgLabel.TextColor3 = color
	dmgLabel.Font = Enum.Font.GothamBold
	dmgLabel.TextSize = size
	dmgLabel.TextStrokeTransparency = 0.3
	dmgLabel.ZIndex = 20
	dmgLabel.Parent = dmgNumberFolder
	
	-- Float up and fade
	local startY = dmgLabel.Position.Y.Offset
	for i = 1, 25 do
		task.wait(0.025)
		dmgLabel.Position = UDim2.new(0, dmgLabel.Position.X.Offset + (isCrit and math.sin(i * 0.3) * 1.5 or 0), 0, dmgLabel.Position.Y.Offset - 2.5)
		dmgLabel.TextTransparency = i / 25
		if not dmgLabel.Parent then break end
	end
	dmgLabel:Destroy()
end

-- EnemyHit handler
local enemyHitRemote = ReplicatedStorage:FindFirstChild("EnemyHit")
if enemyHitRemote then
	enemyHitRemote.OnClientEvent:Connect(function(enemyId, damage, isCrit, element, enemyType)
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			local cam = workspace.CurrentCamera
			if root and cam then
				local screenPos, onScreen = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 5, 0))
				if onScreen then
					local xOffset = math.random(-80, 80)
					showDamageNumber(Vector2.new(screenPos.X + xOffset, screenPos.Y - 40), damage, isCrit, element)
				end
			end
		end
	end)
end

-- PlayerDamaged handler
local pDamaged = ReplicatedStorage:FindFirstChild("PlayerDamaged")
if pDamaged then
	pDamaged.OnClientEvent:Connect(function(damage, enemyType)
		local flash = Instance.new("Frame")
		flash.Size = UDim2.new(1, 0, 1, 0)
		flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		flash.BackgroundTransparency = 0.7
		flash.BorderSizePixel = 0
		flash.ZIndex = 100
		flash.Parent = screenGui
		
		for i = 1, 12 do
			task.wait(0.025)
			flash.BackgroundTransparency = flash.BackgroundTransparency + 0.03
			if not flash.Parent then break end
		end
		flash:Destroy()
		
		hintText.Text = "💥 " .. tostring(damage) .. " damage taken!"
		task.delay(1.5, function()
			if hintText and hintText.Text:find("damage taken") then
				hintText.Text = "Use abilities and attack to defeat enemies!"
			end
		end)
	end)
end

-- Weapons module reference for attack range
-- Attack cooldown tracking
local lastAttackTime = 0
local myAttackSpeed = 0.8 -- base, updated on character spawn

-- Update local attack speed when character spawns (in the spawnRemote handler below)
local function getWeaponCooldown()
	return myAttackSpeed
end

-- Continuous enemy targeting update
local function findNearestEnemy()
	local char = player.Character
	if not char then return nil end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	
	local nearestPart = nil
	local nearestDist = 15
	-- No camera needed for distance-only check
	
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v:GetAttribute("EnemyType") and v:GetAttribute("IsAlive") ~= false then
			local dist = (v.Position - root.Position).Magnitude
			if dist < nearestDist then
				-- Check if enemy is roughly in front of the player (within 120 degree cone)
				local dirToEnemy = (v.Position - root.Position).Unit
				local lookDir = root.CFrame.LookVector
				local dot = dirToEnemy:Dot(lookDir)
				if dot > -0.5 then
					nearestDist = dist
					nearestPart = v
				end
			end
		end
	end
	
	return nearestPart
end

-- Track the currently targeted enemy
local currentTarget = nil

-- Update targeting reticle periodically (not every frame - every 0.1s is enough)
local lastTargetUpdate = 0
RunService.BindToRenderStep("TargetingUpdate", Enum.RenderPriority.Camera.Value - 1, function()
	local cam = workspace.CurrentCamera
	if not cam then return end
	
	-- Only search for target every 5 frames to save performance
	local now = tick()
	if now - lastTargetUpdate > 0.1 then
		lastTargetUpdate = now
		currentTarget = findNearestEnemy()
	end
	
	local target = currentTarget
	
	-- Always keep reticle at center of screen, only highlight when target found
	-- The reticle position is always center - we just change its appearance
	aireticle.Position = UDim2.new(0.5, -20, 0.5, -20)
	
	if target then
		local enemyData = target:GetAttribute("EnemyType") or ""
		targetLabel.Text = "🎯 " .. enemyData
		targetLabel.Visible = true
		
		-- Light up the dot and crosshair
		reticleDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		reticleDot.BackgroundTransparency = 0
		reticleH.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		reticleV.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
		
		-- Show boss label
		if target:GetAttribute("IsBoss") then
			targetLabel.Text = "👑 BOSS - " .. enemyData
			targetLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		else
			targetLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		end
	else
		-- Dim reticle at center
		targetLabel.Visible = false
		reticleDot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		reticleDot.BackgroundTransparency = 0.5
		reticleH.BackgroundColor3 = colors.accent
		reticleV.BackgroundColor3 = colors.accent
	end
end)

-- ============ SHARED ACTION FUNCTIONS ============
-- These are called by BOTH button click handlers AND keyboard shortcuts

local function performAttack()
	local dealRemote = ReplicatedStorage:FindFirstChild("DealDamage")
	if not dealRemote then return end
	
	-- Cooldown check
	local now = tick()
	local cd = getWeaponCooldown()
	if now - lastAttackTime < cd then return end
	lastAttackTime = now
	
	-- Show cooldown overlay
	attackCd.Visible = true
	attackCd.BackgroundTransparency = 0.6
	attackCdLabel.Text = tostring(cd)
	for i = cd, 0.25, -0.25 do
		task.wait(0.25)
		attackCdLabel.Text = string.format("%.1f", i)
	end
	attackCd.Visible = false
	attackCdLabel.Text = ""
	
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	-- Check targets: prefer current reticle target, then nearest
	local targetPart = currentTarget
	if not targetPart or (targetPart.Position - root.Position).Magnitude > 15 then
		targetPart = findNearestEnemy()
	end
	
	if targetPart then
		-- Face the target
		local lookCF = CFrame.lookAt(root.Position, targetPart.Position)
		root.CFrame = CFrame.new(root.Position.X, root.Position.Y, root.Position.Z) * CFrame.Angles(0, (lookCF - lookCF.Position):ToOrientation(), 0)
		
		-- Fire the attack to server
		dealRemote:FireServer(targetPart.Name, nil, targetPart:GetAttribute("EnemyType"))
		
		-- Weapon flash animation on the weapon handle
		local weaponHandle = char:FindFirstChild("WeaponHandle")
		if weaponHandle then
			local originalColor = weaponHandle.Color
			local originalSize = weaponHandle.Size
			weaponHandle.Color = Color3.fromRGB(255, 255, 200)
			weaponHandle.Size = originalSize * 1.2
			task.delay(0.08, function()
				if weaponHandle and weaponHandle.Parent then
					weaponHandle.Color = originalColor
					weaponHandle.Size = originalSize
				end
			end)
		end
		
		hintText.Text = "⚔️ Attacked!"
		task.delay(0.5, function()
			if hintText and hintText.Text == "⚔️ Attacked!" then
				hintText.Text = "Use abilities and attack to defeat enemies!"
			end
		end)
	end
end

local function performAbility()
	local useRemote = ReplicatedStorage:FindFirstChild("UseAbility")
	if useRemote then useRemote:FireServer() end
	abilCd.Visible = true
	abilCd.Text = "..."
end

local function performInteract()
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v:GetAttribute("InteractType") then
			if (v.Position - root.Position).Magnitude < 8 then
				local it = v:GetAttribute("InteractType")
				local id = v:GetAttribute("InteractData")
				if it == "chest" then
					local cr = ReplicatedStorage:FindFirstChild("OpenChest")
					if cr then cr:FireServer(id) end
				elseif it == "crystal" then
					local cr = ReplicatedStorage:FindFirstChild("CollectCrystal")
					if cr then cr:FireServer(id, v:GetAttribute("CrystalName")) end
				elseif it == "coin" then
					local cr = ReplicatedStorage:FindFirstChild("CollectCoin")
					if cr then cr:FireServer(v:GetAttribute("Amount") or 1) end
				elseif it == "gem" then
					local cr = ReplicatedStorage:FindFirstChild("CollectGem")
					if cr then cr:FireServer(v:GetAttribute("Amount") or 1) end
				end
				break
			end
		end
	end
end

local function performJump()
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.Jump = true end
	end
end

local function performSprintStart()
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 32 end
	end
end

local function performSprintEnd()
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end
end

-- ============ BUTTON CLICK HANDLERS ============
attackBtn.MouseButton1Click:Connect(performAttack)
abilityBtn.MouseButton1Click:Connect(performAbility)
interactBtn.MouseButton1Click:Connect(performInteract)

jumpBtn.MouseButton1Down:Connect(performJump)
sprintBtn.MouseButton1Down:Connect(performSprintStart)
sprintBtn.MouseButton1Up:Connect(performSprintEnd)

-- ============ KEYBOARD / MOUSE SHORTCUTS ============
local shiftHeld = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	local key = input.KeyCode
	
	if key == Enum.KeyCode.Space then
		performJump()
	elseif key == Enum.KeyCode.Q then
		performAbility()
	elseif key == Enum.KeyCode.E then
		performInteract()
	elseif key == Enum.KeyCode.LeftShift or key == Enum.KeyCode.RightShift then
		shiftHeld = true
		performSprintStart()
	elseif key == Enum.KeyCode.ButtonR2 or key == Enum.KeyCode.ButtonX then
		performAbility()  -- controller RB/X
	elseif key == Enum.KeyCode.ButtonL2 or key == Enum.KeyCode.ButtonA then
		performJump()  -- controller LB/A
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		shiftHeld = false
		performSprintEnd()
	end
end)

-- Left mouse click = attack (when not on UI elements)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- Avoid double-fire: don't attack if clicking directly on the attack button
		local mousePos = UserInputService:GetMouseLocation()
		local absPos = attackBtn.AbsolutePosition
		local absSize = attackBtn.AbsoluteSize
		local onAttackBtn = mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X 
			and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
		
		if not onAttackBtn then
			performAttack()
		end
	end
end)

-- ============ CHARACTER SPAWN HANDLING ============
local myCharacterId = "warrior"

if spawnRemote then
	spawnRemote.OnClientEvent:Connect(function(charData)
		myCharacterId = charData.id or "warrior"
		-- Update local attack speed from weapon data
		local weaponId = charData.weapon or charData.weaponId
		if weaponId then
			local wData = Weapons[weaponId]
			if wData then
				myAttackSpeed = wData.attackSpeed or 0.8
			end
		end
		charSelectFrame.Visible = false
		hintText.Text = "Ready! Use the island panel to teleport!"
	end)
end

local abActivated = ReplicatedStorage:FindFirstChild("AbilityActivated")
if abActivated then
	abActivated.OnClientEvent:Connect(function(ability)
		if ability and ability.name then
			abilityLabel.Text = "⚡\n" .. ability.name
		end
		
		local cd = ability.cooldown or 15
		abilCd.Visible = true
		abilCd.Text = tostring(cd)
		abilityBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
		abilityBtn.Active = false
		for i = cd - 1, 0, -1 do
			task.wait(1)
			abilCd.Text = tostring(i)
		end
		abilCd.Visible = false
		abilityBtn.Active = true
		
		local Characters = require(ReplicatedStorage.Shared.Characters)
		local charData = Characters[myCharacterId]
		if charData and charData.ability then
			abilityLabel.Text = "⚡\n" .. charData.ability.name
		else
			abilityLabel.Text = "⚡\nAbility"
		end
		abilityBtn.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
	end)
end

-- Boss spawn notification handler
local bossSpawnEvent = ReplicatedStorage:FindFirstChild("BossSpawned")
if bossSpawnEvent then
	bossSpawnEvent.OnClientEvent:Connect(function(bossType, position)
		hintText.Text = "👑 BOSS has appeared! Defeat it for great rewards!"
		task.delay(5, function()
			if hintText and hintText.Text:find("BOSS") then
				hintText.Text = "Use abilities and attack to defeat enemies!"
			end
		end)
	end)
end

print("[Treasure Quest HUD] Loaded with enhanced design")
end)

if not success then
	warn("[Treasure Quest HUD] Error: " .. tostring(err))
end
