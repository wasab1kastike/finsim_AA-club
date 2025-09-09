extends Node

func _remove_save() -> void:
    if FileAccess.file_exists(GameState.SAVE_PATH):
        DirAccess.remove_absolute(GameState.SAVE_PATH)

func test_save_creates_file(res) -> void:
    GameClock.enabled = false
    _remove_save()
    GameState.save()
    if not FileAccess.file_exists(GameState.SAVE_PATH):
        res.fail("save file missing")

func test_offline_gain(res) -> void:
    GameClock.enabled = false
    _remove_save()

    var data := {
        "res": GameState.res,
        "last_timestamp": Time.get_unix_time_from_system() - 5,
    }
    var file := FileAccess.open(GameState.SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    file.close()

    GameState.res["wood"] = 0.0
    GameState.res["food"] = 0.0
    GameState.res["steam"] = 0.0
    GameState.load()

    var expected_ticks := int(5 / GameClock.TICK_INTERVAL)
    var expected := GameState.WOOD_PER_TICK * expected_ticks
    if GameState.res["wood"] < expected - 0.001:
        res.fail("offline gains not applied")

