extends Node

var res := {
    "gold": 100.0,
    "wood": 100.0,
    "food": 0.0,
    "research": 0.0,
    "influence": 0.0,
    "sisu": 0.0,
    "morale": 100.0,
}

var meta := {
    "production_mult": 1.0,
}

var tiles: Dictionary = {}

var last_timestamp: int = 0

const SAVE_PATH := "user://save.json"

func _ready() -> void:
    load_state()

func save() -> void:
    last_timestamp = Time.get_unix_time_from_system()
    var tiles_array: Array = []
    for pos in tiles.keys():
        var info := tiles[pos]
        tiles_array.append({
            "q": pos.x,
            "r": pos.y,
            "terrain": info.get("terrain", "")
        })
    var data := {
        "res": res,
        "meta": meta,
        "tiles": tiles_array,
        "last_timestamp": last_timestamp,
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
    meta = data.get("meta", meta)
    tiles.clear()
    for t in data.get("tiles", []):
        var q := int(t.get("q", 0))
        var r := int(t.get("r", 0))
        tiles[Vector2i(q, r)] = {"terrain": t.get("terrain", ""), "q": q, "r": r}
    last_timestamp = int(data.get("last_timestamp", Time.get_unix_time_from_system()))
