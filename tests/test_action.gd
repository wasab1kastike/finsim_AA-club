extends Node

const ActionScript = preload("res://scripts/core/Action.gd")
var Resources = preload("res://scripts/core/Resources.gd")

func test_policy_apply_and_cooldown(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig = gs.res.duplicate()
    gs.res[Resources.GOLD] = 100.0
    gs.res[Resources.MORALE] = 0.0
    gs.res[Resources.FOOD] = 0.0
    var policy = load("res://resources/policies/tax_relief.tres")
    if not (policy is ActionScript):
        res.fail("Policy does not inherit Action")
        return
    if not policy.apply():
        res.fail("Policy failed to apply")
        gs.res = orig
        return
    if int(gs.res[Resources.GOLD]) != 80 or int(gs.res[Resources.MORALE]) != 10:
        res.fail("Policy effects not applied")
    if policy.apply():
        res.fail("Cooldown not enforced")
    gs.res = orig

func test_event_inherits_action(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig = gs.res.duplicate()
    gs.res[Resources.GOLD] = 100.0
    gs.res[Resources.MORALE] = 0.0
    gs.res[Resources.FOOD] = 0.0
    var ev = load("res://resources/events/rain.tres")
    if not (ev is ActionScript):
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
    if int(gs.res[Resources.FOOD]) != 20:
        res.fail("Event effect not applied")
    gs.res = orig

