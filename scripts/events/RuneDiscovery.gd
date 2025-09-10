extends GameEvent
class_name RuneDiscoveryEvent

## Use global Resources class instead of preloading to avoid shadowing.

@export var required_saunatieto: float = 5.0

func can_trigger() -> bool:
    return GameState.res.get(Resources.SAUNATIETO, 0) >= required_saunatieto
