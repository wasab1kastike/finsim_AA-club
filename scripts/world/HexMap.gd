extends TileMap
class_name HexMap

@export var radius := 8
@export var terrain_weights := {"forest":0.4,"taiga":0.35,"hill":0.15,"lake":0.1}

signal tile_clicked(qr:Vector2i)

const HEX_DIRS = [Vector2i(1,0), Vector2i(1,-1), Vector2i(0,-1), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,1)]

var _terrain_sources: Dictionary = {}
var _fog_source_id := -1
var _building_sources: Dictionary = {}
const BuildingIcons := preload("res://scripts/world/BuildingIcons.gd")

func _ready() -> void:
    _setup_tileset()
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
            "fog": Color(0,0,0,0.75),
        }
        for name in ["forest","taiga","hill","lake","fog"]:
            var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
            img.fill(colors[name])
            var tex := ImageTexture.create_from_image(img)
            var src := TileSetAtlasSource.new()
            src.texture = tex
            var sid := tile_set.add_source(src)
            if name == "fog":
                _fog_source_id = sid
            else:
                _terrain_sources[name] = sid
        # load building icons from base64 strings
        for name in ["sauna", "farm", "lumber", "mine", "school"]:
            var b64: String = BuildingIcons.ICONS.get(name, "")
            if b64 != "":
                var img48 := Image.new()
                var data: PackedByteArray = PackedByteArray.from_base64(b64)
                if img48.load_png_from_buffer(data) == OK:
                    var img64 := Image.create(64, 64, false, Image.FORMAT_RGBA8)
                    img64.fill(Color(0,0,0,0))
                    img64.blit_rect(img48, Rect2i(Vector2i.ZERO, img48.get_size()), Vector2i(8,8))
                    var tex := ImageTexture.create_from_image(img64)
                    var src := TileSetAtlasSource.new()
                    src.texture = tex
                    var sid := tile_set.add_source(src)
                    _building_sources[name] = sid
    else:
        var terrain_names := ["forest","taiga","hill","lake"]
        var ids := tile_set.get_source_id_list()
        for i in range(min(terrain_names.size(), ids.size())):
            _terrain_sources[terrain_names[i]] = ids[i]
        if ids.size() > terrain_names.size():
            _fog_source_id = ids[terrain_names.size()]
        var building_names := ["sauna", "farm", "lumber", "mine", "school"]
        for j in range(building_names.size()):
            var idx := terrain_names.size() + 1 + j
            if ids.size() > idx:
                _building_sources[building_names[j]] = ids[idx]
    self.layers = max(self.layers, 3)
    set_layer_z_index(2, 1)

func _generate_tiles() -> void:
    var rng := RandomNumberGenerator.new()
    for q in range(-radius, radius + 1):
        for r in range(max(-radius, -q - radius), min(radius, -q + radius) + 1):
            var terrain := _random_terrain(rng)
            var building := null
            if q == 0 and r == 0:
                building = "sauna"
            GameState.tiles[Vector2i(q, r)] = {
                "terrain": terrain,
                "owner": "none",
                "building": building,
                "explored": false,
            }
            _set_tile(Vector2i(q, r))

func _load_tiles() -> void:
    for coord in GameState.tiles.keys():
        _set_tile(coord)

func _set_tile(coord: Vector2i) -> void:
    var data: Dictionary = GameState.tiles.get(coord, {})
    var terrain: String = data.get("terrain", "forest")
    var source_id: int = _terrain_sources.get(terrain, _terrain_sources.get("forest"))
    set_cell(0, coord, source_id, Vector2i.ZERO)
    if data.get("explored", false):
        set_cell(1, coord, -1, Vector2i.ZERO)
    else:
        set_cell(1, coord, _fog_source_id, Vector2i.ZERO)
    var b: String = data.get("building", null)
    if b and _building_sources.has(b):
        var sid: int = _building_sources[b]
        set_cell(2, coord, sid, Vector2i.ZERO)
    else:
        set_cell(2, coord, -1, Vector2i.ZERO)

func _random_terrain(rng: RandomNumberGenerator) -> String:
    var roll := rng.randf()
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

static func axial_neighbors(q: int, r: int) -> Array[Vector2i]:
    var res: Array[Vector2i] = []
    for d in HEX_DIRS:
        res.append(Vector2i(q + d.x, r + d.y))
    return res

static func axial_distance(a: Vector2i, b: Vector2i) -> int:
    var dq := a.x - b.x
    var dr := a.y - b.y
    var ds := -dq - dr
    return max(abs(dq), abs(dr), abs(ds))

func reveal_area(center: Vector2i, radius: int = 2) -> void:
    for coord in GameState.tiles.keys():
        if axial_distance(coord, center) <= radius:
            GameState.tiles[coord]["explored"] = true
            set_cell(1, coord, -1, Vector2i.ZERO)

func reveal_all() -> void:
    for coord in GameState.tiles.keys():
        GameState.tiles[coord]["explored"] = true
        set_cell(1, coord, -1, Vector2i.ZERO)

func axial_to_world(qr: Vector2i) -> Vector2:
    return to_global(map_to_local(qr))

func world_to_axial(pos: Vector2) -> Vector2i:
    return local_to_map(to_local(pos))
