extends Action
class_name GameEvent

@export var name: String = ""
@export var description: String = ""
@export var choices: Array[Dictionary] = []

func can_trigger() -> bool:
    return can_apply()

func apply() -> bool:
    return super.apply()
