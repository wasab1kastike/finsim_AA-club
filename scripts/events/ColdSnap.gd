extends GameEvent
class_name ColdSnapEvent

const Resources = preload("res://scripts/core/Resources.gd")

@export var duration_ticks: int = 30
@export var penalty_multiplier: float = 0.8
@export var steam_cost: float = 2.0

func apply() -> bool:
    if not super.apply():
        return false
    if GameState.res.get(Resources.STEAM, 0) >= steam_cost:
        GameState.res[Resources.STEAM] -= steam_cost
        GameState.production_modifier = 1.0
    else:
        GameState.production_modifier = penalty_multiplier
    GameState.modifier_ticks_remaining = duration_ticks
    return true
