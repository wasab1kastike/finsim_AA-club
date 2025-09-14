extends Node2D
class_name Unit

const HPTheme   = preload("res://units/themes/hp_theme.gd")

@onready var icon: Sprite2D      = $Icon
@onready var ring: ColorRect     = $SelectionRing
@onready var hp_bar: ProgressBar = $HP

signal selected(unit: Unit)
signal deselected(unit: Unit)
signal hp_changed(unit: Unit, hp: int)

var unit_data: UnitData = null
var data: BattleUnitData = BattleUnitData.new()
var id: String = ""
var pos_qr: Vector2i = Vector2i.ZERO
var move: float = 0.0
var atk: int = 0
var def: int = 0
var type: String = ""
var data_path: String = ""
var is_selected: bool = false

var hp: int:
    get: return data.hp
    set(value):
        data.hp = clamp(value, 0, data.max_hp)
        if is_inside_tree():
            hp_bar.value = data.hp
            hp_bar.get_theme_stylebox("fill", "ProgressBar").bg_color = \
                Palette.HP_GREEN if data.hp > data.max_hp / 2 else Palette.HP_RED
        emit_signal("hp_changed", self, data.hp)
        for i in range(GameState.units.size()):
            var u: Dictionary = GameState.units[i]
            if u.get("id", "") == id:
                u["hp"] = data.hp
                GameState.units[i] = u
                break

func _ready():
    if id == "":
        id = UUID.new_uuid_string()
    icon.texture = load(data.icon_path)
    icon.modulate = data.faction_color()
    hp_bar.max_value = data.max_hp
    hp_bar.value = data.hp
    hp_bar.theme = HPTheme.new()

func set_data(d: BattleUnitData) -> void:
    data = d
    move = float(data.move)
    hp = data.hp
    type = data.name
    if is_inside_tree():
        _ready()

func apply_data(d: UnitData) -> void:
    unit_data = d
    type = d.name
    data_path = d.resource_path
    data.name = d.name
    data.max_hp = d.max_health
    hp = d.max_health
    atk = d.attack
    def = d.defense
    move = d.speed
    data.move = int(move)
    if is_inside_tree():
        _ready()

func set_selected(v: bool) -> void:
    is_selected = v
    ring.visible = v
    ring.material.set("shader_parameter/tint", Palette.SEL_RING)
    if v: emit_signal("selected", self)
    else: emit_signal("deselected", self)

func apply_damage(amount: int) -> void:
    hp = data.hp - amount

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
        "atk": atk,
        "def": def,
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
    move = float(d.get("move", move if move != 0.0 else float(data.move)))
    data.move = int(move)
    atk = d.get("atk", atk)
    def = d.get("def", def)
    hp = d.get("hp", data.hp)
    data.faction = d.get("faction", data.faction) as BattleUnitData.Faction
    if is_inside_tree():
        _ready()
