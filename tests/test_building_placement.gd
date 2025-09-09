extends RefCounted

var HudStub := preload("res://tests/hud_stub.gd")
var WorldScript := preload("res://scripts/world/World.gd")
var FarmRes := preload("res://resources/buildings/farm.tres")

func run(tree) -> bool:
    var gs = tree.root.get_node("/root/GameState")
    gs.res = {"gold": 100.0, "wood": 100.0}
    var world = WorldScript.new()
    world.GameState = gs
    world.hud = HudStub.new()
    var tile := Vector2i(1, 1)
    world.tile_occupants[tile] = FarmRes
    var before = world.tile_occupants.size()
    world.construct_building(FarmRes, tile)
    var after = world.tile_occupants.size()
    return before == 1 and after == 1
