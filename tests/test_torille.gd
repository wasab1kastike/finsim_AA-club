extends Node

func _remove_save(gs) -> void:
    if FileAccess.file_exists(gs.SAVE_PATH):
        DirAccess.remove_absolute(gs.SAVE_PATH)

func test_torille_recall(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    _remove_save(gs)
    gs.units.clear()
    gs.tiles.clear()
    gs.tiles[Vector2i(0,0)] = {"terrain":"grass", "building":"sauna"}
    gs.tiles[Vector2i(1,0)] = {"terrain":"grass"}
    gs.tiles[Vector2i(2,0)] = {"terrain":"grass"}
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)
    world.spawn_unit_at_center()
    var unit = world.get_node("Units").get_child(0)
    unit.pos_qr = Vector2i(2,0)
    unit.position = world.hex_map.axial_to_world(unit.pos_qr)
    for i in range(GameState.units.size()):
        var data: Dictionary = GameState.units[i]
        if data.get("id", "") == unit.id:
            data["pos_qr"] = unit.pos_qr
            GameState.units[i] = data
            break
    world.torille()
    if unit.pos_qr != Vector2i(0,0):
        res.fail("unit not recalled")
    world.queue_free()
    gs.units.clear()
    gs.tiles.clear()
    _remove_save(gs)
