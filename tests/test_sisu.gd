extends Node

func _remove_save(gs) -> void:
    if FileAccess.file_exists(gs.SAVE_PATH):
        DirAccess.remove_absolute(gs.SAVE_PATH)

func _cleanup(world, sisu, gs, orig) -> void:
    world.queue_free()
    sisu.queue_free()
    gs.res = orig
    gs.units.clear()
    gs.tiles.clear()
    _remove_save(gs)

func test_spend_sisu_heals(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    _remove_save(gs)
    var orig = gs.res.duplicate()
    gs.units.clear()
    gs.tiles.clear()
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)
    for i in range(3):
        world.spawn_unit_at_center()
        var unit = world.units_root.get_child(i)
        unit.hp = int(unit.unit_data.max_health * 0.5)
        gs.units[i]["hp"] = unit.hp
    gs.res[Resources.SISU] = 5.0
    var SisuSystem = load("res://scripts/systems/SisuSystem.gd")
    var sisu = SisuSystem.new()
    sisu.world = world
    tree.root.add_child(sisu)
    if not sisu.spend():
        res.fail("Spend failed")
        _cleanup(world, sisu, gs, orig)
        return
    for unit in world.units_root.get_children():
        var max_hp = unit.unit_data.max_health
        var expected = int(max_hp * 0.7)
        if unit.hp != expected:
            res.fail("Unit not healed")
            _cleanup(world, sisu, gs, orig)
            return
    if gs.res[Resources.SISU] != 0.0:
        res.fail("Sisu not deducted")
        _cleanup(world, sisu, gs, orig)
        return
    if sisu.cooldown_ticks_remaining <= 0:
        res.fail("Cooldown not active")
        _cleanup(world, sisu, gs, orig)
        return
    _cleanup(world, sisu, gs, orig)
