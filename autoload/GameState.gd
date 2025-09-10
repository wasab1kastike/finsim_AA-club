extends Node

const HALOT_PER_TICK := 0.2
const MAKKARA_PER_TICK := 0.1
const LOYLY_PER_TICK := 0.2
const SPEED_PER_SAUNAKUNNIA := 0.25

const ResourcesLib = preload("res://scripts/core/Resources.gd")
const SaunakunniaLib = preload("res://scripts/core/Saunakunnia.gd")
const BuildingLib = preload("res://scripts/core/Building.gd")

var res := {
    ResourcesLib.HALOT: 0.0,
    ResourcesLib.MAKKARA: 0.0,
    ResourcesLib.KIUASKIVET: 0.0,
    ResourcesLib.SAUNATIETO: 0.0,
    ResourcesLib.LAUDEVALTA: 0.0,
    ResourcesLib.LOYLY: 0.0,
    ResourcesLib.SISU: 0.0,
    ResourcesLib.SAUNATUNNELMA: 100.0,
    ResourcesLib.KULTA: 100.0,
    ResourcesLib.SAUNAKUNNIA: 0.0,
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
    var mult := production_modifier * SaunakunniaLib.production_bonus(int(res.get(ResourcesLib.SAUNAKUNNIA, 0)))
    res[ResourcesLib.HALOT] += HALOT_PER_TICK * mult
    res[ResourcesLib.MAKKARA] += MAKKARA_PER_TICK * mult
    res[ResourcesLib.LOYLY] += LOYLY_PER_TICK * mult
    if modifier_ticks_remaining > 0:
        modifier_ticks_remaining -= 1
        if modifier_ticks_remaining <= 0:
            production_modifier = 1.0

func save() -> void:
    last_timestamp = int(Time.get_unix_time_from_system())
    var tile_data: Dictionary = {}
    for c in tiles.keys():
        var t: Dictionary = tiles[c]
        var b = t.get("building", null)
        if b is BuildingLib:
            t = t.duplicate()
            t["building"] = b.resource_path.get_file().get_basename()
        tile_data["%d,%d" % [c.x, c.y]] = t
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
        last_timestamp = int(Time.get_unix_time_from_system())
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        last_timestamp = int(Time.get_unix_time_from_system())
        return
    var content := file.get_as_text()
    file.close()
    var data = JSON.parse_string(content)
    if typeof(data) != TYPE_DICTIONARY:
        last_timestamp = int(Time.get_unix_time_from_system())
        return
    res = data.get("res", res)
    res[ResourcesLib.SISU] = min(10.0, res.get(ResourcesLib.SISU, 0.0))
    res[ResourcesLib.SAUNATUNNELMA] = max(0.0, res.get(ResourcesLib.SAUNATUNNELMA, 0.0))
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

    var now: int = int(Time.get_unix_time_from_system())
    var elapsed := now - last_timestamp
    if elapsed > 0:
        var ticks := int(elapsed / GameClock.TICK_INTERVAL)
        if ticks > 0:
            var mult := SaunakunniaLib.production_bonus(int(res.get(ResourcesLib.SAUNAKUNNIA, 0)))
            res[ResourcesLib.HALOT] += HALOT_PER_TICK * ticks * mult
            res[ResourcesLib.MAKKARA] += MAKKARA_PER_TICK * ticks * mult
            res[ResourcesLib.LOYLY] += LOYLY_PER_TICK * ticks * mult
    last_timestamp = now
    _apply_speed_for_saunakunnia()
    save()

func load() -> void:
    load_state()

func gain_saunakunnia() -> void:
    res[ResourcesLib.SAUNAKUNNIA] += 1
    for k in res.keys():
        if k != ResourcesLib.SAUNAKUNNIA:
            res[k] = 0.0
    production_modifier = 1.0
    modifier_ticks_remaining = 0
    _apply_speed_for_saunakunnia()
    save()

func _apply_speed_for_saunakunnia() -> void:
    var saunakunnia_level: int = int(res.get(ResourcesLib.SAUNAKUNNIA, 0))
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

func add_sisu(amount: float) -> void:
    var current: float = res.get(ResourcesLib.SISU, 0.0)
    res[ResourcesLib.SISU] = min(10.0, current + amount)

func decrease_saunatunnelma(amount: float) -> void:
    var current: float = res.get(ResourcesLib.SAUNATUNNELMA, 0.0)
    res[ResourcesLib.SAUNATUNNELMA] = max(0.0, current - amount)

