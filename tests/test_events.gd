extends Node
const Resources = preload("res://scripts/core/Resources.gd")
const GameEvent = preload("res://scripts/events/Event.gd")

class DummyEvent:
    extends GameEvent

    func apply() -> bool:
        return false

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
    gs.res[Resources.HALOT] = 20.0
    gs.res[Resources.MAKKARA] = 0.0
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
    if gs.res[Resources.MAKKARA] < 15 or gs.res[Resources.HALOT] > 10:
        res.fail("event effects not applied")

func test_event_fails_prerequisites(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var em = tree.root.get_node("EventManager")
    var orig = gs.res.duplicate()
    gs.res[Resources.HALOT] = 0.0
    var ev: GameEvent = load("res://resources/events/merchant.tres")
    if ev.can_trigger():
        res.fail("event unexpectedly triggerable")
        gs.res = orig
        return
    em.start_event(ev)
    var overlay_present := false
    for child in tree.root.get_children():
        if child.name == "EventOverlay":
            overlay_present = true
    _cleanup_overlays(tree)
    gs.res = orig
    if em.current_event != null or overlay_present:
        res.fail("event started despite failing prerequisites")

func test_unaffordable_choice_keeps_resources(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var em = tree.root.get_node("EventManager")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    var orig = gs.res.duplicate()
    gs.res[Resources.HALOT] = 0.0
    var ev: GameEvent = load("res://resources/events/merchant.tres")
    em.start_event(ev)
    var before: Dictionary = gs.res.duplicate()
    em._on_choice_selected(ev.choices[0])
    _cleanup_overlays(tree)
    if gs.res != before:
        res.fail("resources changed despite unaffordable choice")
    gs.res = orig
    em.current_event = null
    clock.start()
    clock.set_process(true)

func test_event_apply_returns_false(res) -> void:
    var tree = Engine.get_main_loop()
    var em = tree.root.get_node("EventManager")
    var clock = tree.root.get_node("GameClock")
    clock.set_process(false)
    clock.start()
    var ev: DummyEvent = DummyEvent.new()
    em.start_event(ev)
    var overlay_present := false
    for child in tree.root.get_children():
        if child.name == "EventOverlay":
            overlay_present = true
    _cleanup_overlays(tree)
    if overlay_present:
        res.fail("overlay shown despite apply returning false")
    if em.current_event != null:
        res.fail("current_event not cleared after apply returned false")
    if not clock.running:
        res.fail("GameClock stopped despite apply returning false")
    clock.set_process(true)
        