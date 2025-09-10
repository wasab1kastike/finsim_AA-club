extends Node2D

@export var map_width: int = 10
@export var map_height: int = 10
@export var seed: int = 0
@export var hex_radius: float = 32.0

const HexUtils = preload("res://scripts/world/HexUtils.gd")
var noise := FastNoiseLite.new()
@onready var hex_tile_scene: PackedScene = preload("res://scenes/world/HexTile.tscn")

func _ready() -> void:
    noise.seed = seed
    RNG.seed_from_string(str(seed))
    generate_map()

func generate_map() -> void:
    for child in get_children():
        child.queue_free()
    for r in map_height:
        for q in map_width:
            var hex: Node2D = hex_tile_scene.instantiate() as Node2D
            var noise_val := noise.get_noise_2d(float(q), float(r))
            var terrain_type := "water"
            if noise_val > 0.4:
                terrain_type = "mountain"
            elif noise_val > 0.0:
                terrain_type = "grass"
            var resource_type := ""
            var roll := RNG.randf()
            if roll < 0.1:
                resource_type = "gold"
            elif roll < 0.25:
                resource_type = "wood"
            hex.q = q
            hex.r = r
            hex.terrain = terrain_type
            hex.resource = resource_type
            hex.position = HexUtils.axial_to_world(q, r, hex_radius)
            add_child(hex)
