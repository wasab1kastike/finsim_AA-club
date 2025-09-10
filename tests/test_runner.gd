extends SceneTree

class TestResult:
    var failed := false
    var message := ""
    func fail(msg: String) -> void:
        failed = true
        message = msg

var test_script_paths := [
    "res://tests/test_rng.gd",
    "res://tests/test_game_clock.gd",
    "res://tests/test_building.gd",
    "res://tests/test_game_state.gd",
    "res://tests/test_hexmap.gd",
    "res://tests/test_map_to_pos.gd",
    "res://tests/test_pathing.gd",
    "res://tests/test_bfs_performance.gd",
    "res://tests/test_raider_spawn_performance.gd",
    "res://tests/test_action.gd",
    "res://tests/test_resources.gd",
    "res://tests/test_prestige.gd",
    "res://tests/test_events.gd",
    "res://tests/test_world.gd",
    "res://tests/test_battle.gd",
    "res://tests/test_raiders.gd",
    "res://tests/test_sisu.gd",
]

func _init() -> void:
    call_deferred("_run_tests")

func _run_tests() -> void:
    var total := 0
    var failed_count := 0
    for path in test_script_paths:
        var script = load(path)
        var obj = script.new()
        for method in obj.get_method_list():
            var name = method.name
            if name.begins_with("test_"):
                total += 1
                var res = TestResult.new()
                obj.call(name, res)
                if res.failed:
                    failed_count += 1
                    print("FAIL: %s.%s - %s" % [path, name, res.message])
    if failed_count == 0:
        print("All %d tests passed" % total)
    else:
        print("%d/%d tests failed" % [failed_count, total])
    quit(failed_count)
