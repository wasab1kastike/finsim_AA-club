extends Node
class_name BattleManager
## HexNavigator is available globally via `class_name`; no preload needed.

var world: Node = null
var hex_map: TileMap = null
var units_root: Node2D = null

func _ready() -> void:
    world = get_parent()
    if world:
        hex_map = world.get_node("TileMap")
        units_root = world.get_node("Units")

func process_tick() -> void:
    if GameState.units.is_empty():
        return
    var changed := false
    for i in range(GameState.units.size()):
        var data: Dictionary = GameState.units[i]
        var path: Array[Vector2i] = HexNavigator.nearest_hostile_path(data.get("pos_qr", Vector2i.ZERO), GameState.tiles)
        if path.size() <= 1:
            if path.size() == 1:
                world._resolve_combat(path[0])
                changed = true
            continue
        var next: Vector2i = path[1]
        var node = _find_unit_node(data.get("id", ""))
        if node:
            node.pos_qr = next
            node.position = hex_map.axial_to_world(next)
        data["pos_qr"] = next
        GameState.units[i] = data
        hex_map.reveal_area(next, 1)
        changed = true
        if path.size() == 2:
            world._resolve_combat(next)
    if changed:
        GameState.save()

func _find_unit_node(uid: String) -> Node:
    if units_root == null:
        return null
    for child in units_root.get_children():
        if child.id == uid:
            return child
    return null
