# Game Design – Neon Forge: City of Tomorrow

## Identity
A near-future industrial city builder where the player grows a garage startup into a solar-system-scale technology empire. The fantasy is not medieval power: it is ownership, automation, discovery, and exponential engineering.

## Core loop
Produce Credits → buy upgrades → automate districts → unlock new zones → collect prototypes → finish contracts/achievements → prestige for Cores → rebuild faster with permanent multipliers.

## Currencies
- Credits: primary purchase currency
- Energy: active-play secondary resource and future special-system hook
- Research: achievement/quest/meta resource
- Cores: permanent prestige currency
- Event Chips: event exchange currency

## Progression
12 major zones span Garage Node to Singularity Core. Each zone has nine upgrade families (108 total). Unlock prices and production scale exponentially while prestige and collectible bonuses keep resets productive rather than punitive.

## Collections
60 prototypes: drones, rovers, robots, chips, vehicles, blueprints, AIs, reactors, satellites and skins. Six rarities from Common to Mythic. Owned collectibles contribute a global production multiplier.

## Achievements and quests
60 achievements monitor earning, tapping, upgrades, collection, prestige and zone progression. 36 city contracts provide milestone payouts. Several achievements are hidden until discovered.

## Prestige
At lifetime revenue thresholds, the player earns permanent Cores. Rebirth resets run currencies, normal upgrades and zones while preserving settings, achievements, collectibles and prestige history.

## Offline progression
Production is calculated from the last saved timestamp up to an 8-hour cap at 75% normal efficiency, then granted immediately at launch.

## Retention cadence
- 0–5 min: manual production, first upgrades
- 5–30 min: first automation/zone unlocks and collectibles
- 30–120 min: stronger quests, achievement chains and event exchange
- 2–5 h: multiple districts and first rebirth planning
- 5–20 h: prestige acceleration, higher rarity collections and late districts
- 20 h+: optimization, collection completion, prestige scaling and event loops

## Visual direction
Dark navy sci-fi interface, cyan highlights, compact holographic panels, large touch targets and a portrait-first one-handed layout.

## Architecture
Godot 4 with data-driven content classes, versioned JSON save state, localization dictionary, procedural UI construction and modular progression calculations. No external dependencies.
