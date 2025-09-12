extends Node2D
class_name HexMap

const TILE_SIZE := Vector2i(96, 84)

@export var radius: int = 0
@export var terrain_weights: Dictionary = {}

@onready var grid: TileMap = $TileMap
@onready var terrain: TileMapLayer = $TileMap/Terrain
@onready var buildings: TileMapLayer = $TileMap/Buildings
@onready var fog: TileMapLayer = $TileMap/Fog

signal tile_clicked(cell: Vector2i)

func _ready() -> void:
    assert(grid is TileMap, "TileMap node missing or wrong type")
    assert(terrain is TileMapLayer, "Terrain layer must be TileMapLayer")
    assert(buildings is TileMapLayer, "Buildings layer must be TileMapLayer")
    assert(fog is TileMapLayer, "Fog layer must be TileMapLayer")
    _ensure_singletons()
    if GameState.tiles.is_empty():
        _generate_tiles()
    else:
        _draw_from_saved(GameState.tiles)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var cell := grid.local_to_map(grid.to_local(event.position))
        emit_signal("tile_clicked", cell)

func axial_to_world(qr: Vector2i) -> Vector2:
    return grid.map_to_local(qr)

func reveal_area(center: Vector2i, reveal_radius: int = 2) -> void:
    for cell in _disc(center, reveal_radius):
        fog.erase_cell(cell)
        if GameState.tiles.has(cell):
            var t: Dictionary = GameState.tiles[cell]
            t["explored"] = true
            GameState.tiles[cell] = t

func reveal_all() -> void:
    fog.clear()
    for coord in GameState.tiles.keys():
        var t: Dictionary = GameState.tiles[coord]
        t["explored"] = true
        GameState.tiles[coord] = t

func _draw_from_saved(saved: Dictionary) -> void:
    terrain.clear()
    buildings.clear()
    fog.clear()
    for coord in saved.keys():
        var data: Dictionary = saved[coord]
        _paint_terrain(coord, data.get("terrain", "plain"))
        var b = data.get("building", null)
        if b != null and b != "":
            buildings.set_cell(coord, 0)
        if data.get("explored", false):
            fog.erase_cell(coord)
        else:
            fog.set_cell(coord, 0)

func _paint_terrain(coord: Vector2i, terrain_type: String) -> void:
    var source_id := 0
    match terrain_type:
        "forest":
            source_id = 0
        "taiga":
            source_id = 1
        "hill":
            source_id = 2
        "lake":
            source_id = 3
        _:
            source_id = 0
    terrain.set_cell(coord, source_id)

func _generate_tiles() -> void:
    GameState.tiles.clear()
    for coord in _disc(Vector2i.ZERO, radius):
        var terrain_type := _choose_terrain()
        _paint_terrain(coord, terrain_type)
        GameState.tiles[coord] = {
            "terrain": terrain_type,
            "owner": "none",
            "building": null,
            "explored": false,
        }
        fog.set_cell(coord, 0)

func _choose_terrain() -> String:
    var total := 0.0
    for v in terrain_weights.values():
        total += float(v)
    var roll := randf() * total
    for k in terrain_weights.keys():
        roll -= float(terrain_weights[k])
        if roll <= 0.0:
            return k
    return terrain_weights.keys()[0]

func _disc(center: Vector2i, disc_radius: int) -> Array[Vector2i]:
    var cells: Array[Vector2i] = []
    for q in range(-disc_radius, disc_radius + 1):
        for r in range(max(-disc_radius, -q - disc_radius), min(disc_radius, -q + disc_radius) + 1):
            cells.append(center + Vector2i(q, r))
    return cells

func _ensure_singletons() -> void:
    var root: Node = Engine.get_main_loop().root
    load("res://scripts/core/Resources.gd")
    if not root.has_node("GameState"):
        var gs = load("res://autoload/GameState.gd").new()
        gs.name = "GameState"
        root.add_child(gs)
    if not root.has_node("GameClock"):
        var gc = load("res://autoload/GameClock.gd").new()
        gc.name = "GameClock"
        root.add_child(gc)

