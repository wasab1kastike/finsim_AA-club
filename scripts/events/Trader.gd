extends GameEvent
class_name TraderEvent

## Resources is globally accessible via `class_name`; preloading is unnecessary.

@export var required_halot: float = 10.0

func can_trigger() -> bool:
    return GameState.res.get(Resources.HALOT, 0) >= required_halot
