extends Node

const FogMap = preload("res://scripts/world/FogMap.gd")

func _make_tilemap() -> TileMap:
    var tile_map := TileMap.new()
    var tset := TileSet.new()
    tset.tile_shape = TileSet.TILE_SHAPE_HEXAGON
    tset.tile_size = Vector2i(8, 8)
    tile_map.tile_set = tset
    return tile_map

func test_fog_source_created(res) -> void:
    var tile_map := _make_tilemap()
    var fog := FogMap.new()
    tile_map.add_child(fog)
    fog._ready()
    var tset := tile_map.tile_set
    var count := tset.get_source_count()
    if count != 1:
        res.fail("Expected 1 fog source, got %d" % count)
        return
    var src := tset.get_source(fog.source_id) as TileSetAtlasSource
    if src.texture_region_size != tset.tile_size:
        res.fail("Fog source size %s does not match tileset %s" % [src.texture_region_size, tset.tile_size])
        return
    fog.set_cell(Vector2i(1,1), fog.source_id)
    if fog.source_id != tset.get_source_id(0):
        res.fail("FogMap did not use fog source for set_cell")

func test_ready_is_idempotent(res) -> void:
    var tile_map := _make_tilemap()
    var fog := FogMap.new()
    tile_map.add_child(fog)
    fog._ready()
    fog._ready()
    var tset := tile_map.tile_set
    var count := tset.get_source_count()
    if count != 1:
        res.fail("_ready created duplicate sources: %d" % count)
