extends SceneTree

class TestResult:
    var failed := false
    var message := ""
    func fail(msg: String) -> void:
        failed = true
        message = msg

var test_scripts := [
    preload("res://tests/test_rng.gd"),
    preload("res://tests/test_game_clock.gd"),
    preload("res://tests/test_building.gd"),
]

func _init() -> void:
    var total := 0
    var failed_count := 0
    for script in test_scripts:
        var obj = script.new()
        for method in obj.get_method_list():
            var name = method.name
            if name.begins_with("test_"):
                total += 1
                var res = TestResult.new()
                obj.call(name, res)
                if res.failed:
                    failed_count += 1
                    print("FAIL: %s.%s - %s" % [script.resource_path, name, res.message])
    if failed_count == 0:
        print("All %d tests passed" % total)
    else:
        print("%d/%d tests failed" % [failed_count, total])
    quit(failed_count)
