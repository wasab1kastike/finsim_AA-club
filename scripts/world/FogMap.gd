extends RefCounted
class_name FogMap

## Name used to identify the fog source within the TileSet.
const FOG_SOURCE_NAME := "fog"

var tile_map: TileMap
var fog_layer: TileMapLayer
var source_id: int = -1

func _init(p_tile_map: TileMap, p_fog_layer: TileMapLayer) -> void:
    tile_map = p_tile_map
    fog_layer = p_fog_layer
    var tset: TileSet = tile_map.tile_set
    if tset == null:
        tset = TileSet.new()
        tset.tile_shape = TileSet.TILE_SHAPE_HEXAGON
        tile_map.tile_set = tset
    source_id = _get_or_create_fog_source(tset)

func set_fog(coord: Vector2i) -> void:
    fog_layer.set_cell(coord, source_id)

func clear_fog(coord: Vector2i) -> void:
    fog_layer.erase_cell(coord)

## Generates a fog texture based on the TileSet tile size.
func _generate_fog_texture(size: Vector2i) -> Texture2D:
    var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0.75))
    return ImageTexture.create_from_image(img)

## Returns an existing fog source or creates one if absent.
func _get_or_create_fog_source(tset: TileSet) -> int:
    var size: Vector2i = tset.tile_size
    for id in tset.get_source_id_list():
        var existing := tset.get_source(id)
        if existing is TileSetAtlasSource and existing.resource_name == FOG_SOURCE_NAME:
            return id
    var src := TileSetAtlasSource.new()
    src.resource_name = FOG_SOURCE_NAME
    src.texture = _generate_fog_texture(size)
    src.texture_region_size = size
    return tset.add_source(src)
