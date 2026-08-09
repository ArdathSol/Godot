# Neon Forge: City of Tomorrow

A touch-first mobile idle/incremental game built with Godot 4.

## Implemented
- 12 production zones and automated idle income
- 108 upgrades with scaling costs and per-zone multipliers
- 60 collectibles across six rarity tiers
- 60 achievements (including hidden achievements)
- 36 progression quests
- Prestige/rebirth with permanent Cores
- Offline progression (8h cap, 75% efficiency)
- Daily rewards
- Modular event currency/progression loop
- Save/load + versioned save schema
- Statistics
- Touch-first portrait UI
- Settings for sound/music/vibration/reduced motion
- Localization system: German, English, French, Spanish, Italian, Portuguese
- Mobile-safe viewport and Android-ready Godot project

## Run
1. Install Godot 4.3+
2. Import `project.godot`
3. Press F6/F5

## Android export
Install Android build templates in Godot, configure JDK/Android SDK, then create an Android export preset.

## Project structure
- `scenes/Main.tscn` – main scene
- `scripts/main.gd` – UI/gameplay orchestration
- `scripts/game_state.gd` – save/load/migration
- `scripts/game_content.gd` – generated content definitions
- `scripts/localization.gd` – six-language localization
- `docs/GAME_DESIGN.md` – design and progression specification

No paid assets or plugins are required.
