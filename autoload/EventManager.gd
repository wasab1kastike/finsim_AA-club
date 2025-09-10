extends Node

# The autoload provides the EventManager singleton; avoid registering a global
# class name that conflicts with the autoload itself.

var events: Array = []
var current_event: GameEvent = null
var _ticks_until_event: int = 0

const GameEvent = preload("res://scripts/events/Event.gd")
const OVERLAY_SCENE := preload("res://scenes/ui/EventOverlay.tscn")

func _ready() -> void:
    _load_events()
    GameClock.tick.connect(_on_tick)
    _schedule_next_event()

func _load_events() -> void:
    events.clear()
    for file in DirAccess.get_files_at("res://resources/events"):
        if file.get_extension() == "tres":
            var res := load("res://resources/events/%s" % file)
            if res is GameEvent:
                events.append(res)

func _schedule_next_event() -> void:
    _ticks_until_event = 30 + int(RNG.randf() * 21)

func _on_tick() -> void:
    if current_event:
        return
    _ticks_until_event -= 1
    if _ticks_until_event <= 0:
        if events.size() > 0:
            var idx := int(RNG.randf() * events.size())
            start_event(events[idx])

func start_event(ev: GameEvent) -> void:
    if current_event:
        return
    current_event = ev
    if ev.has_method("apply"):
        ev.apply()
    GameClock.stop()
    var overlay = OVERLAY_SCENE.instantiate()
    overlay.show_event(ev)
    overlay.choice_selected.connect(_on_choice_selected)
    get_tree().root.add_child(overlay)

func _on_choice_selected(choice: Dictionary) -> void:
    var costs: Dictionary = choice.get("costs", {})
    for k in costs.keys():
        if GameState.res.get(k, 0) < costs[k]:
            push_warning("Insufficient %s" % k)
            return
    for k in costs.keys():
        GameState.res[k] = GameState.res.get(k, 0) - costs[k]
    var effects: Dictionary = choice.get("effects", {})
    for k in effects.keys():
        GameState.res[k] = GameState.res.get(k, 0) + effects[k]
    var next_path: String = choice.get("next_event", "")
    current_event = null
    if next_path != "":
        var next_ev: GameEvent = load(next_path)
        start_event(next_ev)
    else:
        GameClock.start()
        _schedule_next_event()
