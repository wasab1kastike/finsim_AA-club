extends Resource
class_name Unit

const Pathfinder := preload("res://scripts/world/Pathfinder.gd")

@export var name: String = ""
@export var max_health: int = 100
@export var attack: int = 10
@export var defense: int = 5
@export var speed: float = 1.0
@export var owner: String = ""

var health: int
var position: Vector2i = Vector2i.ZERO

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

func move_to(target: Vector2i, is_passable: Callable) -> Array[Vector2i]:
    var path := Pathfinder.a_star(position, target, is_passable)
    if path.is_empty():
        return []
    position = target
    return path
