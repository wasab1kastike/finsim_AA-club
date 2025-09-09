extends Node2D

const BUILDINGS := {
        "Farm": preload("res://resources/buildings/farm.tres"),
        "Lumber Mill": preload("res://resources/buildings/lumber_mill.tres"),
        "Gold Mine": preload("res://resources/buildings/gold_mine.tres"),
}

const UNIT_RESOURCES := {
        "Footman": preload("res://resources/units/footman.tres"),
        "Archer": preload("res://resources/units/archer.tres"),
        "Knight": preload("res://resources/units/knight.tres"),
}

var selected_tile: Vector2i = Vector2i.ZERO
var tile_occupants: Dictionary = {}
var selected_building_name: String = "Farm"

@onready var hud: CanvasLayer = $Hud
@onready var game_clock: Node = $GameClock
@onready var tile_map: TileMap = $LaneTileMap
var battle_manager := preload("res://scripts/battle/BattleManager.gd").new()


func _ready() -> void:
        add_child(battle_manager)
        hud.start_pressed.connect(game_clock.start)
        hud.pause_pressed.connect(game_clock.stop)
        game_clock.tick.connect(_on_tick)
        hud.update_resources(GameState.res)
        hud.update_tile(selected_tile, null)
        hud.building_selected.connect(_on_building_selected)
        hud.spawn_unit_pressed.connect(_on_spawn_unit_pressed)
        hud.set_building_options(BUILDINGS.keys())
        hud.set_unit_options(UNIT_RESOURCES.keys())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = tile_map.to_local(event.position)
		selected_tile = tile_map.local_to_map(pos)
		hud.update_tile(selected_tile, tile_occupants.get(selected_tile))
        elif event is InputEventKey and event.pressed and event.keycode == KEY_B:
                var building_res: Resource = BUILDINGS.get(selected_building_name, null)
                if building_res:
                        construct_building(building_res, selected_tile)


func construct_building(building_res: Resource, tile_pos: Vector2i) -> void:
	if tile_occupants.has(tile_pos):
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
        selected_building_name = name


func _on_spawn_unit_pressed(unit_name: String) -> void:
        var unit_res: Resource = UNIT_RESOURCES.get(unit_name, null)
        if unit_res:
                battle_manager.spawn_unit(unit_res)
