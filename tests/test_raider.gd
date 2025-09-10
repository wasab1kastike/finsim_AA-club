extends Node

func _remove_save(gs) -> void:
    if FileAccess.file_exists(gs.SAVE_PATH):
        DirAccess.remove_absolute(gs.SAVE_PATH)

func test_raider_spawn_and_path(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    _remove_save(gs)
    gs.units.clear()
    gs.camps = []
    gs.tiles.clear()
    gs.camps.append(Vector2i(2,0))
    gs.tiles[Vector2i(0,0)] = {"terrain": "forest", "owner": "none", "building": null, "explored": false}
    gs.tiles[Vector2i(1,0)] = {"terrain": "forest", "owner": "none", "building": null, "explored": false}
    gs.tiles[Vector2i(2,0)] = {"terrain": "forest", "owner": "none", "building": null, "explored": false}
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)

    for i in range(20):
        GameClock.emit_signal("tick")

    if GameState.units.size() != 1:
        res.fail("raider not spawned")
        world.queue_free()
        gs.units.clear()
        gs.camps.clear()
        gs.tiles.clear()
        _remove_save(gs)
        return
    var u_dict: Dictionary = GameState.units[0]
    if u_dict.get("pos_qr", Vector2i.ZERO) != Vector2i(1,0):
        res.fail("raider did not move toward center")
        world.queue_free()
        gs.units.clear()
        gs.camps.clear()
        gs.tiles.clear()
        _remove_save(gs)
        return
    GameClock.emit_signal("tick")
    u_dict = GameState.units[0]
    if u_dict.get("pos_qr", Vector2i.ONE) != Vector2i.ZERO:
        res.fail("raider did not reach center")
    world.queue_free()
    gs.units.clear()
    gs.camps.clear()
    gs.tiles.clear()
    _remove_save(gs)
