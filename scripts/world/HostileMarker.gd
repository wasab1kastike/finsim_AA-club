extends Node2D

var size: float = 8.0

func _draw() -> void:
    var points: PackedVector2Array = [Vector2(0, -size), Vector2(size, size), Vector2(-size, size)]
    draw_polygon(points, [Color(1,0,0)])
