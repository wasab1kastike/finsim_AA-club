extends Node2D
class_name HexMap

@export var radius := 8
@export var terrain_weights := {"forest":0.4,"taiga":0.35,"hill":0.15,"lake":0.1}

signal tile_clicked(qr:Vector2i)

const HexUtils = preload("res://scripts/world/HexUtils.gd")

@onready var grid: TileMap = $TileMap
@onready var terrain: TileMapLayer = $TileMap/Terrain
@onready var buildings: TileMapLayer = $TileMap/Buildings
@onready var fog: FogMap = $TileMap/Fog

var _terrain_sources: Dictionary = {}
var _building_sources: Dictionary = {}
var _markers: Dictionary = {}
var marker_root: Node2D
var _state: Node
var _rng: Node

func _ensure_singletons() -> void:
    var root := Engine.get_main_loop().root
    if _state == null:
        _state = root.get_node("GameState")
    if _rng == null:
        _rng = root.get_node("RNG")

func _ready() -> void:
    _setup_tileset()
    marker_root = Node2D.new()
    add_child(marker_root)
    _ensure_singletons()
    if _state.tiles.is_empty():
        _generate_tiles()
        reveal_area(Vector2i.ZERO, 2)
    else:
        _draw_from_saved(_state.tiles)

func _setup_tileset() -> void:
    if grid.tile_set == null:
        grid.tile_set = TileSet.new()
        grid.tile_set.tile_shape = TileSet.TILE_SHAPE_HEXAGON
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
            var sid := grid.tile_set.add_source(src)
            _terrain_sources[name] = sid
    else:
        var names := ["forest","taiga","hill","lake"]
        var ids: Array[int] = grid.tile_set.get_source_id_list()
        for i in range(min(names.size(), ids.size())):
            _terrain_sources[names[i]] = ids[i]
    _setup_building_tiles()

func _setup_building_tiles() -> void:
    var size := grid.tile_set.tile_size
    var colors := {
        "sauna": Color(0.8, 0.5, 0.3),
        "farm": Color(0.7, 0.9, 0.4),
        "lumber": Color(0.3, 0.7, 0.2),
        "mine": Color(0.5, 0.5, 0.5),
        "school": Color(0.3, 0.5, 0.9),
    }
    for name in colors.keys():
        var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
        img.fill(colors[name])
        var inner := Image.create(24, 24, false, Image.FORMAT_RGBA8)
        inner.fill(Color.WHITE)
        img.blit_rect(inner, Rect2i(Vector2i.ZERO, inner.get_size()), Vector2i(12, 12))
        var big := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
        big.fill(Color(0, 0, 0, 0))
        var off := Vector2i((size.x - img.get_width()) / 2, (size.y - img.get_height()) / 2)
        big.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), off)
        var tex := ImageTexture.create_from_image(big)
        var src := TileSetAtlasSource.new()
        src.texture = tex
        src.texture_region_size = size
        var sid := grid.tile_set.add_source(src)
        _building_sources[name] = sid

func _generate_tiles() -> void:
    _ensure_singletons()
    for q in range(-radius, radius + 1):
        for r in range(max(-radius, -q - radius), min(radius, -q + radius) + 1):
            var terrain := _random_terrain()
            var is_hostile: bool = terrain != "lake" and _rng.randf() < 0.09
            var is_wildlife: bool = terrain != "lake" and _rng.randf() < 0.05
            var building: String = ""
            if q == 0 and r == 0:
                building = "sauna"
            var coord := Vector2i(q, r)
            _state.tiles[coord] = {
                "terrain": terrain,
                "owner": "none",
                "building": building,
                "explored": false,
                "hostile": is_hostile,
                "wildlife": is_wildlife,
            }
            _state.set_hostile(coord, is_hostile)
            _set_tile(coord)

func _draw_from_saved(tiles: Dictionary) -> void:
    _ensure_singletons()
    for coord in tiles.keys():
        _set_tile(coord)

func _set_tile(coord: Vector2i) -> void:
    _ensure_singletons()
    var data: Dictionary = _state.tiles.get(coord, {})
    var terrain: String = data.get("terrain", "forest")
    var source_id: int = _terrain_sources.get(terrain, _terrain_sources.get("forest"))
    terrain.set_cell(coord, source_id)
    var bname: String = data.get("building", "")
    if bname != "" and _building_sources.has(bname):
        buildings.set_cell(coord, _building_sources[bname])
    else:
        buildings.erase_cell(coord)
    var marker: Node2D = _markers.get(coord, null)
    if data.get("hostile", false):
        if marker == null:
            marker = preload("res://scripts/world/HostileMarker.gd").new()
            marker.position = axial_to_world(coord)
            marker.z_index = 10
            marker_root.add_child(marker)
            _markers[coord] = marker
    elif marker != null:
        marker.queue_free()
        _markers.erase(coord)
    if fog != null:
        if data.get("explored", false):
            fog.erase_cell(coord)
        else:
            fog.set_cell(coord, fog.source_id)

func _random_terrain() -> String:
    _ensure_singletons()
    var roll: float = _rng.randf()
    var acc := 0.0
    for k in terrain_weights.keys():
        acc += terrain_weights[k]
        if roll <= acc:
            return k
    return terrain_weights.keys()[0]

func _unhandled_input(event: InputEvent) -> void:
    _ensure_singletons()
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var local_pos := to_local(event.position)
        var cell := grid.local_to_map(local_pos)
        if _state.tiles.has(cell):
            var terrain: String = _state.tiles[cell]["terrain"]
            print("Hex %d,%d terrain %s" % [cell.x, cell.y, terrain])
            emit_signal("tile_clicked", cell)

func reveal_area(center: Vector2i, radius: int = 2) -> void:
    _ensure_singletons()
    for coord in _state.tiles.keys():
        if HexUtils.axial_distance(coord, center) <= radius:
            _state.tiles[coord]["explored"] = true
            if fog != null:
                fog.erase_cell(coord)

func reveal_all() -> void:
    _ensure_singletons()
    for coord in _state.tiles.keys():
        _state.tiles[coord]["explored"] = true
        if fog != null:
            fog.erase_cell(coord)

func axial_to_world(qr: Vector2i) -> Vector2:
    var radius := grid.tile_set.tile_size.x / 2.0
    return HexUtils.axial_to_world(qr.x, qr.y, radius)

func world_to_axial(pos: Vector2) -> Vector2i:
    var radius := grid.tile_set.tile_size.x / 2.0
    return HexUtils.world_to_axial(pos, radius)

func map_to_pos(cell: Vector2i) -> Vector2:
    return grid.map_to_local(cell)
