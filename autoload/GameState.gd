extends Node

const WOOD_PER_TICK := 0.2
const FOOD_PER_TICK := 0.1
const STEAM_PER_TICK := 0.2

var res := {
    "wood": 0.0,
    "food": 0.0,
    "ore": 0.0,
    "research": 0.0,
    "influence": 0.0,
    "steam": 0.0,
    "sisu": 0.0,
    "morale": 100.0,
}

var last_timestamp: int = 0

const SAVE_PATH := "user://save.json"

func _ready() -> void:
    load()
    GameClock.tick.connect(_on_tick)

func _on_tick() -> void:
    res["wood"] += WOOD_PER_TICK
    res["food"] += FOOD_PER_TICK
    res["steam"] += STEAM_PER_TICK

func save() -> void:
    last_timestamp = Time.get_unix_time_from_system()
    var data := {
        "res": res,
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
    last_timestamp = int(data.get("last_timestamp", Time.get_unix_time_from_system()))

    var now := Time.get_unix_time_from_system()
    var elapsed := now - last_timestamp
    if elapsed > 0:
        var ticks := int(elapsed / GameClock.TICK_INTERVAL)
        if ticks > 0:
            res["wood"] += WOOD_PER_TICK * ticks
            res["food"] += FOOD_PER_TICK * ticks
            res["steam"] += STEAM_PER_TICK * ticks
    last_timestamp = now
    save()

