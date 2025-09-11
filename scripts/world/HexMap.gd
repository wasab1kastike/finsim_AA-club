extends Node2D
class_name HexMap

@onready var grid: TileMap     = $TileMap
@onready var fog: TileMapLayer = $TileMap/Fog

signal tile_clicked(cell: Vector2i)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var cell := grid.local_to_map(grid.to_local(event.position))
        emit_signal("tile_clicked", cell)

func axial_to_world(qr: Vector2i) -> Vector2:
    return grid.map_to_local(qr)

func reveal_area(center: Vector2i, reveal_radius: int = 2) -> void:
    for cell in _disc(center, reveal_radius):
        fog.erase_cell(cell)

func reveal_all() -> void:
    fog.clear()

func _disc(center: Vector2i, radius: int) -> Array[Vector2i]:
    var cells: Array[Vector2i] = []
    for q in range(-radius, radius + 1):
        for r in range(max(-radius, -q - radius), min(radius, -q + radius) + 1):
            cells.append(center + Vector2i(q, r))
    return cells

