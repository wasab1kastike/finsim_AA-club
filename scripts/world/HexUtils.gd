extends Object
class_name HexUtils

const HEX_DIRS = [
    Vector2i(1,0),
    Vector2i(1,-1),
    Vector2i(0,-1),
    Vector2i(-1,0),
    Vector2i(-1,1),
    Vector2i(0,1),
]

const RNG = preload("res://autoload/RNG.gd")

static func axial_to_world(q: int, r: int, hex_radius: float) -> Vector2:
    var x := hex_radius * sqrt(3.0) * (q + r / 2.0)
    var y := hex_radius * 1.5 * r
    return Vector2(x, y)

static func world_to_axial(pos: Vector2, hex_radius: float) -> Vector2i:
    var q := (sqrt(3.0) / 3.0 * pos.x - pos.y / 3.0) / hex_radius
    var r := (2.0 / 3.0 * pos.y) / hex_radius
    return Vector2i(int(round(q)), int(round(r)))
