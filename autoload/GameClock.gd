extends Node

signal tick()

const TICK_INTERVAL := 0.5
var time: float = 0.0
var running: bool = true
var _accumulator: float = 0.0

func _process(delta: float) -> void:
    if not running:
        return
    time += delta
    _accumulator += delta
    while _accumulator >= TICK_INTERVAL:
        _accumulator -= TICK_INTERVAL
        emit_signal("tick")

func start() -> void:
    running = true

func stop() -> void:
    running = false
