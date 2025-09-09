extends RefCounted

var MapGeneratorScript := preload("res://scripts/world/MapGenerator.gd")
var HexStub := preload("res://tests/hex_tile_stub.gd")

func run(_tree) -> bool:
    var mg = MapGeneratorScript.new()
    mg.map_width = 2
    mg.map_height = 2
    mg.seed = 1
    mg.noise.seed = mg.seed
    mg.rng.seed = mg.seed
    var stub = HexStub.new()
    var packed = PackedScene.new()
    packed.pack(stub)
    mg.hex_tile_scene = packed
    mg.generate_map()
    if mg.get_child_count() != 4:
        return false
    for child in mg.get_children():
        if child.terrain == "":
            return false
    return true
