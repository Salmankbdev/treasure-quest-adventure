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
	-- Sound configuration (verified working Roblox sound IDs)
	Sounds = {
		Hit = "rbxassetid://160005893",
		CritHit = "rbxassetid://4825495061",
		Kill = "rbxassetid://12221867",
		Ability = "rbxassetid://130844619",
		LevelUp = "rbxassetid://138232555",
		CoinCollect = "rbxassetid://138232555",
		CrystalCollect = "rbxassetid://130844619",
		Teleport = "rbxassetid://161006044",
		BossSpawn = "rbxassetid://12221867",
		BossDefeat = "rbxassetid://12221867",
		ChestOpen = "rbxassetid://160005893",
		Purchase = "rbxassetid://4825495061",
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
