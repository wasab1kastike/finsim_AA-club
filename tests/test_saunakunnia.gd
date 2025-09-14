extends Node
var Resources = preload("res://scripts/core/Resources.gd")

func test_saunakunnia_resets(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    gs.res[Resources.HALOT] = 100.0
    gs.res[Resources.SAUNAKUNNIA] = 0.0
    gs.gain_saunakunnia()
    if gs.res[Resources.HALOT] != 0.0 or gs.res[Resources.SAUNAKUNNIA] != 1.0:
        res.fail("saunakunnia did not reset or increment")

func test_saunakunnia_bonus(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    gs.res[Resources.HALOT] = 0.0
    gs.res[Resources.SAUNAKUNNIA] = 2.0
    gs._on_tick()
    var expected: float = gs.HALOT_PER_TICK * (1.0 + 0.2)
    if abs(gs.res[Resources.HALOT] - expected) > 0.001:
        res.fail("saunakunnia bonus not applied")
