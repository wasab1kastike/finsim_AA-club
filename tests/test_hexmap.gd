extends Node

const HexMapBase = preload("res://scripts/world/HexMap.gd")

class DummyHexMap:
    extends HexMapBase

    func _init():
        var tset := TileSet.new()
        tset.tile_size = TILE_SIZE
        tset.tile_shape = TileSet.TILE_SHAPE_HEXAGON

        var tilemap := TileMap.new()
        tilemap.name = "Grid"
        tilemap.tile_set = tset
        tilemap.set_layer_name(0, "Terrain")
        tilemap.add_layer(1)
        tilemap.set_layer_name(1, "Buildings")
        add_child(tilemap)

        self.grid = tilemap

    func _set_tile(coord: Vector2i) -> void:
        pass

    func _setup_tileset() -> void:
        pass

    func _setup_layers() -> void:
        pass

    func _ready() -> void:
        _ensure_singletons()
        if GameState.tiles.is_empty():
            _generate_tiles()
        else:
            _draw_from_saved(GameState.tiles)

func _reset_tiles() -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    gs.tiles.clear()

func _remove_save(gs) -> void:
    if FileAccess.file_exists(gs.SAVE_PATH):
        DirAccess.remove_absolute(gs.SAVE_PATH)

func test_generate_tiles(res) -> void:
    _reset_tiles()
    var map = DummyHexMap.new()
    map.radius = 2
    map.terrain_weights = {"forest": 1.0}
    map._generate_tiles()
    var gs = Engine.get_main_loop().root.get_node("GameState")
    if gs.tiles.size() != 19:
        res.fail("Expected 19 tiles, got %d" % gs.tiles.size())
    else:
        for t in gs.tiles.values():
            if t.get("terrain") != "forest":
                res.fail("Unexpected terrain %s" % t.get("terrain"))
                break

func test_ready_uses_saved_tiles(res) -> void:
    _reset_tiles()
    var gs = Engine.get_main_loop().root.get_node("GameState")
    gs.tiles[Vector2i(0,0)] = {"terrain": "forest", "owner": "none", "building": "", "explored": false}
    var map = DummyHexMap.new()
    map._ready()
    if gs.tiles.size() != 1 or not gs.tiles.has(Vector2i(0,0)):
        res.fail("Expected existing tiles to persist after _ready")

func test_tiles_persist_across_save(res) -> void:
    _reset_tiles()
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var map = DummyHexMap.new()
    map.radius = 1
    map.terrain_weights = {"forest": 1.0}
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

func test_buildings_persist_across_save(res) -> void:
    _reset_tiles()
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    var map = DummyHexMap.new()
    map.radius = 1
    map.terrain_weights = {"forest": 1.0}
    map._generate_tiles()
    gs.tiles[Vector2i(0,0)]["building"] = preload("res://resources/buildings/farm.tres")
    _remove_save(gs)
    gs.save()
    gs.tiles.clear()
    gs.load()
    var loaded = gs.tiles.get(Vector2i(0,0), {}).get("building", "")
    if loaded != "farm":
        res.fail("building did not persist across save/load")
    _remove_save(gs)

func test_seed_generates_consistent_map(res) -> void:
    _reset_tiles()
    ProjectSettings.set_setting("finsim/seed", 123)
    var map1 = DummyHexMap.new()
    map1.radius = 2
    map1.terrain_weights = {"forest": 1.0, "hill": 1.0}
    map1._generate_tiles()
    var first := GameState.tiles.duplicate(true)
    _reset_tiles()
    var map2 = DummyHexMap.new()
    map2.radius = 2
    map2.terrain_weights = {"forest": 1.0, "hill": 1.0}
    map2._generate_tiles()
    var second := GameState.tiles.duplicate(true)
    ProjectSettings.clear("finsim/seed")
    if JSON.stringify(first) != JSON.stringify(second):
        res.fail("maps differ with same seed")

func test_tiles_are_saved_after_generation(res) -> void:
    _reset_tiles()
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    _remove_save(gs)
    var map = DummyHexMap.new()
    map.radius = 1
    map.terrain_weights = {"forest": 1.0}
    map._generate_tiles()
    if not FileAccess.file_exists(gs.SAVE_PATH):
        res.fail("save file not created after tile generation")
        return
    gs.tiles.clear()
    gs.load()
    if gs.tiles.is_empty():
        res.fail("tiles not persisted after generation")
    _remove_save(gs)

