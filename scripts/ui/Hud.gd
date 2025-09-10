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
@onready var policy_selector: OptionButton = $PolicySelector
@onready var event_selector: OptionButton = $EventSelector

var _policies: Array[Policy] = []
var _events: Array[GameEvent] = []

const Building = preload("res://scripts/core/Building.gd")
const Policy = preload("res://scripts/policies/Policy.gd")
const GameEvent = preload("res://scripts/events/Event.gd")

func _ready() -> void:
    start_button.pressed.connect(func(): start_pressed.emit())
    pause_button.pressed.connect(func(): pause_pressed.emit())
    policy_button.pressed.connect(_on_policy_pressed)
    event_button.pressed.connect(_on_event_pressed)
    build_button.pressed.connect(func(): build_pressed.emit())
    _populate_buildings()
    _populate_policies()
    _populate_events()
    building_selector.item_selected.connect(_on_building_selected)
    if building_selector.item_count > 0:
        building_selector.select(0)
        building_selected.emit(building_selector.get_item_text(0))
    if policy_selector.item_count > 0:
        policy_selector.select(0)
    if event_selector.item_count > 0:
        event_selector.select(0)

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
    var idx := policy_selector.get_selected()
    if idx >= 0 and idx < _policies.size():
        var policy: Policy = _policies[idx]
        if policy.apply():
            update_resources(GameState.res)

func _on_event_pressed() -> void:
    var idx := event_selector.get_selected()
    if idx >= 0 and idx < _events.size():
        var ev: GameEvent = _events[idx]
        if ev.apply():
            update_resources(GameState.res)
            event_label.text = "%s occurred!" % ev.name
        else:
            event_label.text = "%s on cooldown" % ev.name

func _on_building_selected(index: int) -> void:
    building_selected.emit(building_selector.get_item_text(index))

func _populate_buildings() -> void:
    for file in DirAccess.get_files_at("res://resources/buildings"):
        if file.get_extension() == "tres":
            var b: Building = load("res://resources/buildings/%s" % file)
            building_selector.add_item(b.name)

func _populate_policies() -> void:
    _policies.clear()
    policy_selector.clear()
    for file in DirAccess.get_files_at("res://resources/policies"):
        if file.get_extension() == "tres":
            var p: Policy = load("res://resources/policies/%s" % file)
            policy_selector.add_item(p.name)
            _policies.append(p)

func _populate_events() -> void:
    _events.clear()
    event_selector.clear()
    for file in DirAccess.get_files_at("res://resources/events"):
        if file.get_extension() == "tres":
            var e: GameEvent = load("res://resources/events/%s" % file)
            event_selector.add_item(e.name)
            _events.append(e)
