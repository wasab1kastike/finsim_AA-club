extends Node

func _reset_tiles() -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    gs.tiles.clear()

func test_generate_tiles(res) -> void:
    _reset_tiles()
    var HexMap = load("res://scripts/world/HexMap.gd")
    var map = HexMap.new()
    map.add_layer(1)
    map.radius = 2
    map.terrain_weights = {"forest": 1.0}
    map._setup_tileset()
    map._generate_tiles()
    var gs = Engine.get_main_loop().root.get_node("GameState")
    if gs.tiles.size() != 19:
        res.fail("Expected 19 tiles, got %d" % gs.tiles.size())
    else:
        for t in gs.tiles.values():
            if t.get("terrain") != "forest":
                res.fail("Unexpected terrain %s" % t.get("terrain"))
                break

func test_reveal_area(res) -> void:
    _reset_tiles()
    var HexMap = load("res://scripts/world/HexMap.gd")
    var map = HexMap.new()
    map.add_layer(1)
    map.radius = 2
    map.terrain_weights = {"forest": 1.0}
    map._setup_tileset()
    map._generate_tiles()
    map.reveal_area(Vector2i.ZERO, 1)
    var gs = Engine.get_main_loop().root.get_node("GameState")
    var explored: Array[Vector2i] = []
    for coord in gs.tiles.keys():
        if gs.tiles[coord]["explored"]:
            explored.append(coord)
    var expected := [
        Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1),
        Vector2i(0,-1), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,1)
    ]
    if explored.size() != expected.size():
        res.fail("Expected %d explored, got %d" % [expected.size(), explored.size()])
    else:
        for e in expected:
            if e not in explored:
                res.fail("Missing %s" % e)
                break
    for coord in gs.tiles.keys():
        if coord not in expected and gs.tiles[coord]["explored"]:
            res.fail("Tile %s explored outside radius" % coord)
            break

func _remove_save(gs) -> void:
    if FileAccess.file_exists(gs.SAVE_PATH):
        DirAccess.remove_absolute(gs.SAVE_PATH)

func test_tiles_persist_across_save(res) -> void:
    _reset_tiles()
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var HexMap = load("res://scripts/world/HexMap.gd")
    var map = HexMap.new()
    map.add_layer(1)
    map.radius = 1
    map.terrain_weights = {"forest": 1.0}
    map._setup_tileset()
    map._generate_tiles()
    _remove_save(gs)
    gs.save()
    var before := JSON.stringify(gs.tiles)
    gs.tiles.clear()
    gs.load()
    var after := JSON.stringify(gs.tiles)
    if before != after:
        res.fail("tiles did not persist across save/load")
    _remove_save(gs)
