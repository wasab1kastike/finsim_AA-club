extends Node

var Pathing = preload("res://scripts/world/Pathing.gd")

func test_bfs_path(res) -> void:
    var start := Vector2i(0, 0)
    var goal := Vector2i(2, 0)
    var blocked := {Vector2i(1, 0): true}
    var passable := func(cell: Vector2i) -> bool:
        return !blocked.has(cell)
    var path := Pathing.bfs_path(start, goal, passable)
    var expected := [Vector2i(0,0), Vector2i(1,-1), Vector2i(2,-1), Vector2i(2,0)]
    if path.size() != expected.size():
        res.fail("Expected path length %d, got %d" % [expected.size(), path.size()])
        return
    for i in range(path.size()):
        if path[i] != expected[i]:
            res.fail("Mismatch at %d" % i)
            break
