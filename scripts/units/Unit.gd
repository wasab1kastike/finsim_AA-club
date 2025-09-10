extends Node2D

@export var type := "conscript"
@export var hp := 100
@export var atk := 10
@export var def := 1
@export var move := 1
var pos_qr := Vector2i.ZERO

func to_dict() -> Dictionary:
    return {
        "type": type,
        "pos_qr": pos_qr,
        "hp": hp,
        "atk": atk,
        "def": def,
        "move": move,
    }

func from_dict(data: Dictionary) -> void:
    type = data.get("type", type)
    pos_qr = data.get("pos_qr", pos_qr)
    hp = data.get("hp", hp)
    atk = data.get("atk", atk)
    def = data.get("def", def)
    move = data.get("move", move)
