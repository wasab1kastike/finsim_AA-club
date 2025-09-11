extends Panel
class_name InfoBox


@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var cost_label: Label = $VBoxContainer/CostLabel

func show_building(building: Building) -> void:
    if building == null:
        hide()
        return
    name_label.text = building.name
    var desc_parts: PackedStringArray = []
    for key in building.production_rates.keys():
        desc_parts.append("%s: %s" % [key.capitalize(), str(building.production_rates[key])])
    if desc_parts.size() > 0:
        description_label.text = "Produces: " + ", ".join(desc_parts)
    else:
        description_label.text = ""
    var cost_parts: PackedStringArray = []
    var cost: Dictionary = building.get_construction_cost()
    for key in cost.keys():
        cost_parts.append("%s: %s" % [key.capitalize(), str(cost[key])])
    cost_label.text = ("Cost: " + ", ".join(cost_parts)) if cost_parts.size() > 0 else ""
    show()
