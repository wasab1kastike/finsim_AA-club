extends Node2D

signal tile_clicked(qr: Vector2i)

@onready var hex_map: TileMap = $HexMap
@onready var units_root: Node2D = $Units
@onready var season_tint: CanvasModulate = $SeasonTint

var selected_unit: Node = null
var unit_scene: PackedScene = preload("res://scenes/units/Unit.tscn")
const Pathing = preload("res://scripts/world/Pathing.gd")

func _ready() -> void:
    hex_map.tile_clicked.connect(_on_tile_clicked)
    for data in GameState.units:
        var u = unit_scene.instantiate()
        u.from_dict(data)
        u.position = hex_map.axial_to_world(u.pos_qr)
        units_root.add_child(u)
        selected_unit = u

func _on_tile_clicked(qr: Vector2i) -> void:
    emit_signal("tile_clicked", qr)
    if selected_unit:
        var path: Array[Vector2i] = Pathing.bfs_path(selected_unit.pos_qr, qr, func(p: Vector2i):
            return GameState.tiles.has(p) and GameState.tiles[p]["terrain"] != "lake"
        )
        if path.size() > 1 and path.size() - 1 <= selected_unit.move:
            var next: Vector2i = path[1]
            selected_unit.pos_qr = next
            selected_unit.position = hex_map.axial_to_world(next)
            for i in range(GameState.units.size()):
                var u: Dictionary = GameState.units[i]
                if u.get("type", "") == selected_unit.type:
                    GameState.units[i] = selected_unit.to_dict()
                    break
            hex_map.reveal_area(next, 1)
            GameState.save()

func spawn_unit_at_center() -> void:
    var u: Node = unit_scene.instantiate()
    units_root.add_child(u)
    u.pos_qr = Vector2i.ZERO
    u.position = hex_map.axial_to_world(u.pos_qr)
    GameState.units.append(u.to_dict())
    selected_unit = u
    hex_map.reveal_area(u.pos_qr, 1)
    GameState.save()

func reveal_all() -> void:
    hex_map.reveal_all()
    GameState.save()
    
func center_on(qr: Vector2i) -> void:
    position = -hex_map.axial_to_world(qr)

func set_season(season: String) -> void:
    season_tint.set_season(season)

