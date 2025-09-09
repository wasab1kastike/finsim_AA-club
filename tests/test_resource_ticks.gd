extends RefCounted

var HudStub := preload("res://tests/hud_stub.gd")
var WorldScript := preload("res://scripts/world/World.gd")
var BuildingScript := preload("res://scripts/core/Building.gd")

func run(tree) -> bool:
    var gs = tree.root.get_node("/root/GameState")
    gs.res = {"food": 0.0}
    var building = BuildingScript.new()
    building.production_rates = {"food": 5.0}
    var world = WorldScript.new()
    world.GameState = gs
    world.hud = HudStub.new()
    world.tile_occupants = {Vector2i(0, 0): building}
    world._on_tick(1.0)
    return gs.res.get("food", 0.0) == 5.0
