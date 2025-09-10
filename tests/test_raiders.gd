extends Node

var Resources = preload("res://scripts/core/Resources.gd")

func _setup_world():
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    gs.units.clear()
    gs.tiles.clear()
    gs.tiles[Vector2i(0,0)] = {"terrain": "forest", "owner": "player", "building": null, "explored": true}
    gs.tiles[Vector2i(1,0)] = {"terrain": "lake", "owner": "none", "building": null, "explored": true}
    gs.tiles[Vector2i(1,-1)] = {"terrain": "forest", "owner": "none", "building": null, "explored": true}
    gs.tiles[Vector2i(2,0)] = {"terrain": "forest", "owner": "none", "building": null, "explored": true}
    gs.tiles[Vector2i(2,-1)] = {"terrain": "forest", "owner": "none", "building": null, "explored": true}
    gs.set_hostile(Vector2i(2,0), true)
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)
    return world

func test_raider_spawn_and_path(res) -> void:
    var world = _setup_world()
    for i in range(19):
        world._on_game_tick()
    if world.raider_manager.raiders.size() != 0:
        res.fail("raider spawned early")
        world.queue_free()
        return
    world._on_game_tick()
    if world.raider_manager.raiders.size() != 1:
        res.fail("raider did not spawn")
        world.queue_free()
        return
    var raider = world.raider_manager.raiders[0]["node"]
    if raider.pos_qr != Vector2i(2,-1):
        res.fail("raider wrong first step %s" % raider.pos_qr)
        world.queue_free()
        return
    world._on_game_tick()
    if raider.pos_qr != Vector2i(1,-1):
        res.fail("raider did not avoid lake")
        world.queue_free()
        return
    world._on_game_tick()
    if raider.pos_qr != Vector2i(0,0):
        res.fail("raider did not reach center")
    world.queue_free()

func test_target_prefers_nearest_building(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    gs.units.clear()
    gs.tiles.clear()
    gs.tiles[Vector2i(3,-1)] = {"terrain": "forest", "owner": "player", "building": "farm"}
    gs.tiles[Vector2i(0,0)] = {"terrain": "forest", "owner": "player", "building": "sauna"}
    var rm = load("res://scripts/world/RaiderManager.gd").new()
    var target = rm._find_target(Vector2i(6,-3))
    if target != Vector2i(3,-1):
        res.fail("expected (3,-1) got %s" % target)

func test_target_falls_back_to_center(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    gs.units.clear()
    gs.tiles.clear()
    var rm = load("res://scripts/world/RaiderManager.gd").new()
    var target = rm._find_target(Vector2i(6,-3))
    if target != Vector2i.ZERO:
        res.fail("expected (0,0) got %s" % target)

func test_raider_saunatunnelma_hit(res) -> void:
    var world = _setup_world()
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var orig = gs.res.duplicate()
    for i in range(19):
        world._on_game_tick()
    world._on_game_tick()
    world._on_game_tick()
    world._on_game_tick()
    var expected = max(0.0, orig.get(Resources.SAUNATUNNELMA, 0.0) - 1.0)
    if abs(gs.res[Resources.SAUNATUNNELMA] - expected) > 0.01:
        res.fail("Saunatunnelma not reduced on raider success")
    world.queue_free()
    gs.res = orig
    gs.units.clear()
    gs.tiles.clear()
