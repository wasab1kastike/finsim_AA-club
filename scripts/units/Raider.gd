extends Node2D
class_name Raider

var speed := 50.0
const Resources = preload("res://scripts/core/Resources.gd")

func _process(delta: float) -> void:
    var dir := (Vector2.ZERO - position)
    if dir.length() <= speed * delta:
        GameState.res[Resources.MORALE] = GameState.res.get(Resources.MORALE, 0) - 5
        if GameState.has_method("clamp_resources"):
            GameState.clamp_resources()
        queue_free()
        return
    position += dir.normalized() * speed * delta
