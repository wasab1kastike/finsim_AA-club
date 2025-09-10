extends Node

func test_map_to_pos(res) -> void:
    var tree = Engine.get_main_loop()
    var gs = tree.root.get_node("GameState")
    gs.tiles.clear()
    var world_scene: PackedScene = load("res://scenes/world/World.tscn")
    var world = world_scene.instantiate()
    tree.root.add_child(world)
    var pos: Vector2 = world.get_node("TileMap").map_to_pos(Vector2i.ZERO)
    if not pos.is_finite():
        res.fail("map_to_pos returned non-finite")
    world.queue_free()
    gs.tiles.clear()
