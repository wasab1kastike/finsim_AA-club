extends Node

var res := {
    "wood": 0.0,
    "food": 0.0,
    "research": 0.0,
    "influence": 0.0,
    "sisu": 0.0,
    "morale": 100.0,
}

var meta := {
    "production_mult": 1.0,
}

var last_timestamp: int = 0

const SAVE_PATH := "user://save.json"

func _ready() -> void:
    load()

func save() -> void:
    last_timestamp = Time.get_unix_time_from_system()
    var data := {
        "res": res,
        "meta": meta,
        "last_timestamp": last_timestamp,
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        file.close()

func load() -> void:
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
    last_timestamp = int(data.get("last_timestamp", Time.get_unix_time_from_system()))
