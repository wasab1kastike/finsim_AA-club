extends RefCounted
class_name FogMap

## Name used to identify the fog source within the TileSet.
const FOG_SOURCE_NAME := "fog"

var layer: TileMapLayer
var source_id: int = -1

static var _cached_texture: Texture2D
static var _cached_source: TileSetAtlasSource

func _init(p_layer: TileMapLayer) -> void:
    layer = p_layer
    var tile_map: TileMap = layer.get_parent()
    var tset: TileSet = tile_map.tile_set
    if tset == null:
        tset = TileSet.new()
        tset.tile_shape = TileSet.TILE_SHAPE_HEXAGON
        tile_map.tile_set = tset
    source_id = _get_or_create_fog_source(tset)

func set_fog(coord: Vector2i) -> void:
    layer.set_cell(coord, source_id)

func clear_fog(coord: Vector2i) -> void:
    layer.erase_cell(coord)

## Generates a fog texture based on the TileSet tile size.
func _generate_fog_texture(size: Vector2i) -> Texture2D:
    var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0.55))
    return ImageTexture.create_from_image(img)

## Returns an existing fog source or creates one if absent.
func _get_or_create_fog_source(tset: TileSet) -> int:
    var size: Vector2i = tset.tile_size
    for i in range(tset.get_source_count()):
        var id: int = tset.get_source_id(i)
        var existing: TileSetSource = tset.get_source(id)
        if existing is TileSetAtlasSource and existing.resource_name == FOG_SOURCE_NAME:
            return id
    if _cached_texture == null or _cached_source == null or _cached_source.texture_region_size != size:
        if _cached_texture == null or (_cached_source != null and _cached_source.texture_region_size != size):
            _cached_texture = _generate_fog_texture(size)
        _cached_source = TileSetAtlasSource.new()
        _cached_source.resource_name = FOG_SOURCE_NAME
        _cached_source.texture = _cached_texture
        _cached_source.texture_region_size = size
    var src := _cached_source.duplicate()
    return tset.add_source(src)
