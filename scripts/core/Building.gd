extends Resource
class_name Building

@export var name: String = ""
@export var construction_cost: Dictionary = {}
@export var production_rates: Dictionary = {}
@export var level: int = 1

func get_construction_cost() -> Dictionary:
    return construction_cost

func get_production_rates() -> Dictionary:
    return production_rates

func upgrade() -> void:
    level += 1
    _on_upgrade()

func _on_upgrade() -> void:
    pass
