extends Node2D

@export var map_width: int = 10
@export var map_height: int = 10
@export var seed: int = 0
@export var hex_radius: float = 32.0

var noise := FastNoiseLite.new()
var rng := RandomNumberGenerator.new()
@onready var hex_tile_scene: PackedScene = preload("res://scenes/world/HexTile.tscn")

func _ready() -> void:
    noise.seed = seed
    rng.seed = seed
    generate_map()

func axial_to_world(q: int, r: int) -> Vector2:
    var x := hex_radius * sqrt(3.0) * (q + r / 2.0)
    var y := hex_radius * 1.5 * r
    return Vector2(x, y)

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
            var roll := rng.randf()
            if roll < 0.1:
                resource_type = "gold"
            elif roll < 0.25:
                resource_type = "wood"
            hex.q = q
            hex.r = r
            hex.terrain = terrain_type
            hex.resource = resource_type
            hex.position = axial_to_world(q, r)
            add_child(hex)
