extends Node

signal tick

const TICK_INTERVAL := 0.5
var _accumulator := 0.0
var enabled := true

func _ready() -> void:
    var now := Time.get_unix_time_from_system()
    var elapsed := now - GameState.last_timestamp
    if elapsed > TICK_INTERVAL:
        var ticks := int(elapsed / TICK_INTERVAL)
        for i in ticks:
            apply_tick()

func _process(delta: float) -> void:
    if not enabled:
        return
    _accumulator += delta
    while _accumulator >= TICK_INTERVAL:
        _accumulator -= TICK_INTERVAL
        apply_tick()

func apply_tick() -> void:
    emit_signal("tick")
    GameState.last_timestamp = Time.get_unix_time_from_system()
    GameState.save()
