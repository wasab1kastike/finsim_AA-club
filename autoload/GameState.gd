extends Node

const WOOD_PER_TICK := 0.2
const FOOD_PER_TICK := 0.1
const STEAM_PER_TICK := 0.2

const Resources = preload("res://scripts/core/Resources.gd")

var res := {
    Resources.WOOD: 0.0,
    Resources.FOOD: 0.0,
    Resources.ORE: 0.0,
    Resources.RESEARCH: 0.0,
    Resources.INFLUENCE: 0.0,
    Resources.STEAM: 0.0,
    Resources.SISU: 0.0,
    Resources.MORALE: 100.0,
    Resources.GOLD: 0.0,
}

var last_timestamp: int = 0

var tiles: Dictionary = {}
var units: Array = []

const SAVE_PATH := "user://save.json"

func _ready() -> void:
    load_state()
    GameClock.tick.connect(_on_tick)

func _on_tick() -> void:
    res[Resources.WOOD] += WOOD_PER_TICK
    res[Resources.FOOD] += FOOD_PER_TICK
    res[Resources.STEAM] += STEAM_PER_TICK

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
    last_timestamp = int(data.get("last_timestamp", Time.get_unix_time_from_system()))
    tiles.clear()
    var tile_data: Dictionary = data.get("tiles", {})
    for key in tile_data.keys():
        var parts: PackedStringArray = key.split(",")
        if parts.size() == 2:
            var c := Vector2i(int(parts[0]), int(parts[1]))
            tiles[c] = tile_data[key]
    units.clear()
    for u in data.get("units", []):
        var pos_arr: Array = u.get("pos_qr", [0, 0])
        var uid: String = u.get("id", "")
        if uid == "":
            uid = UUID.new_uuid_string()
        units.append({
            "id": uid,
            "type": u.get("type", ""),
            "data_path": u.get("data_path", ""),
            "pos_qr": Vector2i(int(pos_arr[0]), int(pos_arr[1])),
            "hp": int(u.get("hp", 0)),
        })

    var now := Time.get_unix_time_from_system()
    var elapsed := now - last_timestamp
    if elapsed > 0:
        var ticks := int(elapsed / GameClock.TICK_INTERVAL)
        if ticks > 0:
            res[Resources.WOOD] += WOOD_PER_TICK * ticks
            res[Resources.FOOD] += FOOD_PER_TICK * ticks
            res[Resources.STEAM] += STEAM_PER_TICK * ticks
    last_timestamp = now
    save()

func load() -> void:
    load_state()

