extends Node
var Building = preload("res://scripts/core/Building.gd")

func test_upgrade_increments_level(res):
    var building = Building.new()
    building.level = 1
    building.upgrade()
    if building.level != 2:
        res.fail("Level after upgrade should be 2")

func test_getters_return_values(res):
    var building = Building.new()
    building.construction_cost = {Resources.KULTA: 100}
    building.production_rates = {Resources.HALOT: 10}
    if building.get_construction_cost().get(Resources.KULTA, 0) != 100:
        res.fail("Construction cost incorrect")
    if building.get_production_rates().get(Resources.HALOT, 0) != 10:
        res.fail("Production rate incorrect")
