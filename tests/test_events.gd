extends Node
var Resources = preload("res://scripts/core/Resources.gd")
var GameEvent = preload("res://scripts/events/Event.gd")

func _cleanup_overlays(tree):
    for child in tree.root.get_children():
        if child.name == "EventOverlay":
            child.queue_free()

func test_branching_event(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var em = tree.root.get_node("EventManager")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    gs.res[Resources.WOOD] = 20.0
    gs.res[Resources.FOOD] = 0.0
    var ev: GameEvent = load("res://resources/events/merchant.tres")
    em.start_event(ev)
    em._on_choice_selected(ev.choices[0])
    _cleanup_overlays(tree)
    var follow_up: GameEvent = em.current_event
    if follow_up == null or follow_up.name != "Merchant Returns":
        res.fail("follow-up event not started")
        return
    em._on_choice_selected(follow_up.choices[0])
    _cleanup_overlays(tree)
    if em.current_event != null:
        res.fail("event chain did not resolve")
    if gs.res[Resources.FOOD] < 15 or gs.res[Resources.WOOD] > 10:
        res.fail("event effects not applied")
