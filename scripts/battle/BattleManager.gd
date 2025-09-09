extends Node
class_name BattleManager

var active_units: Array[Unit] = []

func spawn_unit(unit_res: Resource) -> Unit:
    var unit: Unit = unit_res.duplicate(true) as Unit
    active_units.append(unit)
    return unit
