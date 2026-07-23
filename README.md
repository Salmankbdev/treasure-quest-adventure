# Treasure Quest Adventure

A Roblox adventure game built with Rojo. Explore 7 islands, battle enemies, collect crystals, upgrade weapons, and defeat bosses in this feature-rich RPG.

## Features

- **7 Unique Islands** — Forest, Desert, Snow Mountain, Volcano, Dark Castle, Crystal Cave, Sky Temple — each with distinct environments, enemies, and bosses
- **Character Classes** — Choose from Paladin, Druid, Berserker, Warrior, Archer, Mage, Ninja, Explorer, Pirate, and more — each with unique abilities
- **Weapon System** — 10+ weapons with 5 upgrade tiers (Iron → Steel → Crystal → Legendary → Excalibur)
- **Combat Engine** — Real-time melee/ranged combat with damage calculation, critical hits, elemental bonuses, and defense reduction
- **Enemy AI** — Enemies patrol, aggro, chase, attack, and respawn. Bosses have special behaviors.
- **Power-ups** — Speed Boost, Double Damage, Shield, Health Potion, Energy Potion, Coin Magnet, etc.
- **Shop System** — Buy weapons, potions, and weapon upgrades with coins and gems
- **Crystal Collection** — Collect a crystal from each island to unlock the next
- **Dynamic Environments** — Weather, lighting, and fog change per island (sandstorms, blizzards, ash storms)
- **HUD** — Full-featured UI with health/energy bars, minimap, compass, quest log, inventory, settings
- **Difficulty Settings** — Easy, Normal, Hard, Nightmare — affects enemy damage and coin drops

## Project Structure

```
treasure-quest/
├── default.project.json          # Rojo project configuration
├── src/
│   ├── ReplicatedStorage/
│   │   └── Shared/               # Shared data modules
│   │       ├── Characters.lua    # Character class definitions
│   │       ├── Config.lua        # Game configuration
│   │       ├── Enemies.lua       # Enemy definitions
│   │       ├── Islands.lua       # Island definitions
│   │       ├── Items.lua         # Item definitions
│   │       ├── PowerUps.lua      # Power-up definitions
│   │       └── Weapons.lua       # Weapon definitions
│   ├── ServerScriptService/
│   │   └── Server/               # Server-side logic
│   │       ├── GameManager.server.lua   # Entry point, event creation, player management
│   │       ├── CombatManager.lua        # Damage calculation, enemy combat
│   │       ├── RewardManager.lua        # Coin/gem/xp collection, chests, crystals
│   │       ├── ShopManager.lua          # Shop, buying items/weapons/upgrades
│   │       ├── WorldManager.lua         # Island zones, environments, lighting
│   │       └── EnemySpawner.lua         # Enemy spawning, AI behavior
│   ├── StarterGui/
│   │   └── UI/
│   │       └── HUD.client.lua   # Full HUD (health, inventory, minimap, etc.)
│   └── StarterPlayer/
│       └── StarterPlayerScripts/
│           └── Client/
│               ├── PlayerController.client.lua   # Movement, combat, abilities
│               └── VisualEffects.client.lua      # Particle effects, damage numbers
```

## Prerequisites

- [Rojo](https://rojo.space/) v7.x
- Roblox Studio

## Development

1. Clone the repo:
   ```bash
   git clone https://github.com/salmankb6/treasure-quest-adventure.git
   cd treasure-quest-adventure
   ```

2. Build the place file:
   ```bash
   rojo build --output treasure-quest.rbxlx
   ```

3. Open `treasure-quest.rbxlx` in Roblox Studio.

4. For live sync during development:
   ```bash
   rojo serve
   ```
   Then connect from Studio via the Rojo plugin.

## Islands

| Island | Difficulty | Boss | Crystal |
|--------|-----------|------|---------|
| Forest Island | Easy | Goblin King | Emerald Crystal |
| Desert Island | Normal | Temple Guardian | Ruby Crystal |
| Snow Mountain | Normal | Frost Giant | Sapphire Crystal |
| Volcano Island | Hard | Fire Dragon | Amber Crystal |
| Dark Castle | Nightmare | Dark King | Shadow Crystal |
| Crystal Cave | Hard | Dark King | Diamond Crystal |
| Sky Temple | Nightmare | Fire Dragon King | Storm Crystal |
