extends Node


func _remove_save(gs) -> void:
    if FileAccess.file_exists(gs.SAVE_PATH):
        DirAccess.remove_absolute(gs.SAVE_PATH)

func test_battle_player_win(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    _remove_save(gs)
    var orig = gs.res.duplicate()
    gs.units.clear()
    gs.tiles.clear()
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)
    world.spawn_unit_at_center()
    var target := Vector2i(1, 0)
    var tdata = gs.tiles.get(target, {})
    tdata["terrain"] = "hill"
    tdata["owner"] = "enemy"
    tdata["hostiles"] = [{"hp":50,"atk":5,"def":1}]
    gs.tiles[target] = tdata
    world._on_tile_clicked(target)
    tdata = gs.tiles[target]
    if tdata.get("owner", "") != "player":
        res.fail("Tile not captured")
    if abs(gs.res[Resources.LAUDEVALTA] - (orig.get(Resources.LAUDEVALTA, 0.0) + 0.5)) > 0.01:
        res.fail("Laudevalta not granted")
    world.queue_free()
    gs.res = orig
    gs.units.clear()
    gs.tiles.clear()
    _remove_save(gs)

func test_battle_player_loss(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    _remove_save(gs)
    var orig = gs.res.duplicate()
    gs.units.clear()
    gs.tiles.clear()
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)
    world.spawn_unit_at_center()
    var target := Vector2i(1, 0)
    var tdata = gs.tiles.get(target, {})
    tdata["terrain"] = "forest"
    tdata["owner"] = "enemy"
    tdata["hostiles"] = [{"hp":200,"atk":20,"def":5}]
    gs.tiles[target] = tdata
    world._on_tile_clicked(target)
    tdata = gs.tiles[target]
    if tdata.get("owner", "") == "player":
        res.fail("Tile should remain enemy")
    var expected_saunatunnelma = orig.get(Resources.SAUNATUNNELMA, 0.0) - 1.0
    if abs(gs.res[Resources.SAUNATUNNELMA] - expected_saunatunnelma) > 0.01:
        res.fail("Saunatunnelma not reduced")
    var expected_sisu = orig.get(Resources.SISU, 0.0) + 1.0
    if abs(gs.res[Resources.SISU] - expected_sisu) > 0.01:
        res.fail("Sisu not increased")
    world.queue_free()
    gs.res = orig
    gs.units.clear()
    gs.tiles.clear()
    _remove_save(gs)
