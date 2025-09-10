extends Node

var Action = preload("res://scripts/core/Action.gd")
var Policy = preload("res://scripts/policies/Policy.gd")
var GameEvent = preload("res://scripts/events/Event.gd")

func test_policy_apply_and_cooldown(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig = gs.res.duplicate()
    gs.res["gold"] = 100.0
    gs.res["morale"] = 0.0
    gs.res["food"] = 0.0
    var policy: Policy = load("res://resources/policies/tax_relief.tres")
    if not (policy is Action):
        res.fail("Policy does not inherit Action")
        return
    if not policy.apply():
        res.fail("Policy failed to apply")
        gs.res = orig
        return
    if int(gs.res["gold"]) != 80 or int(gs.res["morale"]) != 10:
        res.fail("Policy effects not applied")
    if policy.apply():
        res.fail("Cooldown not enforced")
    gs.res = orig

func test_event_inherits_action(res):
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var orig = gs.res.duplicate()
    gs.res["gold"] = 100.0
    gs.res["morale"] = 0.0
    gs.res["food"] = 0.0
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
    if int(gs.res["food"]) != 20:
        res.fail("Event effect not applied")
    gs.res = orig

