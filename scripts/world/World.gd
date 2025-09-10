extends Node2D

signal tile_clicked(qr: Vector2i)

@onready var hex_map: TileMap = $HexMap
@onready var units_root: Node2D = $Units
@onready var battle_manager: Node = $BattleManager

var selected_unit: Node = null
var unit_scene: PackedScene = preload("res://scenes/units/Unit.tscn")
const Pathing = preload("res://scripts/world/Pathing.gd")
const AutoResolve = preload("res://scripts/battle/AutoResolve.gd")
const Resources = preload("res://scripts/core/Resources.gd")
const HexUtils = preload("res://scripts/world/HexUtils.gd")

var raiders: Array = []
var _tick_counter: int = 0

func _ready() -> void:
    hex_map.tile_clicked.connect(_on_tile_clicked)
    GameClock.tick.connect(_on_game_tick)
    for data in GameState.units:
        var u = unit_scene.instantiate()
        u.from_dict(data)
        u.position = hex_map.axial_to_world(u.pos_qr)
        units_root.add_child(u)
        selected_unit = u

func _on_tile_clicked(qr: Vector2i) -> void:
    emit_signal("tile_clicked", qr)
    if selected_unit:
        var path: Array[Vector2i] = Pathing.bfs_path(selected_unit.pos_qr, qr, func(p: Vector2i):
            return GameState.tiles.has(p) and GameState.tiles[p]["terrain"] != "lake"
        )
        if path.size() > 1 and path.size() - 1 <= selected_unit.move:
            var next: Vector2i = path[1]
            selected_unit.pos_qr = next
            selected_unit.position = hex_map.axial_to_world(next)
            for i in range(GameState.units.size()):
                var u: Dictionary = GameState.units[i]
                if u.get("id", "") == selected_unit.id:
                    GameState.units[i] = selected_unit.to_dict()
                    break
            hex_map.reveal_area(next, 1)
            _resolve_combat(next)
            GameState.save()

func _on_game_tick() -> void:
    _tick_counter += 1
    if _tick_counter % 20 == 0:
        _spawn_raiders()
    _move_raiders()
    if battle_manager:
        battle_manager.process_tick()

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

func spawn_unit_at_center() -> void:
    var u: Node = unit_scene.instantiate()
    var data_res: UnitData = load("res://resources/units/footman.tres")
    if data_res:
        u.apply_data(data_res)
    u.id = UUID.new_uuid_string()
    units_root.add_child(u)
    u.pos_qr = Vector2i.ZERO
    u.position = hex_map.axial_to_world(u.pos_qr)
    GameState.units.append(u.to_dict())
    selected_unit = u
    hex_map.reveal_area(u.pos_qr, 1)
    GameState.save()

func reveal_all() -> void:
    hex_map.reveal_all()
    GameState.save()

func center_on(qr: Vector2i) -> void:
    position = -hex_map.axial_to_world(qr)

func _resolve_combat(pos: Vector2i) -> void:
    var tile: Dictionary = GameState.tiles.get(pos, {})
    var enemies: Array = tile.get("hostiles", [])
    if enemies.is_empty():
        return
    var friendly: Array = []
    for u in GameState.units:
        if u.get("pos_qr", Vector2i.ZERO) == pos:
            friendly.append(u.duplicate())
    var initial := friendly.size()
    var result: Dictionary = AutoResolve.resolve(friendly, enemies, tile.get("terrain", "plain"))
    var survivors: Array = result.get("friendly", [])
    var enemy_left: Array = result.get("enemies", [])
    var ids: Dictionary = {}
    for f in survivors:
        ids[f.get("id", "")] = f.get("hp", 0)
    for i in range(GameState.units.size() - 1, -1, -1):
        var data: Dictionary = GameState.units[i]
        if data.get("pos_qr", Vector2i.ZERO) == pos:
            var uid: String = data.get("id", "")
            if ids.has(uid):
                data["hp"] = ids[uid]
                GameState.units[i] = data
            else:
                for child in units_root.get_children():
                    if child.id == uid:
                        child.queue_free()
                        break
                GameState.units.remove_at(i)
    if selected_unit and not ids.has(selected_unit.id):
        selected_unit = null
    tile["hostiles"] = enemy_left
    tile["hostile"] = not enemy_left.is_empty()
    if enemy_left.is_empty() and survivors.size() > 0:
        tile["owner"] = "player"
        GameState.res[Resources.INFLUENCE] = GameState.res.get(Resources.INFLUENCE, 0.0) + 0.5
    elif survivors.is_empty():
        GameState.res[Resources.MORALE] = GameState.res.get(Resources.MORALE, 0.0) - 1.0
    var casualties := initial - survivors.size()
    if casualties > 0:
        GameState.res[Resources.SISU] = GameState.res.get(Resources.SISU, 0.0) + casualties
    GameState.tiles[pos] = tile
