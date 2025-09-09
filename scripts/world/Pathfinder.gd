extends Resource
class_name Pathfinder

static func axial_neighbors(hex: Vector2i) -> Array[Vector2i]:
    var directions := [
        Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
        Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
    ]
    var result: Array[Vector2i] = []
    for dir in directions:
        result.append(hex + dir)
    return result

static func hex_distance(a: Vector2i, b: Vector2i) -> int:
    var ac := Vector3i(a.x, a.y, -a.x - a.y)
    var bc := Vector3i(b.x, b.y, -b.x - b.y)
    return max(abs(ac.x - bc.x), abs(ac.y - bc.y), abs(ac.z - bc.z))

static func a_star(start: Vector2i, goal: Vector2i, is_passable: Callable) -> Array[Vector2i]:
    var open_set: Array[Vector2i] = [start]
    var came_from: Dictionary = {}
    var g_score: Dictionary = {start: 0}
    var f_score: Dictionary = {start: hex_distance(start, goal)}
    while not open_set.is_empty():
        open_set.sort_custom(func(a, b): return f_score[a] < f_score[b])
        var current: Vector2i = open_set[0]
        if current == goal:
            return _reconstruct_path(came_from, current)
        open_set.remove_at(0)
        for neighbor in axial_neighbors(current):
            if not is_passable.call(neighbor):
                continue
            var tentative := g_score[current] + 1
            if not g_score.has(neighbor) or tentative < g_score[neighbor]:
                came_from[neighbor] = current
                g_score[neighbor] = tentative
                f_score[neighbor] = tentative + hex_distance(neighbor, goal)
                if neighbor not in open_set:
                    open_set.append(neighbor)
    return []

static func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
    var total: Array[Vector2i] = [current]
    while came_from.has(current):
        current = came_from[current]
        total.insert(0, current)
    return total
