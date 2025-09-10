extends Node2D

signal tile_clicked(qr: Vector2i)

@onready var hex_map: TileMap = $HexMap
@onready var units_root: Node2D = $Units

var selected_unit: Node = null
var unit_scene: PackedScene = preload("res://scenes/units/Unit.tscn")
const Pathing = preload("res://scripts/world/Pathing.gd")
const AutoResolve = preload("res://scripts/battle/AutoResolve.gd")
const Resources = preload("res://scripts/core/Resources.gd")
const UnitData = preload("res://scripts/units/UnitData.gd")

func _ready() -> void:
    hex_map.tile_clicked.connect(_on_tile_clicked)
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
    if enemy_left.is_empty() and survivors.size() > 0:
        tile["owner"] = "player"
        GameState.res[Resources.INFLUENCE] = GameState.res.get(Resources.INFLUENCE, 0.0) + 0.5
    elif survivors.is_empty():
        GameState.res[Resources.MORALE] = GameState.res.get(Resources.MORALE, 0.0) - 1.0
    var casualties := initial - survivors.size()
    if casualties > 0:
        GameState.res[Resources.SISU] = min(GameState.res.get(Resources.SISU, 0.0) + casualties, 10.0)
    GameState.tiles[pos] = tile

func spend_sisu_heal() -> bool:
    if GameState.res.get(Resources.SISU, 0.0) < 1.0:
        return false
    GameState.res[Resources.SISU] = GameState.res.get(Resources.SISU, 0.0) - 1.0
    for i in range(GameState.units.size()):
        var u: Dictionary = GameState.units[i]
        var ud: UnitData = load(u.get("data_path", "")) as UnitData
        if ud:
            var max_hp: int = ud.max_health
            var new_hp: int = int(min(u.get("hp", 0) + max_hp * 0.2, max_hp))
            u["hp"] = new_hp
            GameState.units[i] = u
            for child in units_root.get_children():
                if child.id == u.get("id", ""):
                    child.hp = new_hp
                    break
    GameState.save()
    return true
