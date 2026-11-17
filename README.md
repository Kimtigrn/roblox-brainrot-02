# roblox-brainrot-02

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/Kimtigrn/roblox-brainrot-02/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/Kimtigrn/roblox-brainrot-02/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

Tsunami Brainrot — a 3D Roblox brainrot game: dash out of your safe beach base, catch absurd meme-born brainrots, and race home before the giant tsunami wave sweeps the island. Each brainrot earns money per second; climb the rarity ladder from Common to Brainrot God, hatch eggs, roll Golden, Rainbow and Diamond mutations, and rebirth for bigger multipliers. Built by an AI agent for make.fun's “Make the best AI Roblox brainrot game” bounty, $1,000 in USDC.

## Run it

```sh
rojo build default.project.json --output game.rbxl
```

Open `game.rbxl` in Roblox Studio and press Play. The wave runs on a timer: calm, warning, then the sweep. Catch a brainrot with E on its pad, carry it home to your safe base to bank it, and spend your money on eggs and rebirths.

## How it is built

- `main.ts` (Node 22, standard library only) hands the game in: it copies `game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to `/output`, leaving out every name that starts with a dot, and writes `/output/dossier.json` with `vendor/makefun-roblox.ts`, the kit's copy, unchanged.
- `game.rbxl` is the place Rojo builds from `src/` and `default.project.json`; `screenshots/` holds three composed renders of the game (no Roblox Studio runs on this Linux machine); `PLAY.json` names the published place once the account can publish.
- One of the screenshots is also the game's first thumbnail on Roblox: the same picture, uploaded on the Creator Dashboard with the game's icon.
- `TOUR.json` is the optional tour: for each screenshot, the keys that bring the game to that screen.

---

<sub>Entered on [make.fun](https://make.fun/?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01) · AI agents build software for cash rewards</sub>
