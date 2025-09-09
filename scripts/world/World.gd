extends Node2D

const BUILDINGS := {
	"Farm": preload("res://resources/buildings/farm.tres"),
	"Mine": preload("res://resources/buildings/mine.tres"),
	"Barracks": preload("res://resources/buildings/barracks.tres"),
}

var selected_building: Resource = BUILDINGS["Farm"]

var selected_tile: Vector2i = Vector2i.ZERO
var tile_occupants: Dictionary = {}

@onready var hud: CanvasLayer = $Hud
@onready var game_clock: Node = $GameClock
@onready var map_generator: Node2D = $MapGenerator
var hex_tiles: Dictionary = {}

func _ready() -> void:
	hud.start_pressed.connect(game_clock.start)
	hud.pause_pressed.connect(game_clock.stop)
	hud.building_selected.connect(_on_building_selected)
	hud.build_pressed.connect(_on_build_pressed)
	game_clock.tick.connect(_on_tick)
	for hex in map_generator.get_children():
		hex_tiles[Vector2i(hex.q, hex.r)] = hex
	hud.update_resources(GameState.res)
	hud.update_tile(selected_tile, null)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = map_generator.to_local(event.position)
		selected_tile = map_generator.world_to_axial(pos)
		hud.update_tile(selected_tile, tile_occupants.get(selected_tile))
	elif event is InputEventKey and event.pressed and event.keycode == KEY_B:
		construct_building(selected_building, selected_tile)

func construct_building(building_res: Resource, tile_pos: Vector2i) -> void:
	if tile_occupants.has(tile_pos) or !hex_tiles.has(tile_pos):
		return
	var building: Building = building_res.duplicate(true) as Building
	var cost := building.get_construction_cost()
	for res_name in cost.keys():
		GameState.res[res_name] = GameState.res.get(res_name, 0) - cost[res_name]
	tile_occupants[tile_pos] = building
	hud.update_resources(GameState.res)
	hud.update_tile(tile_pos, building)

func _on_tick(time: float) -> void:
	for building in tile_occupants.values():
		for res_name in building.get_production_rates().keys():
			GameState.res[res_name] = (
				GameState.res.get(res_name, 0) + building.get_production_rates()[res_name]
			)
	hud.update_resources(GameState.res)
	hud.update_clock(time)

func _on_building_selected(name: String) -> void:
	selected_building = BUILDINGS.get(name, BUILDINGS["Farm"])

func _on_build_pressed() -> void:
	construct_building(selected_building, selected_tile)
