extends Action
class_name GameEvent

@export var name: String = ""
@export var description: String = ""

func can_trigger() -> bool:
    return can_apply()
