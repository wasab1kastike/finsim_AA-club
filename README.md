# finsim_aa-club

A 4X strategy autobattler with idle elements.

See [codex](codex.md) for detailed design notes, including the hex-grid combat model.

## Gameplay
- Start with a single sauna in Finland.
- Gain units over time or by clicking the löyly.
- Finnish drunken warriors automatically battle enemies on a hex-grid battlefield and build new saunas.

## Status
Vertical slice WIP: 3 buildings, 1 unit, hex-grid combat, 1 neighbor AI, saunakunnia stub, events.

## Tech
- Godot 4.4.1 (GDScript), Desktop + Web
- Trunk-based Git; feature branches (`feat/...`)

## Build
1. Install Godot 4.4.1.
2. Open `project.godot` in Godot 4.4.1 (Main Scene: `scenes/ui/Main.tscn`).
3. Press ▶ to run.
4. Exports via `export_presets.cfg` (Linux, Web, Windows).

> If you see a UID-upgrade dialog, run once in 4.4.1 and commit the updated `.tscn`/`.tres` files.

## Running on Windows 11

### Minimum Requirements
- Windows 11 (64-bit) with a Vulkan-capable GPU
- Godot Engine 4.4.1 for Windows
- 4 GB RAM and 1 GB free disk space

### How to Run
1. Download and install Godot 4.4.1 for Windows.
2. Clone this repository and open `project.godot` in Godot 4.4.1.
   - Or run directly: `godot4.exe --path .`
3. (Optional) Run tests: `godot4.exe --headless -s tests/test_runner.gd`
4. To export a standalone build, use the included **Windows Desktop** export preset.

## Runbook
Open the project in Godot 4.4.1 (Standard). In Project Settings, confirm the Main Scene is `scenes/ui/Main.tscn`.

AutoLoads:
- `GameClock` (`res://autoload/GameClock.gd`)
- `GameState` (`res://autoload/GameState.gd`)
- `RNG` (`res://autoload/RNG.gd`)
- `EventManager` (`res://autoload/EventManager.gd`)

Press ▶ to run, then use the Save/Load demo to test persistence.

## Testing
Run automated tests in headless mode:

```
godot4 --headless -s tests/test_runner.gd
```

## Controls
Mouse-only prototype:
- Left panel: build
- Center: hex-grid map & battle
- Right: policies/events
- Sisu button: clutch play
