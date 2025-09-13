class_name UnitNode
extends Node2D

const BattleUnitData = preload("res://units/scripts/unit_data.gd")
const UnitData       = preload("res://scripts/units/UnitData.gd")
const HPTheme   = preload("res://units/themes/hp_theme.gd")
const Palette   = preload("res://styles/palette.gd")

@onready var icon: Sprite2D         = $Icon
@onready var ring: ColorRect        = $SelectionRing
@onready var hp_bar: ProgressBar    = $HP

signal selected(unit: UnitNode)
signal deselected(unit: UnitNode)
signal hp_changed(unit: UnitNode, hp: int)

var data: BattleUnitData = BattleUnitData.new()
var id: String = ""
var pos_qr: Vector2i = Vector2i.ZERO
var move: int = 0
var type: String = ""
var data_path: String = ""
var is_selected: bool = false

func _ready():
    # visuals
    if id == "":
        id = UUID.new_uuid_string()
    icon.texture = load(data.icon_path)
    icon.modulate = data.faction_color()
    hp_bar.max_value = data.max_hp
    hp_bar.value = data.hp
    hp_bar.theme = HPTheme.new()
    move = data.move

func set_data(d: BattleUnitData) -> void:
    data = d
    move = data.move
    type = data.name
    if is_inside_tree():
        _ready()

func apply_data(d: UnitData) -> void:
    type = d.name
    data_path = d.resource_path
    data.name = d.name
    data.max_hp = d.max_health
    data.hp = d.max_health
    move = int(d.speed)
    data.move = move
    if is_inside_tree():
        _ready()

func set_selected(v: bool) -> void:
    is_selected = v
    ring.visible = v
    ring.material.set("shader_parameter/tint", Palette.SEL_RING)
    if v: emit_signal("selected", self)
    else: emit_signal("deselected", self)

func apply_damage(amount: int) -> void:
    data.hp = clamp(data.hp - amount, 0, data.max_hp)
    hp_bar.value = data.hp
    hp_bar.get_theme_stylebox("fill", "ProgressBar").bg_color = \
        (data.hp > data.max_hp/2) ? Palette.HP_GREEN : Palette.HP_RED
    emit_signal("hp_changed", self, data.hp)
    for i in range(GameState.units.size()):
        var u: Dictionary = GameState.units[i]
        if u.get("id", "") == id:
            u["hp"] = data.hp
            GameState.units[i] = u
            break

func set_faction(f: BattleUnitData.Faction) -> void:
    data.faction = f
    icon.modulate = data.faction_color()

func _input_event(_viewport, event, _shape_idx):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        set_selected(true)

func to_dict() -> Dictionary:
    return {
        "id": id,
        "type": type,
        "data_path": data_path,
        "pos_qr": pos_qr,
        "hp": data.hp,
        "move": move,
        "faction": int(data.faction),
    }

func from_dict(d: Dictionary) -> void:
    id = d.get("id", id)
    pos_qr = d.get("pos_qr", pos_qr)
    type = d.get("type", type)
    data_path = d.get("data_path", data_path)
    if data_path != "":
        var ud: UnitData = load(data_path)
        if ud:
            apply_data(ud)
    move = d.get("move", move if move != 0 else data.move)
    data.move = move
    data.hp = d.get("hp", data.hp)
    data.faction = BattleUnitData.Faction(d.get("faction", data.faction))
    if is_inside_tree():
        _ready()
