extends Node

const Action = preload("res://scripts/core/Action.gd")
const Policy = preload("res://scripts/policies/Policy.gd")
const GameEvent = preload("res://scripts/events/Event.gd")
const Resources = preload("res://scripts/core/Resources.gd")

func test_policy_apply_and_cooldown(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig = gs.res.duplicate()
    gs.res[Resources.KULTA] = 100.0
    gs.res[Resources.SAUNATUNNELMA] = 0.0
    gs.res[Resources.MAKKARA] = 0.0
    var policy: Policy = load("res://resources/policies/tax_relief.tres")
    if not (policy is Action):
        res.fail("Policy does not inherit Action")
        return
    if not policy.apply():
        res.fail("Policy failed to apply")
        gs.res = orig
        return
    if int(gs.res[Resources.KULTA]) != 80 or int(gs.res[Resources.SAUNATUNNELMA]) != 10:
        res.fail("Policy effects not applied")
    if policy.apply():
        res.fail("Cooldown not enforced")
    gs.res = orig

func test_event_inherits_action(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig = gs.res.duplicate()
    gs.res[Resources.KULTA] = 100.0
    gs.res[Resources.SAUNATUNNELMA] = 0.0
    gs.res[Resources.MAKKARA] = 0.0
    var ev: GameEvent = load("res://resources/events/rain.tres")
    if not (ev is Action):
        res.fail("Event does not inherit Action")
        return
    if not ev.can_trigger():
        res.fail("Event cannot trigger")
        gs.res = orig
        return
    if not ev.apply():
        res.fail("Event failed to apply")
        gs.res = orig
        return
    if int(gs.res[Resources.MAKKARA]) != 20:
        res.fail("Event effect not applied")
    gs.res = orig

func test_sauna_diplomacy(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig_res = gs.res.duplicate()
    gs.res[Resources.HALOT] = 50.0
    gs.res[Resources.LOYLY] = 1.0
    gs.res[Resources.LAUDEVALTA] = 0.0
    var ev: GameEvent = load("res://resources/events/sauna_diplomacy.tres")
    if not ev.can_trigger():
        res.fail("Sauna Diplomacy cannot trigger")
        gs.res = orig_res
        return
    if not ev.apply():
        res.fail("Sauna Diplomacy failed to apply")
        gs.res = orig_res
        return
    if int(gs.res[Resources.HALOT]) != 0 or int(gs.res[Resources.LOYLY]) != 0 or int(gs.res[Resources.LAUDEVALTA]) != 10:
        res.fail("Sauna Diplomacy costs or effects not applied")
    gs.res = orig_res

func test_cold_snap(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig_res = gs.res.duplicate()
    var orig_mod = gs.production_modifier
    var orig_ticks = gs.modifier_ticks_remaining
    gs.res[Resources.LOYLY] = 0.0
    gs.production_modifier = 1.0
    gs.modifier_ticks_remaining = 0
    var ev = load("res://resources/events/cold_snap.tres")
    if not ev.apply():
        res.fail("Cold Snap failed to apply without löyly")
        _restore(gs, orig_res, orig_mod, orig_ticks)
        return
    if abs(gs.production_modifier - 0.8) > 0.01 or gs.modifier_ticks_remaining != 30:
        res.fail("Cold Snap penalty not applied")
        _restore(gs, orig_res, orig_mod, orig_ticks)
        return
    gs.res[Resources.LOYLY] = 2.0
    gs.production_modifier = 1.0
    gs.modifier_ticks_remaining = 0
    if not ev.apply():
        res.fail("Cold Snap failed to apply with löyly")
        _restore(gs, orig_res, orig_mod, orig_ticks)
        return
    if gs.res[Resources.LOYLY] != 0.0 or abs(gs.production_modifier - 1.0) > 0.01 or gs.modifier_ticks_remaining != 30:
        res.fail("Cold Snap cost or effect incorrect")
    _restore(gs, orig_res, orig_mod, orig_ticks)

func _restore(gs, res_dict, mod, ticks):
    gs.res = res_dict
    gs.production_modifier = mod
    gs.modifier_ticks_remaining = ticks

