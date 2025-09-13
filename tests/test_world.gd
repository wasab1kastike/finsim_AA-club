extends Node

func _remove_save(gs) -> void:
    if FileAccess.file_exists(gs.SAVE_PATH):
        DirAccess.remove_absolute(gs.SAVE_PATH)

func test_spawn_and_reveal(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    _remove_save(gs)
    gs.units.clear()
    gs.tiles.clear()
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)
    world.spawn_unit_at_center()
    if GameState.units.size() != 1:
        res.fail("unit not spawned")
        world.queue_free()
        return
    var u_dict: Dictionary = GameState.units[0]
    if u_dict.get("pos_qr", Vector2i.ONE) != Vector2i.ZERO:
        res.fail("unit not at center")
        world.queue_free()
        return
    for data in GameState.tiles.values():
        if not data.get("explored", false):
            res.fail("tile not revealed")
            break
    world.queue_free()
    gs.units.clear()
    gs.tiles.clear()
    _remove_save(gs)
