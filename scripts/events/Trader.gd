extends GameEvent
class_name TraderEvent

const Resources = preload("res://scripts/core/Resources.gd")

@export var required_wood: float = 10.0

func can_trigger() -> bool:
    return GameState.res.get(Resources.WOOD, 0) >= required_wood
