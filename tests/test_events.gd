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

func test_event_not_triggered_when_requirements_fail(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var em = tree.root.get_node("EventManager")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    gs.res[Resources.WOOD] = 0.0
    var ev: GameEvent = load("res://resources/events/merchant.tres")
    em.events = [ev]
    em.current_event = null
    em._ticks_until_event = 0
    em._on_tick()
    _cleanup_overlays(tree)
    if em.current_event != null:
        res.fail("event triggered despite failing requirements")

func test_hud_respects_can_trigger(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var em = tree.root.get_node("EventManager")
    gs.res[Resources.WOOD] = 0.0
    var ev: GameEvent = load("res://resources/events/merchant.tres")
    var hud_scene = load("res://scenes/ui/Hud.tscn")
    var hud = hud_scene.instantiate()
    tree.root.add_child(hud)
    hud._events = [ev]
    hud.event_selector.clear()
    hud.event_selector.add_item(ev.name)
    hud.event_selector.select(0)
    em.current_event = null
    hud._on_event_pressed()
    _cleanup_overlays(tree)
    if em.current_event != null:
        res.fail("hud triggered event despite failing requirements")
    if hud.event_label.text != "%s cannot trigger" % ev.name:
        res.fail("hud did not report failure")
    hud.queue_free()
