extends CanvasLayer

signal start_pressed
signal pause_pressed

@onready var resources_label: Label = $ResourcesLabel
@onready var tile_info_label: Label = $TileInfoLabel
@onready var start_button: Button = $StartButton
@onready var pause_button: Button = $PauseButton
@onready var clock_label: Label = $ClockLabel


func _ready() -> void:
	start_button.pressed.connect(func(): start_pressed.emit())
	pause_button.pressed.connect(func(): pause_pressed.emit())


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
