extends Object
class_name Pathing
const HexUtils = preload("res://scripts/world/HexUtils.gd")

static func bfs_path(start: Vector2i, goal: Vector2i, passable: Callable) -> Array[Vector2i]:
    if start == goal:
        return [start]
    var frontier: Array[Vector2i] = [start]
    var head := 0
    var came_from: Dictionary = {start: start}
    while head < frontier.size():
        var current: Vector2i = frontier[head]
        head += 1
        if current == goal:
            break
        for dir in HexUtils.HEX_DIRS:
            var nxt: Vector2i = current + dir
            if !passable.call(nxt):
                continue
            if !came_from.has(nxt):
                frontier.append(nxt)
                came_from[nxt] = current
    if !came_from.has(goal):
        return []
    var path: Array[Vector2i] = [goal]
    var node: Vector2i = goal
    while node != start:
        node = came_from[node]
        path.append(node)
    path.reverse()
    return path
