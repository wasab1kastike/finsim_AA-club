extends Node

func _setup_tiles(tile_count: int, hostile_count: int) -> void:
    var gs = Engine.get_main_loop().root.get_node("GameState")
    gs.tiles.clear()
    gs.hostile_tiles.clear()
    for i in range(tile_count):
        var coord := Vector2i(i, 0)
        gs.tiles[coord] = {"terrain": "forest", "owner": "none", "building": null, "explored": true}
    for i in range(hostile_count):
        var coord := Vector2i(i * 10, 0)
        gs.tiles[coord]["hostile"] = true
        gs.hostile_tiles.append(coord)

func _naive_spawn_loop() -> void:
    for coord in GameState.tiles.keys():
        var tile: Dictionary = GameState.tiles[coord]
        if tile.get("hostile", false):
            pass

func _optimized_spawn_loop() -> void:
    for coord in GameState.hostile_tiles:
        var tile: Dictionary = GameState.tiles.get(coord, {})
        pass

func test_raider_spawn_performance(res) -> void:
    _setup_tiles(10000, 10)
    var iterations := 50
    var t0 := Time.get_ticks_usec()
    for i in range(iterations):
        _naive_spawn_loop()
    var naive_time := Time.get_ticks_usec() - t0
    var t1 := Time.get_ticks_usec()
    for i in range(iterations):
        _optimized_spawn_loop()
    var opt_time := Time.get_ticks_usec() - t1
    var gs = Engine.get_main_loop().root.get_node("GameState")
    gs.tiles.clear()
    gs.hostile_tiles.clear()
    if opt_time * 2 >= naive_time:
        res.fail("optimized %dus vs naive %dus" % [opt_time, naive_time])
