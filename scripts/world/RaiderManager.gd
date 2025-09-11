extends Node
class_name RaiderManager

var _hex: HexMap
var _units_root: Node2D
var _unit_scene: PackedScene

var raiders: Array = []
var _tick_counter: int = 0

func setup(hex_map: HexMap, units_root: Node2D, unit_scene: PackedScene) -> void:
    _hex = hex_map
    _units_root = units_root
    _unit_scene = unit_scene

func process_tick() -> void:
    _tick_counter += 1
    if _tick_counter % 20 == 0:
        _spawn_raiders()
    _move_raiders()

func _spawn_raiders() -> void:
    for coord in GameState.hostile_tiles:
        var target: Vector2i = _find_target(coord)
        var path: Array[Vector2i] = Pathing.bfs_path(coord, target, func(p: Vector2i):
            return GameState.tiles.has(p) and GameState.tiles[p].get("terrain") != "lake"
        )
        if path.size() >= 2:
            var r: Node = _unit_scene.instantiate()
            r.pos_qr = coord
            r.position = _hex.axial_to_world(coord)
            var vis = r.get_node_or_null("Visual")
            if vis:
                vis.color = Color(0,0,0)
            _units_root.add_child(r)
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
            node.position = _hex.axial_to_world(next)
            if step >= path.size() - 1:
                _raider_reached(node)
                node.queue_free()
                raiders.remove_at(i)
            else:
                data["step"] = step
                raiders[i] = data
        else:
            _raider_reached(node)
            node.queue_free()
            raiders.remove_at(i)

func _raider_reached(node) -> void:
    var tile: Dictionary = GameState.tiles.get(node.pos_qr, {})
    var hit := false
    if tile.get("owner", "") == "player":
        GameState.decrease_saunatunnelma(1.0)
        hit = true
        tile["owner"] = "enemy"
        GameState.tiles[node.pos_qr] = tile
        GameState.set_hostile(node.pos_qr, true)
    if node.pos_qr == Vector2i.ZERO and not hit:
        GameState.decrease_saunatunnelma(1.0)

func _find_target(start: Vector2i) -> Vector2i:
    var candidates: Array[Vector2i] = []
    for u in GameState.units:
        candidates.append(u.get("pos_qr", Vector2i.ZERO))
    if candidates.is_empty():
        for coord in GameState.tiles.keys():
            var tile: Dictionary = GameState.tiles[coord]
            if tile.get("owner", "") == "player" and tile.get("building") != null:
                candidates.append(coord)
    if candidates.is_empty():
        return Vector2i.ZERO
    var best := Vector2i.ZERO
    var best_dist := INF
    for coord in candidates:
        var dist := HexUtils.axial_distance(start, coord)
        if dist < best_dist:
            best_dist = dist
            best = coord
    return best
