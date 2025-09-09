extends SceneTree

const TESTS = [
    preload("res://tests/test_resource_ticks.gd"),
    preload("res://tests/test_building_placement.gd"),
    preload("res://tests/test_map_generation.gd"),
]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var failures := 0
    for script in TESTS:
        var test = script.new()
        var ok = test.run(self)
        if ok:
            print("[PASS] ", script)
        else:
            print("[FAIL] ", script)
            failures += 1
    quit(failures)
