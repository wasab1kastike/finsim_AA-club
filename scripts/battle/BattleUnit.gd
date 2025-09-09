extends Node2D
class_name BattleUnit

@export var unit: Unit
@export var team: int = 0
var hex_pos: Vector2i = Vector2i.ZERO

func set_hex_pos(hex: Vector2i, map: Node) -> void:
    hex_pos = hex
    position = map.axial_to_world(hex.x, hex.y)

func is_alive() -> bool:
    return unit.is_alive()

func apply_team_color() -> void:
    var poly: Polygon2D = $Polygon2D
    if team == 0:
        poly.color = Color(0.2, 0.6, 1.0)
    else:
        poly.color = Color(1.0, 0.3, 0.3)
