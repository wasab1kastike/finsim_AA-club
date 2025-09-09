extends Node
class_name HexNavigator

const DIRECTIONS: Array[Vector2i] = [
    Vector2i(1, 0),
    Vector2i(1, -1),
    Vector2i(0, -1),
    Vector2i(-1, 0),
    Vector2i(-1, 1),
    Vector2i(0, 1),
]

static func hex_distance(a: Vector2i, b: Vector2i) -> int:
    var dq := a.x - b.x
    var dr := a.y - b.y
    return int((abs(dq) + abs(dq + dr) + abs(dr)) / 2)

static func next_step(start: Vector2i, target: Vector2i) -> Vector2i:
    var best := start
    var best_dist := hex_distance(start, target)
    for dir in DIRECTIONS:
        var cand := start + dir
        var dist := hex_distance(cand, target)
        if dist < best_dist:
            best_dist = dist
            best = cand
    return best
