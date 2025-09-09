extends TileMap

const RADIUS := 8
const TERRAIN_WEIGHTS := {
    "forest": 0.40,
    "taiga": 0.35,
    "hill": 0.15,
    "lake": 0.10,
}
const TERRAIN_IDS := {
    "forest": 0,
    "taiga": 1,
    "hill": 2,
    "lake": 3,
}
const TERRAIN_COLORS := {
    "forest": Color(0.2, 0.6, 0.2),
    "taiga": Color(0.1, 0.4, 0.1),
    "hill": Color(0.5, 0.5, 0.5),
    "lake": Color(0.2, 0.2, 0.8),
}

func _ready() -> void:
    _init_tileset()
    GameState.tiles.clear()
    randomize()
    _generate_map()

func _init_tileset() -> void:
    var ts := TileSet.new()
    ts.tile_shape = TileSet.TILE_SHAPE_HEXAGON
    for terrain in TERRAIN_IDS.keys():
        var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
        img.fill(TERRAIN_COLORS[terrain])
        var tex := ImageTexture.create_from_image(img)
        var src := TileSetAtlasSource.new()
        src.texture = tex
        var id := TERRAIN_IDS[terrain]
        ts.add_source(id, src)
    tile_set = ts

func _generate_map() -> void:
    for q in range(-RADIUS, RADIUS + 1):
        var r1 := max(-RADIUS, -q - RADIUS)
        var r2 := min(RADIUS, -q + RADIUS)
        for r in range(r1, r2 + 1):
            var terrain := _pick_terrain()
            var coords := Vector2i(q, r)
            GameState.tiles[coords] = {"q": q, "r": r, "terrain": terrain}
            set_cell(0, coords, TERRAIN_IDS[terrain])

func _pick_terrain() -> String:
    var roll := randf()
    var cumulative := 0.0
    for terrain in TERRAIN_WEIGHTS.keys():
        cumulative += TERRAIN_WEIGHTS[terrain]
        if roll <= cumulative:
            return terrain
    return "forest"
