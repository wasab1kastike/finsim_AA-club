extends CanvasLayer

const PolicyBase := preload("res://scripts/policies/Policy.gd")
const GameEventBase = preload("res://scripts/events/Event.gd")

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
@onready var info_box: InfoBox = $InfoBox

var _policies: Array[Policy] = []
var _events: Array[GameEventBase] = []
var _buildings_info: Array[Building] = []

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
    var popup := building_selector.get_popup()
    popup.id_focused.connect(_on_building_hovered)
    popup.mouse_exited.connect(func(): info_box.hide())
    popup.popup_hide.connect(func(): info_box.hide())
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
    var total_seconds := int(time)
    var minutes := int(total_seconds / 60)
    var seconds := total_seconds % 60
    clock_label.text = "Time: %02d:%02d" % [minutes, seconds]

func _on_policy_pressed() -> void:
    var idx := policy_selector.get_selected()
    if idx >= 0 and idx < _policies.size():
        var policy: Policy = _policies[idx]
        if policy.apply():
            update_resources(GameState.res)

func _on_event_pressed() -> void:
    var idx := event_selector.get_selected()
    if idx >= 0 and idx < _events.size():
        var ev: GameEventBase = _events[idx]
        if ev.can_trigger():
            EventManager.start_event(ev)
            event_label.text = "%s triggered" % ev.name
        else:
            event_label.text = "%s cannot trigger" % ev.name

func _on_building_selected(index: int) -> void:
    building_selected.emit(building_selector.get_item_text(index))
    info_box.hide()

func _on_building_hovered(id: int) -> void:
    if id >= 0 and id < _buildings_info.size():
        info_box.show_building(_buildings_info[id])

func show_building_info(building: Building) -> void:
    if building:
        info_box.show_building(building)
    else:
        info_box.hide()

func _populate_buildings() -> void:
    _buildings_info.clear()
    building_selector.clear()
    for file in DirAccess.get_files_at("res://resources/buildings"):
        if file.get_extension() == "tres":
            var b_res := load("res://resources/buildings/%s" % file)
            if b_res == null:
                push_warning("Failed to load building resource: res://resources/buildings/%s" % file)
            elif b_res is Building and b_res.name:
                building_selector.add_item(b_res.name)
                _buildings_info.append(b_res)
            else:
                push_warning("Loaded resource is not a Building: res://resources/buildings/%s" % file)

func _populate_policies() -> void:
    _policies.clear()
    policy_selector.clear()
    for file in DirAccess.get_files_at("res://resources/policies"):
        if file.get_extension() == "tres":
            var res := load("res://resources/policies/%s" % file)
            if res == null:
                push_warning("Failed to load policy resource: res://resources/policies/%s" % file)
            elif res is PolicyBase and res.name:
                policy_selector.add_item(res.name)
                _policies.append(res)
            else:
                push_warning("Loaded resource is not a Policy: res://resources/policies/%s" % file)

func _populate_events() -> void:
    _events.clear()
    event_selector.clear()
    for file in DirAccess.get_files_at("res://resources/events"):
        if file.get_extension() == "tres":
            var res := load("res://resources/events/%s" % file)
            if res == null:
                push_warning("Failed to load event resource: res://resources/events/%s" % file)
            elif res is GameEventBase and res.name:
                event_selector.add_item(res.name)
                _events.append(res)
            else:
                push_warning("Loaded resource is not a GameEventBase: res://resources/events/%s" % file)
