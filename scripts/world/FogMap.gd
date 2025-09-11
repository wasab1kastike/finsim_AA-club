extends RefCounted
class_name FogMap

var tile_map: TileMap
var layer: int = -1
var source_id: int = -1

func setup(p_tile_map: TileMap, p_layer: int) -> void:
    tile_map = p_tile_map
    layer = p_layer
    var tset: TileSet = tile_map.tile_set
    if tset == null:
        tset = TileSet.new()
        tset.tile_shape = TileSet.TILE_SHAPE_HEXAGON
        tile_map.tile_set = tset
    var size: Vector2i = tile_map.cell_tile_size
    var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
    img.fill(Color(0,0,0,0.75))
    var tex := ImageTexture.create_from_image(img)
    var src := TileSetAtlasSource.new()
    src.texture = tex
    src.texture_region_size = size
    source_id = tset.add_source(src)

func set_cell(coord: Vector2i, sid: int = source_id) -> void:
    tile_map.set_cell(layer, coord, sid)

func erase_cell(coord: Vector2i) -> void:
    tile_map.erase_cell(layer, coord)
