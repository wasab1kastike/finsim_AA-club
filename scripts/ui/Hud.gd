extends CanvasLayer

signal start_pressed
signal pause_pressed
signal building_selected
signal spawn_unit_pressed

@onready var resources_label: Label = $ResourcesLabel
@onready var tile_info_label: Label = $TileInfoLabel
@onready var start_button: Button = $StartButton
@onready var pause_button: Button = $PauseButton
@onready var clock_label: Label = $ClockLabel
@onready var building_select: OptionButton = $BuildingSelect
@onready var unit_select: OptionButton = $UnitSelect
@onready var spawn_button: Button = $SpawnUnitButton


func _ready() -> void:
        start_button.pressed.connect(func(): start_pressed.emit())
        pause_button.pressed.connect(func(): pause_pressed.emit())
        building_select.item_selected.connect(func(id): building_selected.emit(get_selected_building()))
        spawn_button.pressed.connect(func(): spawn_unit_pressed.emit(get_selected_unit()))


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


func set_building_options(buildings: Array) -> void:
        building_select.clear()
        for name in buildings:
                building_select.add_item(name)
        building_select.select(0)
        building_selected.emit(get_selected_building())


func set_unit_options(units: Array) -> void:
        unit_select.clear()
        for name in units:
                unit_select.add_item(name)
        unit_select.select(0)


func get_selected_building() -> String:
        var idx := building_select.get_selected_id()
        return building_select.get_item_text(idx)


func get_selected_unit() -> String:
        var idx := unit_select.get_selected_id()
        return unit_select.get_item_text(idx)
