extends Node2D

@onready var hud: CanvasLayer = $Hud
@onready var game_clock: Node = $GameClock

const FARM_BUILDING: Resource = preload("res://resources/buildings/farm.tres")

var owned_buildings: Array[Building] = []

func _ready() -> void:
    hud.start_pressed.connect(game_clock.start)
    hud.pause_pressed.connect(game_clock.stop)
    game_clock.tick.connect(_on_tick)
    hud.update_resources(GameState.res)
    construct_building(FARM_BUILDING)

func construct_building(building_res: Resource) -> void:
    var building: Building = building_res.duplicate(true) as Building
    var cost := building.get_construction_cost()
    for res_name in cost.keys():
        GameState.res[res_name] = GameState.res.get(res_name, 0) - cost[res_name]
    owned_buildings.append(building)
    hud.update_resources(GameState.res)

func _on_tick(time: float) -> void:
    for building in owned_buildings:
        for res_name in building.get_production_rates().keys():
            GameState.res[res_name] = GameState.res.get(res_name, 0) + building.get_production_rates()[res_name]
    hud.update_resources(GameState.res)
    hud.update_clock(time)
