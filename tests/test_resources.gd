extends Node

func test_game_state_resources(res) -> void:
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var keys := gs.res.keys()
    keys.sort()
    var expected := [
        Resources.HALOT,
        Resources.MAKKARA,
        Resources.KIUASKIVET,
        Resources.SAUNATIETO,
        Resources.LAUDEVALTA,
        Resources.LOYLY,
        Resources.SISU,
        Resources.SAUNATUNNELMA,
        Resources.KULTA,
        Resources.SAUNAKUNNIA,
    ]
    expected.sort()
    if keys != expected:
        res.fail("resource keys mismatch: %s" % [keys])

func test_starting_kulta(res) -> void:
    var gs = Engine.get_main_loop().root.get_node("GameState")
    if gs.res[Resources.KULTA] <= 0.0:
        res.fail("starting kulta should be positive")
