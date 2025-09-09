extends Node2D
class_name BattleManager

@onready var map_generator: Node = get_parent().get_node("MapGenerator")
var unit_scene: PackedScene = preload("res://scenes/battle/BattleUnit.tscn")
var units: Array[BattleUnit] = []

func spawn_unit(unit_res: Unit, hex: Vector2i, team: int) -> void:
    var inst: BattleUnit = unit_scene.instantiate()
    inst.unit = unit_res.duplicate(true)
    inst.team = team
    add_child(inst)
    inst.set_hex_pos(hex, map_generator)
    inst.apply_team_color()
    units.append(inst)

func _on_tick(_time: float) -> void:
    _update_battle()

func _update_battle() -> void:
    for unit in units.duplicate():
        if not unit.is_alive():
            continue
        var target = _find_target(unit)
        if target is BattleUnit:
            var dist = HexNavigator.hex_distance(unit.hex_pos, target.hex_pos)
            if dist <= 1:
                unit.unit.deal_damage(target.unit)
                if not target.unit.is_alive():
                    target.queue_free()
                    units.erase(target)
            else:
                var step = HexNavigator.next_step(unit.hex_pos, target.hex_pos)
                unit.set_hex_pos(step, map_generator)
        elif target is Vector2i:
            var dist2 = HexNavigator.hex_distance(unit.hex_pos, target)
            if dist2 <= 1:
                var world = get_parent()
                if world.tile_occupants.has(target):
                    world.tile_occupants.erase(target)
            else:
                var step2 = HexNavigator.next_step(unit.hex_pos, target)
                unit.set_hex_pos(step2, map_generator)

func _find_target(unit: BattleUnit):
    var best_unit: BattleUnit = null
    var best_dist := 1_000_000
    for other in units:
        if other == unit or other.team == unit.team or not other.is_alive():
            continue
        var dist = HexNavigator.hex_distance(unit.hex_pos, other.hex_pos)
        if dist < best_dist:
            best_dist = dist
            best_unit = other
    if best_unit != null:
        return best_unit
    var world = get_parent()
    var best_tile: Vector2i = Vector2i.ZERO
    var best_tile_dist := best_dist
    for tile in world.tile_occupants.keys():
        var dist2 = HexNavigator.hex_distance(unit.hex_pos, tile)
        if dist2 < best_tile_dist:
            best_tile_dist = dist2
            best_tile = tile
    if best_tile_dist < 1_000_000:
        return best_tile
    return null
