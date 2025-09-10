extends Object
class_name HexNavigator

const HexUtils = preload("res://scripts/world/HexUtils.gd")

static func nearest_hostile_path(start: Vector2i, tiles: Dictionary) -> Array[Vector2i]:
    if tiles.is_empty():
        return []
    var frontier: Array[Vector2i] = [start]
    var came_from: Dictionary = {start: start}
    while frontier.size() > 0:
        var current: Vector2i = frontier.pop_front()
        var tile: Dictionary = tiles.get(current, {})
        if tile.get("hostile", false):
            var path: Array[Vector2i] = [current]
            while current != start:
                current = came_from[current]
                path.append(current)
            path.reverse()
            return path
        for dir in HexUtils.HEX_DIRS:
            var nxt: Vector2i = current + dir
            if came_from.has(nxt):
                continue
            if !tiles.has(nxt):
                continue
            var t: Dictionary = tiles[nxt]
            if t.get("terrain", "") == "lake":
                continue
            frontier.append(nxt)
            came_from[nxt] = current
    return []
