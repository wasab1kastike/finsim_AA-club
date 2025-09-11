extends TileMapLayer
class_name FogMap

var source_id: int = -1

func _ready() -> void:
    var tile_map: TileMap = get_parent() as TileMap
    var tset: TileSet = tile_map.tile_set
    if tset == null:
        tset = TileSet.new()
        tset.tile_shape = TileSet.TILE_SHAPE_HEXAGON
        tile_map.tile_set = tset
    source_id = _get_or_create_fog_source(tset)

func _get_or_create_fog_source(tset: TileSet) -> int:
    if source_id != -1 and tset.has_source(source_id):
        return source_id
    var size: Vector2i = tset.tile_size
    var tex := _generate_fog_texture(size)
    var src := TileSetAtlasSource.new()
    src.texture = tex
    src.texture_region_size = size
    return tset.add_source(src)

## Generates a fog texture based on the TileSet tile size.
func _generate_fog_texture(size: Vector2i) -> Texture2D:
    var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0.75))
    return ImageTexture.create_from_image(img)
