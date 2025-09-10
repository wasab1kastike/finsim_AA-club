extends CanvasLayer

signal start_pressed
signal pause_pressed
signal build_pressed
signal building_selected

@onready var resources_label: Label = $ResourcesLabel
@onready var tile_info_label: Label = $TileInfoLabel
@onready var start_button: Button = $StartButton
@onready var pause_button: Button = $PauseButton
@onready var clock_label: Label = $ClockLabel
@onready var policy_button: Button = $PolicyButton
@onready var event_button: Button = $EventButton
@onready var event_label: Label = $EventLabel
@onready var build_button: Button = $BuildButton
@onready var building_selector: OptionButton = $BuildingSelector

const Building = preload("res://scripts/core/Building.gd")
const Policy = preload("res://scripts/policies/Policy.gd")
const GameEvent = preload("res://scripts/events/Event.gd")

func _ready() -> void:
    start_button.pressed.connect(func(): start_pressed.emit())
    pause_button.pressed.connect(func(): pause_pressed.emit())
    policy_button.pressed.connect(_on_policy_pressed)
    event_button.pressed.connect(_on_event_pressed)
    build_button.pressed.connect(func(): build_pressed.emit())
    for name in ["Farm", "Mine", "Barracks"]:
        building_selector.add_item(name)
    building_selector.item_selected.connect(_on_building_selected)
    building_selector.select(0)
    building_selected.emit(building_selector.get_item_text(0))

func update_resources(resources: Dictionary) -> void:
    var keys := resources.keys()
    keys.sort()
    var parts: PackedStringArray = []
    for key in keys:
        parts.append("%s: %d" % [key.capitalize(), int(resources[key])])
    resources_label.text = " ".join(parts)

func update_tile(tile_pos: Vector2i, building: Building) -> void:
    var text := "Tile: (%d,%d)" % [tile_pos.x, tile_pos.y]
    if building:
        text += " - %s" % building.name
    else:
        text += " - Empty"
    tile_info_label.text = text

func update_clock(time: float) -> void:
    clock_label.text = "Time: %.2f" % time

func _on_policy_pressed() -> void:
    var policy: Policy = load("res://resources/policies/tax_relief.tres")
    if policy.apply():
        update_resources(GameState.res)

func _on_event_pressed() -> void:
    var ev: GameEvent = load("res://resources/events/rain.tres")
    if ev.apply():
        update_resources(GameState.res)
        event_label.text = "%s occurred!" % ev.name
    else:
        event_label.text = "%s on cooldown" % ev.name

func _on_building_selected(index: int) -> void:
    building_selected.emit(building_selector.get_item_text(index))
