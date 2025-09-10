extends Node

## Resources is globally available via `class_name`; no need to preload it.

const COOLDOWN_TICKS := 20 # 10 seconds at 0.5s per tick

var cooldown_ticks_remaining: int = 0
var world: Node = null

func _ready() -> void:
    GameClock.tick.connect(_on_tick)

func _on_tick() -> void:
    if cooldown_ticks_remaining > 0:
        cooldown_ticks_remaining -= 1

func can_spend() -> bool:
    return cooldown_ticks_remaining <= 0 and GameState.res.get(Resources.SISU, 0.0) >= 5.0

func spend() -> bool:
    if not can_spend():
        return false
    GameState.res[Resources.SISU] = GameState.res.get(Resources.SISU, 0.0) - 5.0
    cooldown_ticks_remaining = COOLDOWN_TICKS
    _heal_units()
    return true

func _heal_units() -> void:
    var nodes_by_id: Dictionary = {}
    if world and world.has_node("Units"):
        for child in world.units_root.get_children():
            nodes_by_id[child.id] = child
    for i in range(GameState.units.size()):
        var data: Dictionary = GameState.units[i]
        var uid: String = data.get("id", "")
        var hp: int = data.get("hp", 0)
        var max_hp: int = hp
        var path: String = data.get("data_path", "")
        if path != "":
            var ud = load(path)
            if ud:
                max_hp = roundi(ud.max_health)
        var heal_amount: int = roundi(max_hp * 0.2)
        hp = min(max_hp, hp + heal_amount)
        data["hp"] = hp
        GameState.units[i] = data
        if nodes_by_id.has(uid):
            var node = nodes_by_id[uid]
            node.hp = hp
