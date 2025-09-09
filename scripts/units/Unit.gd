extends Resource
class_name Unit

@export var name: String = ""
@export var max_health: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var speed: float = 1.0

var health: int

func _init():
    health = max_health

func is_alive() -> bool:
    return health > 0

func take_damage(amount: int) -> void:
    var effective: int = max(amount - defense, 0)
    health = max(health - effective, 0)

func deal_damage(target: Unit) -> void:
    target.take_damage(attack)

func heal(amount: int) -> void:
    health = min(health + amount, max_health)
