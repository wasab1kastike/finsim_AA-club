extends Node2D

const Building := preload("res://scripts/core/Building.gd")
const FARM_BUILDING: Resource = preload("res://resources/buildings/farm.tres")

var selected_tile: Vector2i = Vector2i.ZERO
var tile_occupants: Dictionary = {}
var GameState: Node

@onready var hud: CanvasLayer = $Hud
@onready var game_clock: Node = $GameClock
@onready var tile_map: TileMap = $LaneTileMap


func _ready() -> void:
        GameState = get_node("/root/GameState")
        hud.start_pressed.connect(game_clock.start)
        hud.pause_pressed.connect(game_clock.stop)
        game_clock.tick.connect(_on_tick)
        hud.update_resources(GameState.res)
        hud.update_tile(selected_tile, null)


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var pos: Vector2 = tile_map.to_local(event.position)
        selected_tile = tile_map.local_to_map(pos)
        hud.update_tile(selected_tile, tile_occupants.get(selected_tile))
    elif event is InputEventKey and event.pressed and event.keycode == KEY_B:
        construct_building(FARM_BUILDING, selected_tile)


func construct_building(building_res: Resource, tile_pos: Vector2i) -> void:
    if tile_occupants.has(tile_pos):
        return
        var building = building_res
        var cost = building.get_construction_cost()
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
