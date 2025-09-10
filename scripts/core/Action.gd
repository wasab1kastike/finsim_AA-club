extends Resource
class_name Action

@export var costs: Dictionary = {}
@export var effects: Dictionary = {}
@export var cooldown: float = 0.0

var last_used: float = -INF

func _has_resources() -> bool:
    for key in costs.keys():
        if GameState.res.get(key, 0) < costs[key]:
            return false
    return true

func can_apply() -> bool:
    return Time.get_unix_time_from_system() - last_used >= cooldown and _has_resources()

func apply() -> bool:
    if not can_apply():
        return false
    for key in costs.keys():
        GameState.res[key] = GameState.res.get(key, 0) - costs[key]
    for key in effects.keys():
        GameState.res[key] = GameState.res.get(key, 0) + effects[key]
    if GameState.has_method("clamp_resources"):
        GameState.clamp_resources()
    last_used = Time.get_unix_time_from_system()
    return true

