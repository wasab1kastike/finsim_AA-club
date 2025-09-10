extends Node
var Resources = preload("res://scripts/core/Resources.gd")

func test_prestige_resets(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    gs.res[Resources.WOOD] = 100.0
    gs.res[Resources.PRESTIGE] = 0.0
    gs.prestige()
    if gs.res[Resources.WOOD] != 0.0 or gs.res[Resources.PRESTIGE] != 1.0:
        res.fail("prestige did not reset or increment")

func test_prestige_bonus(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    gs.res[Resources.WOOD] = 0.0
    gs.res[Resources.PRESTIGE] = 2.0
    gs._on_tick()
    var expected := gs.WOOD_PER_TICK * (1.0 + 0.2)
    if abs(gs.res[Resources.WOOD] - expected) > 0.001:
        res.fail("prestige bonus not applied")
