extends GameEvent
class_name TraderEvent

const Resources = preload("res://scripts/core/Resources.gd")

@export var required_halot: float = 10.0

func can_trigger() -> bool:
    return GameState.res.get(Resources.HALOT, 0) >= required_halot
