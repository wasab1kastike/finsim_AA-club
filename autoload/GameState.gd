extends Node

const HALOT_PER_TICK := 0.2
const MAKKARA_PER_TICK := 0.1
const LOYLY_PER_TICK := 0.2
const SPEED_PER_SAUNAKUNNIA := 0.25

const Resources = preload("res://scripts/core/Resources.gd")
const SaunaKunnia = preload("res://scripts/core/SaunaKunnia.gd")

var res := {
    Resources.HALOT: 0.0,
    Resources.MAKKARA: 0.0,
    Resources.KIUASKIVET: 0.0,
    Resources.SAUNATIETO: 0.0,
    Resources.LAUDEVALTA: 0.0,
    Resources.LOYLY: 0.0,
    Resources.SISU: 0.0,
    Resources.SAUNATUNNELMA: 100.0,
    Resources.KULTA: 0.0,
    Resources.SAUNAKUNNIA: 0.0,
}

var production_modifier: float = 1.0
var modifier_ticks_remaining: int = 0

var last_timestamp: int = 0

var tiles: Dictionary = {}
var units: Array = []
var tutorial_done: bool = false
var hostile_tiles: Array[Vector2i] = []

const SAVE_PATH := "user://save.json"

func _ready() -> void:
    load_state()
    GameClock.tick.connect(_on_tick)

func _on_tick() -> void:
    var mult := production_modifier * SaunaKunnia.production_bonus(int(res.get(Resources.SAUNAKUNNIA, 0)))
    res[Resources.HALOT] += HALOT_PER_TICK * mult
    res[Resources.MAKKARA] += MAKKARA_PER_TICK * mult
    res[Resources.LOYLY] += LOYLY_PER_TICK * mult
    if modifier_ticks_remaining > 0:
        modifier_ticks_remaining -= 1
        if modifier_ticks_remaining <= 0:
            production_modifier = 1.0

func save() -> void:
    last_timestamp = Time.get_unix_time_from_system()
    var tile_data: Dictionary = {}
    for c in tiles.keys():
        tile_data["%d,%d" % [c.x, c.y]] = tiles[c]
    var unit_data: Array = []
    for u in units:
        unit_data.append({
            "id": u.get("id", ""),
            "type": u.get("type", ""),
            "data_path": u.get("data_path", ""),
            "pos_qr": [u.get("pos_qr", Vector2i.ZERO).x, u.get("pos_qr", Vector2i.ZERO).y],
            "hp": u.get("hp", 0),
        })
    var data := {
        "res": res,
        "last_timestamp": last_timestamp,
        "tiles": tile_data,
        "units": unit_data,
        "tutorial_done": tutorial_done,
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        file.close()

func load_state() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        last_timestamp = Time.get_unix_time_from_system()
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        last_timestamp = Time.get_unix_time_from_system()
        return
    var content := file.get_as_text()
    file.close()
    var data = JSON.parse_string(content)
    if typeof(data) != TYPE_DICTIONARY:
        last_timestamp = Time.get_unix_time_from_system()
        return
    res = data.get("res", res)
    tutorial_done = bool(data.get("tutorial_done", false))
    last_timestamp = int(data.get("last_timestamp", Time.get_unix_time_from_system()))
    tiles.clear()
    hostile_tiles.clear()
    var tile_data: Dictionary = data.get("tiles", {})
    for key in tile_data.keys():
        var parts: PackedStringArray = key.split(",")
        if parts.size() == 2:
            var c := Vector2i(int(parts[0]), int(parts[1]))
            tiles[c] = tile_data[key]
            if tile_data[key].get("hostile", false):
                hostile_tiles.append(c)
    units.clear()
    for u in data.get("units", []):
        var pos_arr: Array = u.get("pos_qr", [0, 0])
        var uid: String = u.get("id", "")
        if uid == "":
            uid = str(Time.get_unix_time_from_system())
        units.append({
            "id": uid,
            "type": u.get("type", ""),
            "data_path": u.get("data_path", ""),
            "pos_qr": Vector2i(int(pos_arr[0]), int(pos_arr[1])),
            "hp": int(u.get("hp", 0)),
        })

    if hostile_tiles.is_empty():
        update_hostile_tiles()

    var now := Time.get_unix_time_from_system()
    var elapsed := now - last_timestamp
    if elapsed > 0:
        var ticks := int(elapsed / GameClock.TICK_INTERVAL)
        if ticks > 0:
            var mult := SaunaKunnia.production_bonus(int(res.get(Resources.SAUNAKUNNIA, 0)))
            res[Resources.HALOT] += HALOT_PER_TICK * ticks * mult
            res[Resources.MAKKARA] += MAKKARA_PER_TICK * ticks * mult
            res[Resources.LOYLY] += LOYLY_PER_TICK * ticks * mult
    last_timestamp = now
    _apply_speed_for_saunakunnia()
    save()

func load() -> void:
    load_state()

func gain_saunakunnia() -> void:
    res[Resources.SAUNAKUNNIA] += 1
    for k in res.keys():
        if k != Resources.SAUNAKUNNIA:
            res[k] = 0.0
    production_modifier = 1.0
    modifier_ticks_remaining = 0
    _apply_speed_for_saunakunnia()
    save()

func _apply_speed_for_saunakunnia() -> void:
    var saunakunnia_level: int = int(res.get(Resources.SAUNAKUNNIA, 0))
    GameClock.set_speed(1.0 + saunakunnia_level * SPEED_PER_SAUNAKUNNIA)

func set_hostile(coord: Vector2i, hostile: bool) -> void:
    var tile: Dictionary = tiles.get(coord, {})
    if tile.is_empty():
        return
    tile["hostile"] = hostile
    tiles[coord] = tile
    if hostile:
        if not hostile_tiles.has(coord):
            hostile_tiles.append(coord)
    else:
        hostile_tiles.erase(coord)

func update_hostile_tiles() -> void:
    hostile_tiles.clear()
    for c in tiles.keys():
        if tiles[c].get("hostile", false):
            hostile_tiles.append(c)

