extends Node

# The autoload provides the EventManager singleton; avoid registering a global
# class name that conflicts with the autoload itself.

const GameEventBase := preload("res://scripts/events/Event.gd")

# List of event script paths to ensure their classes are registered with the
# ClassDB before any event resources are loaded.
const _EVENT_SCRIPT_PATHS := [
    "res://scripts/events/ColdSnap.gd",
    "res://scripts/events/Trader.gd",
    "res://scripts/events/RuneDiscovery.gd",
]

var events: Array = []
var current_event: GameEventBase = null
var _ticks_until_event: int = 0

const OVERLAY_SCENE := preload("res://scenes/ui/EventOverlay.tscn")

func _ready() -> void:
    for p in _EVENT_SCRIPT_PATHS:
        load(p)
    _load_events()
    GameClock.tick.connect(_on_tick)
    _schedule_next_event()

func _load_events() -> void:
    events.clear()
    for file in DirAccess.get_files_at("res://resources/events"):
        if file.get_extension() == "tres":
            var res_path := "res://resources/events/%s" % file
            var res := load(res_path)
            if res == null:
                push_warning("Failed to load event resource: %s" % res_path)
            elif res is GameEventBase:
                events.append(res)
            else:
                push_warning("Loaded resource is not a GameEventBase: %s" % res_path)

func _schedule_next_event() -> void:
    _ticks_until_event = 30 + int(RNG.randf() * 21)

func _on_tick() -> void:
    if current_event:
        return
    _ticks_until_event -= 1
    if _ticks_until_event <= 0:
        if events.size() > 0:
            var idx := int(RNG.randf() * events.size())
            var ev: GameEventBase = events[idx]
            if ev.can_trigger():
                start_event(ev)

func start_event(ev: GameEventBase) -> void:
    if current_event:
        return
    if not ev.can_trigger():
        return
    current_event = ev
    var applied := true
    if ev.has_method("apply"):
        applied = ev.apply()
    if not applied:
        current_event = null
        GameClock.start()
        _schedule_next_event()
        return
    GameClock.stop()
    var overlay = OVERLAY_SCENE.instantiate()
    overlay.show_event(ev)
    overlay.choice_selected.connect(_on_choice_selected)
    get_tree().root.add_child(overlay)

func _on_choice_selected(choice: Dictionary) -> void:
    var costs: Dictionary = choice.get("costs", {})
    for k in costs.keys():
        if GameState.res.get(k, 0) < costs[k]:
            return
    for k in costs.keys():
        GameState.res[k] = GameState.res.get(k, 0) - costs[k]
    var effects: Dictionary = choice.get("effects", {})
    for k in effects.keys():
        GameState.res[k] = GameState.res.get(k, 0) + effects[k]
    var next_path: String = choice.get("next_event", "")
    current_event = null
    if next_path != "":
        var next_ev: GameEventBase = load(next_path)
        start_event(next_ev)
    else:
        GameClock.start()
        _schedule_next_event()
