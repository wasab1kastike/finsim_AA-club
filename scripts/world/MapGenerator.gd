extends Node2D

@export var map_width: int = 10
@export var map_height: int = 10
@export var seed: int = 0
@export var hex_radius: float = 32.0

var noise := FastNoiseLite.new()
@onready var hex_tile_scene: PackedScene = preload("res://scenes/world/HexTile.tscn")
var _state: Node

func _ready() -> void:
    noise.seed = seed
    RNG.seed_from_string(str(seed))
    _state = Engine.get_main_loop().root.get_node("GameState")
    if _state.tiles.is_empty():
        _generate_and_store()
    else:
        _draw_from_saved()

func _generate_and_store() -> void:
    for child in get_children():
        child.queue_free()
    for r in map_height:
        for q in map_width:
            var hex: Node2D = hex_tile_scene.instantiate() as Node2D
            var noise_val: float = noise.get_noise_2d(float(q), float(r))
            var terrain_type := "water"
            if noise_val > 0.4:
                terrain_type = "mountain"
            elif noise_val > 0.0:
                terrain_type = "grass"
            var resource_type := ""
            var roll := RNG.randf()
            if roll < 0.1:
                resource_type = Resources.KULTA
            elif roll < 0.25:
                resource_type = Resources.HALOT
            hex.q = q
            hex.r = r
            hex.terrain = terrain_type
            hex.resource = resource_type
            hex.update_sprite()
            hex.position = HexUtils.axial_to_world(q, r, hex_radius)
            add_child(hex)
            var coord := Vector2i(q, r)
            _state.tiles[coord] = {
                "terrain": terrain_type,
                "resource": resource_type,
            }

func _draw_from_saved() -> void:
    for child in get_children():
        child.queue_free()
    for coord in _state.tiles.keys():
        var data: Dictionary = _state.tiles[coord]
        var hex: Node2D = hex_tile_scene.instantiate() as Node2D
        hex.q = coord.x
        hex.r = coord.y
        hex.terrain = data.get("terrain", "water")
        hex.resource = data.get("resource", "")
        hex.update_sprite()
        hex.position = HexUtils.axial_to_world(coord.x, coord.y, hex_radius)
        add_child(hex)
