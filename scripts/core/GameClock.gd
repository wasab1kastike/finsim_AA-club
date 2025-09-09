extends Node

signal tick(time: float)

var time: float = 0.0
var running: bool = false

func _process(delta: float) -> void:
    if running:
        time += delta
        tick.emit(time)

func start() -> void:
    running = true

func stop() -> void:
    running = false
