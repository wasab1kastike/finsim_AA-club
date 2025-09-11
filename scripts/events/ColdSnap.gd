extends GameEvent
class_name ColdSnapEvent


@export var duration_ticks: int = 30
@export var penalty_multiplier: float = 0.8
@export var loyly_cost: float = 2.0

func apply() -> bool:
    if not super.apply():
        return false
    if GameState.res.get(Resources.LOYLY, 0) >= loyly_cost:
        GameState.res[Resources.LOYLY] -= loyly_cost
        GameState.production_modifier = 1.0
    else:
        GameState.production_modifier = penalty_multiplier
    GameState.modifier_ticks_remaining = duration_ticks
    return true
