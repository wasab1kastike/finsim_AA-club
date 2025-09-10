extends GameEvent
class_name RuneDiscoveryEvent

const Resources = preload("res://scripts/core/Resources.gd")

@export var required_research: float = 5.0

func can_trigger() -> bool:
    return GameState.res.get(Resources.RESEARCH, 0) >= required_research
