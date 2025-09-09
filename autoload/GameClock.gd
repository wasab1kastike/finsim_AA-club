extends Node

signal tick()

const TICK_INTERVAL := 0.5
var _accumulator := 0.0

func _process(delta: float) -> void:
    _accumulator += delta
    while _accumulator >= TICK_INTERVAL:
        _accumulator -= TICK_INTERVAL
        emit_signal("tick")
        print("tick")
