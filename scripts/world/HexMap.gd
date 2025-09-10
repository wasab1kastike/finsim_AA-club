extends TileMap
class_name HexMap

@export var radius := 8
@export var terrain_weights := {"forest":0.4,"taiga":0.35,"hill":0.15,"lake":0.1}

signal tile_clicked(qr:Vector2i)

const HexUtils = preload("res://scripts/world/HexUtils.gd")

var _terrain_sources: Dictionary = {}
var fog_map: TileMap = null

func _ready() -> void:
    _setup_tileset()
    if get_parent() != null:
        fog_map = get_parent().get_node_or_null("FogMap")
    if GameState.tiles.is_empty():
        _generate_tiles()
        reveal_area(Vector2i.ZERO, 2)
    else:
        _load_tiles()

func _setup_tileset() -> void:
    if tile_set == null:
        tile_set = TileSet.new()
        tile_set.tile_shape = TileSet.TILE_SHAPE_HEXAGON
        var size := Vector2i(64, 64)
        var colors := {
            "forest": Color(0.1,0.5,0.1),
            "taiga": Color(0.2,0.6,0.2),
            "hill": Color(0.5,0.5,0.5),
            "lake": Color(0,0.3,0.8),
        }
        for name in ["forest","taiga","hill","lake"]:
            var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
            img.fill(colors[name])
            var tex := ImageTexture.create_from_image(img)
            var src := TileSetAtlasSource.new()
            src.texture = tex
            var sid := tile_set.add_source(src)
            _terrain_sources[name] = sid
    else:
        var names := ["forest","taiga","hill","lake"]
        var ids := tile_set.get_source_id_list()
        for i in range(min(names.size(), ids.size())):
            _terrain_sources[names[i]] = ids[i]

func _generate_tiles() -> void:
    for q in range(-radius, radius + 1):
        for r in range(max(-radius, -q - radius), min(radius, -q + radius) + 1):
            var coord := Vector2i(q, r)
            var terrain := _random_terrain()
            var is_hostile := terrain != "lake" and RNG.randf() < 0.09
            var is_wildlife := terrain != "lake" and RNG.randf() < 0.05
            GameState.tiles[coord] = {
                "terrain": terrain,
                "owner": "none",
                "building": null,
                "explored": false,
                "is_hostile": is_hostile,
                "is_wildlife": is_wildlife,
            }
            if is_hostile:
                GameState.camps.append(coord)
            _set_tile(coord)

func _load_tiles() -> void:
    for coord in GameState.tiles.keys():
        _set_tile(coord)

func _set_tile(coord: Vector2i) -> void:
    var data: Dictionary = GameState.tiles.get(coord, {})
    var terrain: String = data.get("terrain", "forest")
    var source_id: int = _terrain_sources.get(terrain, _terrain_sources.get("forest"))
    set_cell(0, coord, source_id, Vector2i.ZERO)
    if fog_map != null:
        if data.get("explored", false):
            fog_map.set_cell(0, coord, -1, Vector2i.ZERO)
        else:
            fog_map.set_cell(0, coord, fog_map.source_id, Vector2i.ZERO)

func _random_terrain() -> String:
    var roll := RNG.randf()
    var acc := 0.0
    for k in terrain_weights.keys():
        acc += terrain_weights[k]
        if roll <= acc:
            return k
    return terrain_weights.keys()[0]

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var local_pos := to_local(event.position)
        var cell := local_to_map(local_pos)
        if GameState.tiles.has(cell):
            var terrain: String = GameState.tiles[cell]["terrain"]
            print("Hex %d,%d terrain %s" % [cell.x, cell.y, terrain])
            emit_signal("tile_clicked", cell)

func reveal_area(center: Vector2i, radius: int = 2) -> void:
    for coord in GameState.tiles.keys():
        if HexUtils.axial_distance(coord, center) <= radius:
            GameState.tiles[coord]["explored"] = true
            if fog_map != null:
                fog_map.set_cell(0, coord, -1, Vector2i.ZERO)

func reveal_all() -> void:
    for coord in GameState.tiles.keys():
        GameState.tiles[coord]["explored"] = true
        if fog_map != null:
            fog_map.set_cell(0, coord, -1, Vector2i.ZERO)

func axial_to_world(qr: Vector2i) -> Vector2:
    var radius := tile_set.tile_size.x / 2.0
    return HexUtils.axial_to_world(qr.x, qr.y, radius)

func world_to_axial(pos: Vector2) -> Vector2i:
    var radius := tile_set.tile_size.x / 2.0
    return HexUtils.world_to_axial(pos, radius)
