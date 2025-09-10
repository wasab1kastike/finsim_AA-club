extends TileMap
class_name FogMap

var source_id := -1

func _ready() -> void:
    if tile_set == null:
        tile_set = TileSet.new()
        tile_set.tile_shape = TileSet.TILE_SHAPE_HEXAGON
        var size := Vector2i(96, 84)
        var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
        img.fill(Color(0,0,0,0.75))
        var tex := ImageTexture.create_from_image(img)
        var src := TileSetAtlasSource.new()
        src.texture = tex
        src.texture_region_size = size
        source_id = tile_set.add_source(src)
    else:
        # Assume first source is the fog tile
        var ids = tile_set.get_source_id_list()
        if ids.size() > 0:
            source_id = ids[0]
