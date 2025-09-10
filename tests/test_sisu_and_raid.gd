extends Node

var Resources = preload("res://scripts/core/Resources.gd")
var SpendSisuAction = preload("res://resources/actions/spend_sisu.tres")
var Raider = preload("res://scripts/units/Raider.gd")

func _dup(arr):
    var copy = []
    for u in arr:
        copy.append(u.duplicate(true))
    return copy

func test_sisu_cap(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig = gs.res.duplicate()
    gs.res[Resources.SISU] = 9
    gs.res[Resources.SISU] += 5
    gs.clamp_resources()
    if gs.res[Resources.SISU] != 10:
        res.fail("Sisu not capped at 10")
    gs.res = orig

func test_spend_sisu_heals(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig_res = gs.res.duplicate()
    var orig_units = _dup(gs.units)
    gs.res[Resources.SISU] = 5
    gs.units = [{
        "id": "u1",
        "type": "footman",
        "data_path": "res://resources/units/footman.tres",
        "pos_qr": Vector2i.ZERO,
        "hp": 50,
    }]
    var action = SpendSisuAction
    if not action.apply():
        res.fail("Spend Sisu failed to apply")
    elif gs.res[Resources.SISU] != 4:
        res.fail("Sisu not deducted")
    else:
        var ud = load("res://resources/units/footman.tres")
        var expected = min(ud.max_health, 50 + int(ud.max_health * 0.2))
        if gs.units[0]["hp"] != expected:
            res.fail("Unit not healed")
    gs.res = orig_res
    gs.units = orig_units

func test_raider_edge_rule(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig = gs.res.duplicate()
    gs.res[Resources.MORALE] = 100
    var raider = Raider.new()
    raider.position = Vector2(100,0)
    Engine.get_main_loop().root.add_child(raider)
    raider._process(2.0)
    if int(gs.res[Resources.MORALE]) != 95:
        res.fail("Morale not reduced")
    if not raider.is_queued_for_deletion():
        res.fail("Raider did not despawn")
    gs.res = orig
