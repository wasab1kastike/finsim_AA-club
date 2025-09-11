extends Node2D

signal tile_clicked(qr: Vector2i)

@onready var cam: Camera2D = $Camera2D
@onready var grid: TileMap = $HexMap/TileMap
@onready var hex_map: HexMap = $HexMap
@onready var units_root: Node2D = $Units
@onready var battle_manager: Node = $BattleManager

var selected_unit: Node = null
var unit_scene: PackedScene = preload("res://scenes/units/Unit.tscn")

const RaiderManager = preload("res://scripts/world/RaiderManager.gd")
const UnitDataBase = preload("res://scripts/units/UnitData.gd")

var raider_manager: RaiderManager

func _ready() -> void:
	cam.position = grid.map_to_local(Vector2i(0, 0))
	raider_manager = RaiderManager.new()
	add_child(raider_manager)
	raider_manager.setup(hex_map, units_root, unit_scene)
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
	raider_manager.process_tick()
	if battle_manager:
		battle_manager.process_tick()


func spawn_unit_at_center() -> void:
	var u: Node = unit_scene.instantiate()
	var data_res: UnitDataBase = load("res://resources/units/saunoja.tres")
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
		GameState.res[Resources.LAUDEVALTA] = GameState.res.get(Resources.LAUDEVALTA, 0.0) + 0.5
	elif survivors.is_empty():
		GameState.decrease_saunatunnelma(1.0)
	var casualties := initial - survivors.size()
	if casualties > 0:
		GameState.add_sisu(casualties)
	GameState.tiles[pos] = tile
	GameState.set_hostile(pos, not enemy_left.is_empty())
