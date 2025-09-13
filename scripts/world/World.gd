extends Node2D

signal tile_clicked(qr: Vector2i)

const Palette = preload("res://styles/palette.gd")

@onready var cam: Camera2D = $Camera2D
@onready var hex_map: HexMap = $HexMap
@onready var units_root: Node2D = $Units

var selected_unit: Node = null
var unit_scene: PackedScene = preload("res://scenes/units/Unit.tscn")

const UnitDataBase = preload("res://scripts/units/UnitData.gd")

var raider_manager: RaiderManager

func _ready() -> void:
    RenderingServer.set_default_clear_color(Palette.BG)
    cam.limit_smoothed = true
    cam.position_smoothing_enabled = true
    cam.zoom_smoothed = true
    cam.position_smoothing_speed = 8.0
    cam.zoom_smoothing_speed = 8.0
    var vignette := ColorRect.new()
    vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
    vignette.anchor_right = 1.0
    vignette.anchor_bottom = 1.0
    var v_shader := Shader.new()
    v_shader.code = """
shader_type canvas_item;
void fragment() {
    vec2 uv = SCREEN_UV * 2.0 - 1.0;
    float d = length(uv);
    float vig = smoothstep(0.5, 0.9, d);
    COLOR = vec4(0.0, 0.0, 0.0, vig);
}
"""
    var v_mat := ShaderMaterial.new()
    v_mat.shader = v_shader
    vignette.material = v_mat
    add_child(vignette)
    var fog := ColorRect.new()
    fog.name = "FogOverlay"
    fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
    fog.anchor_right = 1.0
    fog.anchor_bottom = 1.0
    var f_shader := Shader.new()
    f_shader.code = """
shader_type canvas_item;
uniform float density : hint_range(0.0, 1.0) = 0.0;
void fragment() {
    COLOR = vec4(0.0, 0.0, 0.0, density);
}
"""
    var f_mat := ShaderMaterial.new()
    f_mat.shader = f_shader
    fog.material = f_mat
    add_child(fog)
    cam.position = hex_map.axial_to_world(Vector2i(0, 0))
    hex_map.reveal_area(Vector2i(0, 0), 2)
    print("World._ready: reveal_area executed")
    hex_map.reveal_all()
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

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        var delta := 0.0
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            delta = -0.1
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            delta = 0.1
        if delta != 0.0:
            var z := clamp(cam.zoom.x + delta, 0.5, 2.0)
            cam.zoom = Vector2.ONE * z
            get_viewport().set_input_as_handled()

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

func torille() -> void:
    var sauna_tiles: Array[Vector2i] = []
    for c in GameState.tiles.keys():
        if GameState.tiles[c].get("building", "") == "sauna":
            sauna_tiles.append(c)
    if sauna_tiles.is_empty():
        return
    var passable := func(p: Vector2i):
        return GameState.tiles.has(p) and GameState.tiles[p].get("terrain", "") != "lake"
    for unit in units_root.get_children():
        var best_dest: Vector2i = unit.pos_qr
        var best_len := 1_000_000
        for sauna in sauna_tiles:
            var path: Array[Vector2i] = Pathing.bfs_path(unit.pos_qr, sauna, passable)
            if path.size() > 0 and path.size() < best_len:
                best_len = path.size()
                best_dest = sauna
        if best_len < 1_000_000:
            unit.pos_qr = best_dest
            unit.position = hex_map.axial_to_world(best_dest)
            for i in range(GameState.units.size()):
                var data: Dictionary = GameState.units[i]
                if data.get("id", "") == unit.id:
                    data["pos_qr"] = best_dest
                    GameState.units[i] = data
                    break
            hex_map.reveal_area(best_dest, 1)
            _resolve_combat(best_dest)
    GameState.save()

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
