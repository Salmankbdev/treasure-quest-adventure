return {
	GameName = "Treasure Quest Adventure",
	MaxPlayers = 8,
	MaxEnergy = 100,
	MaxHealth = 100,
	RespawnTime = 3,
	CoinMultiplier = 1,
	GemMultiplier = 1,
	Levels = {
		Easy = { damageMultiplier = 0.7, coinMultiplier = 1 },
		Normal = { damageMultiplier = 1, coinMultiplier = 1.5 },
		Hard = { damageMultiplier = 1.5, coinMultiplier = 2 },
		Nightmare = { damageMultiplier = 2, coinMultiplier = 3 },
	},
	-- Sound configuration (Roblox free sounds)
	Sounds = {
		Hit = "rbxassetid://4712381813",
		CritHit = "rbxassetid://4712386962",
		Kill = "rbxassetid://4712384545",
		Ability = "rbxassetid://4712381194",
		LevelUp = "rbxassetid://4712383709",
		CoinCollect = "rbxassetid://4712379623",
		CrystalCollect = "rbxassetid://4712380437",
		Teleport = "rbxassetid://4712378717",
		BossSpawn = "rbxassetid://4712377962",
		BossDefeat = "rbxassetid://4712386057",
		ChestOpen = "rbxassetid://4712376493",
		Purchase = "rbxassetid://4712382953",
	},
	-- Ambient particle textures (free)
	Particles = {
		Spark = "rbxassetid://2842055869",
		Fire = "rbxassetid://321526116",
		Smoke = "rbxassetid://2216405431",
		Glow = "rbxassetid://2842055869",
		Leaf = "rbxassetid://4629858649",
		Snow = "rbxassetid://6616484626",
		Sand = "rbxassetid://4629873557",
		Ash = "rbxassetid://2216405431",
		Bubble = "rbxassetid://4629857040",
	},
	-- Weather cycle timing
	WeatherCycle = {
		DayLength = 600,
		NightLength = 300,
	},
	XPPerLevel = 100,
	LevelStatBonus = { health = 10, energy = 5, damage = 1 },
}
