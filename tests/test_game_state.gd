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
    gs.units.append({
        "type": "conscript",
        "pos_qr": Vector2i(1, 2),
        "hp": 55,
        "atk": 6,
        "def": 3,
        "move": 4,
    })
    gs.save()

    gs.units.clear()
    gs.load()

    if gs.units.size() != 1:
        res.fail("unit not loaded")
        return
    var u = gs.units[0]
    if u.get("hp", 0) != 55 or u.get("atk", 0) != 6 or u.get("def", 0) != 3 or u.get("move", 0) != 4:
        res.fail("unit stats not preserved")

