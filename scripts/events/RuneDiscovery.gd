extends GameEvent
class_name RuneDiscoveryEvent

const Resources = preload("res://scripts/core/Resources.gd")

@export var required_saunatieto: float = 5.0

func can_trigger() -> bool:
    return GameState.res.get(Resources.SAUNATIETO, 0) >= required_saunatieto
