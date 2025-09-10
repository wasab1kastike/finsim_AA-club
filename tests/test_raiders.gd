extends Node

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
