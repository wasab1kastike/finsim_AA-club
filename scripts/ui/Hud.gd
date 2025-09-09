extends CanvasLayer

signal start_pressed
signal pause_pressed

@onready var resources_label: Label = $ResourcesLabel
@onready var tile_info_label: Label = $TileInfoLabel
@onready var start_button: Button = $StartButton
@onready var pause_button: Button = $PauseButton
@onready var clock_label: Label = $ClockLabel
@onready var policy_button: Button = $PolicyButton
@onready var event_button: Button = $EventButton
@onready var event_label: Label = $EventLabel


func _ready() -> void:
	start_button.pressed.connect(func(): start_pressed.emit())
	pause_button.pressed.connect(func(): pause_pressed.emit())
	policy_button.pressed.connect(_on_policy_pressed)
	event_button.pressed.connect(_on_event_pressed)


func update_resources(resources: Dictionary) -> void:
	var parts: PackedStringArray = []
	for key in resources.keys().sorted():
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
