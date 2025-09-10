extends Node
var Resources = preload("res://scripts/core/Resources.gd")
var GameEvent = preload("res://scripts/events/Event.gd")
var ColdSnapEvent = preload("res://scripts/events/ColdSnap.gd")

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

func test_cold_snap_event(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    # Sufficient loyly: should spend loyly and avoid penalty
    gs.res[Resources.LOYLY] = 3.0
    gs.production_modifier = 0.0
    gs.modifier_ticks_remaining = 0
    var ev: ColdSnapEvent = ColdSnapEvent.new()
    if not ev.apply():
        res.fail("apply returned false with sufficient loyly")
        return
    if gs.res[Resources.LOYLY] != 1.0 or gs.production_modifier != 1.0:
        res.fail("cold snap did not consume loyly or reset modifier")
        return
    if gs.modifier_ticks_remaining != ev.duration_ticks:
        res.fail("duration not applied")
        return
    # Insufficient loyly: should apply penalty
    gs.res[Resources.LOYLY] = 0.0
    gs.production_modifier = 1.0
    gs.modifier_ticks_remaining = 0
    ev = ColdSnapEvent.new()
    if not ev.apply():
        res.fail("apply returned false with insufficient loyly")
        return
    if gs.production_modifier != ev.penalty_multiplier:
        res.fail("penalty modifier not applied")
        return
    if gs.modifier_ticks_remaining != ev.duration_ticks:
        res.fail("duration not set on penalty")
        return
    gs.res[Resources.LOYLY] = 0.0
    gs.production_modifier = 1.0
    gs.modifier_ticks_remaining = 0

func test_event_fails_prerequisites(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var em = tree.root.get_node("EventManager")
    var orig = gs.res.duplicate()
    gs.res[Resources.WOOD] = 0.0
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

func test_apply_returns_false(res) -> void:
    var tree = Engine.get_main_loop()
    var em = tree.root.get_node("EventManager")
    var clock = tree.root.get_node("GameClock")
    clock.start()
    var ev: DummyEvent = DummyEvent.new()
    em.start_event(ev)
    var overlay_present := false
    for child in tree.root.get_children():
        if child.name == "EventOverlay":
            overlay_present = true
    _cleanup_overlays(tree)
    if overlay_present or em.current_event != null:
        res.fail("event started despite apply returning false")
    if not clock.running:
        res.fail("GameClock stopped on failed event")
        