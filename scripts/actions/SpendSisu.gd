extends Action
class_name SpendSisuAction

@export var heal_ratio: float = 0.2

const Resources = preload("res://scripts/core/Resources.gd")
const UnitData = preload("res://scripts/units/UnitData.gd")

func apply() -> bool:
    if not super.apply():
        return false
    for i in range(GameState.units.size()):
        var u: Dictionary = GameState.units[i]
        var path: String = u.get("data_path", "")
        var max_hp: int = int(u.get("hp", 0))
        if path != "":
            var ud: UnitData = load(path) as UnitData
            if ud:
                max_hp = ud.max_health
        var heal: int = int(max_hp * heal_ratio)
        u["hp"] = min(max_hp, int(u.get("hp", 0)) + heal)
        GameState.units[i] = u
    var world: Node = GameState.get_tree().root.get_node_or_null("World")
    if world and world.has_node("Units"):
        for node in world.get_node("Units").get_children():
            if node.has_method("to_dict") and node.has_method("apply_data"):
                var dict = node.to_dict()
                for u in GameState.units:
                    if u.get("id", "") == dict.get("id", ""):
                        node.hp = u.get("hp", node.hp)
                        break
    GameState.clamp_resources()
    return true
