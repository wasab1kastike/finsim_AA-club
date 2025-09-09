extends Node
class_name NeighborAI

## Simple neighbor exploration and building AI.
##
## The AI periodically acts on `GameClock` ticks. It moves its units to
## unexplored adjacent tiles, keeping track of fog-of-war internally so it does
## not see beyond explored tiles. After moving it attempts to place buildings on
## explored tiles based on a list of resource priorities. The script expects to
## be given the same map data dictionary that the player uses; typically the
## World scene can expose this via metadata or a getter.

@export var game_clock_path: NodePath = "../GameClock"
@export var resource_priorities: PackedStringArray = ["gold", "wood", "food"]
@export var building_catalog: Dictionary = {
    "food": preload("res://resources/buildings/farm.tres"),
}

var map_data: Dictionary = {}
var _game_clock: Node
var _rng := RandomNumberGenerator.new()
var _units: Array[Vector2i] = []
var _explored: Dictionary = {}

func _ready() -> void:
    _game_clock = get_node_or_null(game_clock_path)
    if _game_clock:
        _game_clock.tick.connect(_on_tick)
    # copy map data from parent if provided
    if map_data.is_empty() and get_parent():
        if get_parent().has_meta("map_data"):
            map_data = get_parent().get_meta("map_data")
        elif get_parent().has_method("get_map_data"):
            map_data = get_parent().get_map_data()
    # seed RNG with parent's map seed if present so we match player map
    if get_parent() and get_parent().has_meta("map_seed"):
        _rng.seed = int(get_parent().get_meta("map_seed"))
    else:
        _rng.seed = RNG.randi()

func register_unit(start_tile: Vector2i) -> void:
    _units.append(start_tile)
    _mark_explored(start_tile)

func _on_tick() -> void:
    _explore()
    _attempt_build()

func _explore() -> void:
    for i in _units.size():
        var next: Vector2i = _select_unexplored_adjacent(_units[i])
        if next != Vector2i.ZERO and next != _units[i]:
            _units[i] = next
            _mark_explored(next)

func _select_unexplored_adjacent(pos: Vector2i) -> Vector2i:
    var candidates: Array[Vector2i] = [
        pos + Vector2i.RIGHT,
        pos + Vector2i.LEFT,
        pos + Vector2i.UP,
        pos + Vector2i.DOWN,
    ]
    candidates = candidates.filter(func(p): return map_data.has(p) and not _explored.get(p, false))
    if candidates.is_empty():
        return pos
    return candidates[_rng.randi_range(0, candidates.size() - 1)]

func _attempt_build() -> void:
    for res in resource_priorities:
        var building_res: Resource = building_catalog.get(res)
        if building_res == null:
            continue
        for tile in _explored.keys():
            if _can_build_on(tile, res):
                _place_building(tile, building_res)
                return

func _can_build_on(tile: Vector2i, res_name: String) -> bool:
    var tile_data: Dictionary = map_data.get(tile, {})
    if tile_data.get("building", false):
        return false
    if tile_data.get("resource") != res_name:
        return false
    var cost := (building_catalog[res_name] as Building).get_construction_cost()
    for key in cost.keys():
        if GameState.res.get(key, 0) < cost[key]:
            return false
    return true

func _place_building(tile: Vector2i, building_res: Resource) -> void:
    var building: Building = building_res.duplicate(true) as Building
    var cost := building.get_construction_cost()
    for key in cost.keys():
        GameState.res[key] = GameState.res.get(key, 0) - cost[key]
    map_data[tile]["building"] = building.name

func _mark_explored(tile: Vector2i) -> void:
    _explored[tile] = true
