# finsim_aa-club

A 4X strategy autobattler with idle elements.

## Gameplay
- Start with a single sauna in Finland.
- Gain units over time or by clicking the löyly.
- Finnish drunken warriors automatically battle enemies and build new saunas.

## Status
Vertical slice WIP: 3 buildings, 3 units, 3 lanes, 1 neighbor AI, prestige stub, events.

## Tech
- Godot 4.x (GDScript), Desktop + Web
- Trunk-based Git; feature branches (`feat/...`)

## Build
1. Open in Godot 4.x
2. Press ▶ to run
3. Exports via export_presets.cfg (to be added)

## Testing
Run automated tests in headless mode:

```
godot4 --headless -s tests/test_runner.gd
```

## Controls
Mouse-only prototype:  
- Left panel: build  
- Center: map  
- Bottom: battle lanes  
- Right: policies/events  
- Sisu button: clutch play
