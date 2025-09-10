extends Node

const Pathing = preload("res://scripts/world/Pathing.gd")
const HexUtils = preload("res://scripts/world/HexUtils.gd")

var hex_map: TileMap
var units_root: Node2D
var unit_scene: PackedScene

var raiders: Array = []
var _tick_counter: int = 0

func setup(hmap: TileMap, units: Node2D, scene: PackedScene) -> void:
    hex_map = hmap
    units_root = units
    unit_scene = scene

func process_tick() -> void:
    _tick_counter += 1
    if _tick_counter % 20 == 0:
        _spawn_raiders()
    _move_raiders()

func _spawn_raiders() -> void:
    for coord in GameState.tiles.keys():
        var tile: Dictionary = GameState.tiles[coord]
        if tile.get("hostile", false):
            var target: Vector2i = _find_target(coord)
            var path: Array[Vector2i] = Pathing.bfs_path(coord, target, func(p: Vector2i):
                return GameState.tiles.has(p) and GameState.tiles[p].get("terrain") != "lake"
            )
            if path.size() >= 2:
                var r: Node = unit_scene.instantiate()
                r.pos_qr = coord
                r.position = hex_map.axial_to_world(coord)
                var vis = r.get_node_or_null("Visual")
                if vis:
                    vis.color = Color(0,0,0)
                units_root.add_child(r)
                raiders.append({"node": r, "path": path, "step": 0})

func _move_raiders() -> void:
    for i in range(raiders.size() - 1, -1, -1):
        var data: Dictionary = raiders[i]
        var node = data["node"]
        var path: Array[Vector2i] = data["path"]
        var step: int = data["step"]
        if step + 1 < path.size():
            step += 1
            var next: Vector2i = path[step]
            node.pos_qr = next
            node.position = hex_map.axial_to_world(next)
            data["step"] = step
            raiders[i] = data
        else:
            node.queue_free()
            raiders.remove_at(i)

func _find_target(start: Vector2i) -> Vector2i:
    var best := Vector2i.ZERO
    var best_dist := HexUtils.axial_distance(start, Vector2i.ZERO)
    for coord in GameState.tiles.keys():
        var tile: Dictionary = GameState.tiles[coord]
        if tile.get("owner", "") == "player" and tile.get("building") != null:
            var dist := HexUtils.axial_distance(start, coord)
            if dist < best_dist:
                best_dist = dist
                best = coord
    return best
