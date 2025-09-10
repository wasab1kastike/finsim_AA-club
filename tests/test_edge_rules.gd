extends Node

const Resources = preload("res://scripts/core/Resources.gd")

func _remove_save(gs) -> void:
    if FileAccess.file_exists(gs.SAVE_PATH):
        DirAccess.remove_absolute(gs.SAVE_PATH)

func test_raider_reaches_origin(res) -> void:
    var gs = Engine.get_main_loop().root.get_node("GameState")
    _remove_save(gs)
    var orig = gs.res.duplicate()
    gs.tiles.clear()
    gs.res[Resources.MORALE] = 100.0
    var tdata = {"hostiles":[{"hp":10,"atk":1,"def":0}]}
    gs.tiles[Vector2i.ZERO] = tdata
    gs._on_tick()
    if int(gs.res[Resources.MORALE]) != 95:
        res.fail("Morale not reduced by raider")
    var tile = gs.tiles.get(Vector2i.ZERO, {})
    if tile.get("hostiles", []) != []:
        res.fail("Raider not despawned")
    gs.res = orig
    gs.tiles.clear()
    _remove_save(gs)

func test_sisu_cap(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    _remove_save(gs)
    var orig = gs.res.duplicate()
    gs.res[Resources.SISU] = 9.0
    gs.units.clear()
    gs.tiles.clear()
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)
    world.spawn_unit_at_center()
    world.spawn_unit_at_center()
    var target := Vector2i(1, 0)
    var tdata = {"terrain":"forest","owner":"enemy","hostiles":[{"hp":200,"atk":20,"def":5}]}
    gs.tiles[target] = tdata
    world._on_tile_clicked(target)
    if gs.res[Resources.SISU] > 10.0:
        res.fail("Sisu cap exceeded")
    world.queue_free()
    gs.res = orig
    gs.units.clear()
    gs.tiles.clear()
    _remove_save(gs)

func test_spend_sisu_heal(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    _remove_save(gs)
    var orig = gs.res.duplicate()
    gs.res[Resources.SISU] = 1.0
    gs.units.clear()
    gs.tiles.clear()
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)
    world.spawn_unit_at_center()
    for u in gs.units:
        u["hp"] = int(u["hp"] / 2)
    for child in world.units_root.get_children():
        child.hp = int(child.hp / 2)
    if not world.spend_sisu_heal():
        res.fail("Spend Sisu failed")
    var new_hp = gs.units[0]["hp"]
    if new_hp <= 60:
        res.fail("Unit not healed")
    if gs.res[Resources.SISU] != 0.0:
        res.fail("Sisu not spent")
    world.queue_free()
    gs.res = orig
    gs.units.clear()
    gs.tiles.clear()
    _remove_save(gs)
