# Neon Forge: City of Tomorrow

**Primary version: Browser/PWA — no Godot installation required.**

Neon Forge is a touch-first mobile idle/incremental game that runs directly in modern browsers and can be hosted for free with GitHub Pages.

## Browser version
Open `index.html` through a web server or enable GitHub Pages for this repository.

### GitHub Pages
1. Open this repository on GitHub.
2. Go to **Settings → Pages**.
3. Under **Build and deployment**, choose **Deploy from a branch**.
4. Select branch **main** and folder **/(root)**.
5. Click **Save**.
6. GitHub will publish the game at the Pages URL shown in the Pages settings. For this repository the normal project-site address is `https://ardathsol.github.io/Godot/`.

## Implemented in the browser version
- 12 production zones with idle income
- 108 upgrades with scaling prices and multipliers
- 60 collectibles across six rarities
- 60 achievements including secret achievements
- 36 progression quests
- Prestige/rebirth with permanent Cores
- Offline progression with an 8-hour cap and 75% efficiency
- Daily rewards
- Event progression and Event Chips
- Statistics
- Browser save system using `localStorage`
- Save export to JSON
- Touch-first responsive UI for phones, tablets and desktop
- Haptic feedback where supported
- German, English, French, Spanish, Italian and Portuguese
- PWA manifest + service worker for installable/offline behavior

## Main web files
- `index.html` — browser entry point
- `styles.css` — responsive mobile UI
- `app.js` — all gameplay, economy, save, progression and UI logic
- `manifest.webmanifest` — installable PWA configuration
- `sw.js` — offline cache/service worker
- `icon.svg` — app icon
- `.nojekyll` — static GitHub Pages configuration

## Save data
Progress is stored locally in the browser. Different browsers/devices have separate saves unless the exported JSON save is transferred manually.

## Legacy Godot files
The previous Godot implementation is still present in the repository as reference, but it is **not required** to run or test the current game.

No paid assets or plugins are required.
