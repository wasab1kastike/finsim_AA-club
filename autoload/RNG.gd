extends Node

var _rng := RandomNumberGenerator.new()

func seed_from_string(s: String) -> void:
    _rng.seed = hash(s)

func randf() -> float:
    return _rng.randf()

func randi() -> int:
    return _rng.randi()
