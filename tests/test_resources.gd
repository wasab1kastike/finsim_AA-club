extends Node
var Resources = preload("res://scripts/core/Resources.gd")

func test_game_state_resources(res) -> void:
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var keys := gs.res.keys()
    keys.sort()
    var expected := [
        Resources.WOOD,
        Resources.FOOD,
        Resources.ORE,
        Resources.RESEARCH,
        Resources.INFLUENCE,
        Resources.LOYLY,
        Resources.SISU,
        Resources.MORALE,
        Resources.GOLD,
        Resources.PRESTIGE,
    ]
    expected.sort()
    if keys != expected:
        res.fail("resource keys mismatch: %s" % [keys])

func test_starting_gold(res) -> void:
    var gs = Engine.get_main_loop().root.get_node("GameState")
    if gs.res[Resources.GOLD] <= 0.0:
        res.fail("starting gold should be positive")
