class_name UnitNode
extends Node2D

const UnitData  = preload("res://units/scripts/unit_data.gd")
const HPTheme   = preload("res://units/themes/hp_theme.gd")
const Palette   = preload("res://styles/palette.gd")

@onready var icon: Sprite2D         = $Icon
@onready var ring: ColorRect        = $SelectionRing
@onready var hp_bar: ProgressBar    = $HP

signal selected(unit: UnitNode)
signal deselected(unit: UnitNode)
signal hp_changed(unit: UnitNode, hp: int)

var data: UnitData = UnitData.new()
var is_selected: bool = false

func _ready():
    # visuals
    icon.texture = load(data.icon_path)
    icon.modulate = data.faction_color()
    hp_bar.max_value = data.max_hp
    hp_bar.value = data.hp
    hp_bar.theme = HPTheme.new()

func set_data(d: UnitData) -> void:
    data = d
    if is_inside_tree(): _ready()

func set_selected(v: bool) -> void:
    is_selected = v
    ring.visible = v
    ring.material.set("shader_parameter/tint", Palette.SEL_RING)
    if v: emit_signal("selected", self)
    else: emit_signal("deselected", self)

func apply_damage(amount: int) -> void:
    data.hp = clampi(data.hp - amount, 0, data.max_hp)
    hp_bar.value = data.hp
    hp_bar.get_theme_stylebox("fill", "ProgressBar").bg_color = \
        (data.hp > data.max_hp/2) ? Palette.HP_GREEN : Palette.HP_RED
    emit_signal("hp_changed", self, data.hp)

func set_faction(f: int) -> void:
    data.faction = f
    icon.modulate = data.faction_color()

func _input_event(_viewport, event, _shape_idx):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        set_selected(true)
