extends Node

func _setup_tiles(count: int, hostiles: int) -> void:
    var gs = Engine.get_main_loop().root.get_node("GameState")
    gs.tiles.clear()
    gs.hostile_tiles.clear()
    for i in range(count):
        var c := Vector2i(i, 0)
        gs.tiles[c] = {"terrain": "forest", "owner": "none", "building": null, "explored": true}
    for i in range(hostiles):
        var coord := Vector2i(i * 10, 0)
        gs.tiles[coord]["hostile"] = true
        gs.set_hostile_tile(coord, true)

func _old_iter(gs) -> int:
    var cnt := 0
    for coord in gs.tiles.keys():
        var tile = gs.tiles[coord]
        if tile.get("hostile", false):
            cnt += 1
    return cnt

func _new_iter(gs) -> int:
    var cnt := 0
    for coord in gs.hostile_tiles:
        var tile = gs.tiles.get(coord, {})
        if tile.get("hostile", false):
            cnt += 1
    return cnt

func test_raider_spawn_performance(res) -> void:
    var gs = Engine.get_main_loop().root.get_node("GameState")
    _setup_tiles(100000, 100)
    var iterations := 5
    var old_time := 0
    for i in range(iterations):
        var t0 := Time.get_ticks_usec()
        _old_iter(gs)
        old_time += Time.get_ticks_usec() - t0
    var new_time := 0
    for i in range(iterations):
        var t1 := Time.get_ticks_usec()
        _new_iter(gs)
        new_time += Time.get_ticks_usec() - t1
    if new_time * 5 >= old_time:
        res.fail("new iteration %dus vs old %dus" % [new_time, old_time])
