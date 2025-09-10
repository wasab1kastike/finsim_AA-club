extends Node2D

const UnitData = preload("res://scripts/units/UnitData.gd")

@export var unit_data: UnitData
var id: String = "%s_%s" % [str(Time.get_unix_time_from_system()), str(randi())]
var type := "conscript"
var hp := 100
var atk := 10
var def := 1
var move := 1.0
var pos_qr := Vector2i.ZERO

func _ready() -> void:
    if unit_data:
        apply_data(unit_data)

func apply_data(d: UnitData) -> void:
    unit_data = d
    if unit_data:
        type = unit_data.name
        hp = unit_data.max_health
        atk = unit_data.attack
        def = unit_data.defense
        move = unit_data.speed

func to_dict() -> Dictionary:
    return {
        "id": id,
        "type": type,
        "data_path": unit_data.resource_path if unit_data else "",
        "pos_qr": pos_qr,
        "hp": hp,
    }

func from_dict(data: Dictionary) -> void:
    id = data.get("id", id)
    pos_qr = data.get("pos_qr", pos_qr)
    var path: String = data.get("data_path", "")
    if path != "":
        var ud: UnitData = load(path) as UnitData
        if ud:
            apply_data(ud)
    hp = data.get("hp", hp)
    if unit_data == null:
        type = data.get("type", type)
        atk = data.get("atk", atk)
        def = data.get("def", def)
        move = data.get("move", move)
