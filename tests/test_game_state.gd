extends Node

func _remove_save(gs) -> void:
    if FileAccess.file_exists(gs.SAVE_PATH):
        DirAccess.remove_absolute(gs.SAVE_PATH)

func test_save_creates_file(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    _remove_save(gs)
    gs.save()
    if not FileAccess.file_exists(gs.SAVE_PATH):
        res.fail("save file missing")

func test_offline_gain(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    _remove_save(gs)

    var data := {
        "res": gs.res,
        "last_timestamp": Time.get_unix_time_from_system() - 5,
    }
    var file := FileAccess.open(gs.SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    file.close()

    gs.res["wood"] = 0.0
    gs.res["food"] = 0.0
    gs.res["steam"] = 0.0
    gs.load()

    var expected_ticks := int(5 / clock.TICK_INTERVAL)
    var expected: float = gs.WOOD_PER_TICK * expected_ticks
    if gs.res["wood"] < expected - 0.001:
        res.fail("offline gains not applied")

func test_unit_stats_persist(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    _remove_save(gs)

    gs.units.clear()
    var uid := "test-unit-id"
    gs.units.append({
        "id": uid,
        "type": "Footman",
        "data_path": "res://resources/units/footman.tres",
        "pos_qr": Vector2i(1, 2),
        "hp": 55,
    })
    gs.save()

    gs.units.clear()
    gs.load()

    if gs.units.size() != 1 or gs.units[0].get("id", "") != uid:
        res.fail("unit not loaded")
        return
    var u_dict = gs.units[0]
    var unit_scene: PackedScene = load("res://scenes/units/Unit.tscn")
    var unit = unit_scene.instantiate()
    unit.from_dict(u_dict)
    if unit.id != uid or unit.hp != 55 or unit.atk != 20 or unit.def != 8 or abs(unit.move - 1.5) > 0.01:
        res.fail("unit stats not preserved")

