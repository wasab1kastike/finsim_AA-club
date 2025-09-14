extends Node2D
class_name HexMap

const TILE_SIZE := Vector2i(96, 84)


const TERRAIN_SOURCE_IDS: Dictionary[String, int] = {
    "forest": 0,
    "taiga": 1,
    "hill": 2,
    "lake": 3,
    "plain": 0,
}

const BUILDING_SOURCE_IDS: Dictionary[String, int] = {
    "town": 4,
    "ruins": 5,
}
const DEFAULT_BUILDING_SOURCE_ID := 4

@export var radius: int = 0
@export var map_seed: int = 0
@export var terrain_weights: Dictionary[String, float] = {}

@export var line_thickness: float = 2.0:
    set(value):
        line_thickness = value
        _update_grid_outline()

@export var line_alpha: float = 0.5:
    set(value):
        line_alpha = value
        _update_grid_outline()

@onready var terrain_layer: TileMapLayer = $Terrain
@onready var buildings_layer: TileMapLayer = $Buildings
@onready var fog_layer: TileMapLayer = $Fog
var fog_map: FogMap

const CONFIG_SEED_PATH := "finsim/seed"
var _rng := RandomNumberGenerator.new()

signal tile_clicked(cell: Vector2i)

func _ready() -> void:
    _update_grid_outline()
    if radius <= 0:
        push_warning("HexMap radius is 0")
    _ensure_singletons()
    map_seed = int(ProjectSettings.get_setting(CONFIG_SEED_PATH, map_seed))
    _rng.seed = map_seed
    fog_map = FogMap.new(fog_layer)
    if GameState.tiles.is_empty():
        _generate_tiles()
    else:
        _draw_from_saved(GameState.tiles)
    reveal_all()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var cell := terrain_layer.local_to_map(terrain_layer.to_local(event.position))
        emit_signal("tile_clicked", cell)

func axial_to_world(qr: Vector2i) -> Vector2:
    return terrain_layer.map_to_local(qr)

func reveal_area(center: Vector2i, reveal_radius: int = 2) -> void:
    for cell in _disc(center, reveal_radius):
        fog_map.clear_fog(cell)
        if GameState.tiles.has(cell):
            var t: Dictionary = GameState.tiles[cell]
            t["explored"] = true
            GameState.tiles[cell] = t

func reveal_all() -> void:
    fog_layer.clear()
    for coord in GameState.tiles.keys():
        var t: Dictionary = GameState.tiles[coord]
        t["explored"] = true
        GameState.tiles[coord] = t

func _update_grid_outline() -> void:
    if terrain_layer.material is ShaderMaterial:
        terrain_layer.material.set_shader_parameter("line_thickness", line_thickness)
        terrain_layer.material.set_shader_parameter("line_alpha", line_alpha)

func _draw_from_saved(saved: Dictionary) -> void:
    terrain_layer.clear()
    buildings_layer.clear()
    fog_layer.clear()
    for coord in saved.keys():
        var data: Dictionary = saved[coord]
        var terrain_type: String = data.get("terrain", "plain")
        var source_id: int = TERRAIN_SOURCE_IDS.get(terrain_type, 0)
        _paint_cell(terrain_layer, coord, source_id, terrain_type)
        var b: String = data.get("building", "")
        if b != "":
            var building_name: String = b
            var building_source_id: int = BUILDING_SOURCE_IDS.get(building_name, DEFAULT_BUILDING_SOURCE_ID)
            buildings_layer.set_cell(coord, building_source_id)
        if data.get("explored", false):
            fog_map.clear_fog(coord)
        else:
            fog_map.set_fog(coord)

func _paint_cell(layer: TileMapLayer, coord: Vector2i, source_id: int, terrain: String) -> void:
    layer.set_cell(coord, source_id)
    var tile_data := layer.get_cell_tile_data(coord)
    if tile_data:
        var color := Palette.PLAIN
        match terrain:
            "lake":
                color = Palette.WATER
            "hill":
                color = Palette.HILL
            "taiga":
                color = Palette.TAIGA
            "forest":
                color = Palette.FOREST
            _:
                color = Palette.PLAIN
        tile_data.modulate = color

func _generate_tiles() -> void:
    _rng.seed = map_seed
    GameState.tiles.clear()
    for coord in _disc(Vector2i.ZERO, radius):
        var terrain_type := _choose_terrain()
        var source_id: int = TERRAIN_SOURCE_IDS.get(terrain_type, 0)
        _paint_cell(terrain_layer, coord, source_id, terrain_type)
        GameState.tiles[coord] = {
            "terrain": terrain_type,
            "owner": "none",
            "building": "",
            "explored": false,
        }
        fog_map.set_fog(coord)
    GameState.save()

func _choose_terrain() -> String:
    var total := 0.0
    for v in terrain_weights.values():
        total += float(v)
    var roll := _rng.randf() * total
    for k in terrain_weights.keys():
        roll -= float(terrain_weights[k])
        if roll <= 0.0:
            return String(k)
    if terrain_weights.is_empty():
        return "forest"
    return String(terrain_weights.keys()[0])

func _disc(center: Vector2i, disc_radius: int) -> Array[Vector2i]:
    var cells: Array[Vector2i] = []
    for q in range(-disc_radius, disc_radius + 1):
        for r in range(max(-disc_radius, -q - disc_radius), min(disc_radius, -q + disc_radius) + 1):
            cells.append(center + Vector2i(q, r))
    return cells

func _ensure_singletons() -> void:
    var root: Node = Engine.get_main_loop().root
    var resources_res := ResourceLoader.load("res://scripts/core/Resources.gd")
    if resources_res == null:
        push_error("Failed to load Resources.gd")
        return
    if not root.has_node("GameState"):
        var gs_res := ResourceLoader.load("res://autoload/GameState.gd")
        if gs_res == null:
            push_error("Failed to load GameState.gd")
            return
        var gs = gs_res.new()
        gs.name = "GameState"
        root.add_child(gs)
    if not root.has_node("GameClock"):
        var gc_res := ResourceLoader.load("res://autoload/GameClock.gd")
        if gc_res == null:
            push_error("Failed to load GameClock.gd")
            return
        var gc = gc_res.new()
        gc.name = "GameClock"
        root.add_child(gc)

