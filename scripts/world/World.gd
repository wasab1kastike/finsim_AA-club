extends Node2D

const FARM_BUILDING: Resource = preload("res://resources/buildings/farm.tres")

var selected_tile: Vector2i = Vector2i.ZERO
var tile_occupants: Dictionary = {}
var units: Array[Unit] = []
var explored_tiles: Dictionary = {}

@onready var hud: CanvasLayer = $Hud
@onready var game_clock: Node = $GameClock
@onready var tile_map: TileMap = $LaneTileMap

func _ready() -> void:
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
            GameState.res[res_name] = GameState.res.get(res_name, 0) + building.get_production_rates()[res_name]
    hud.update_resources(GameState.res)
    hud.update_clock(time)

func add_unit(unit_res: Resource, position: Vector2i, owner: String) -> Unit:
    var unit: Unit = unit_res.duplicate(true) as Unit
    unit.position = position
    unit.owner = owner
    units.append(unit)
    _reveal_from(unit)
    return unit

func move_unit(unit: Unit, target: Vector2i) -> void:
    var path := unit.move_to(target, func(pos): return true)
    if path.is_empty():
        return
    _reveal_from(unit)
    _check_combat(unit)

func _reveal_from(unit: Unit) -> void:
    var to_reveal: Array[Vector2i] = [unit.position]
    to_reveal += Pathfinder.axial_neighbors(unit.position)
    for pos in to_reveal:
        explored_tiles[pos] = true

func is_explored(pos: Vector2i) -> bool:
    return explored_tiles.get(pos, false)

func _check_combat(moved: Unit) -> void:
    for other in units:
        if other == moved:
            continue
        if other.owner == moved.owner:
            continue
        var adjacent := Pathfinder.axial_neighbors(other.position)
        if other.position == moved.position or moved.position in adjacent:
            _resolve_combat(moved, other)

func _resolve_combat(a: Unit, b: Unit) -> void:
    a.deal_damage(b)
    b.deal_damage(a)
    if not a.is_alive():
        units.erase(a)
    if not b.is_alive():
        units.erase(b)
