extends Node

var Pathing = preload("res://scripts/world/Pathing.gd")
var HexUtils = preload("res://scripts/world/HexUtils.gd")

func _naive_bfs(start: Vector2i, goal: Vector2i, passable: Callable) -> Array[Vector2i]:
    if start == goal:
        return [start]
    var frontier: Array[Vector2i] = [start]
    var came_from: Dictionary = {start: start}
    while frontier.size() > 0:
        var current: Vector2i = frontier.pop_front()
        if current == goal:
            break
        for dir in HexUtils.HEX_DIRS:
            var nxt: Vector2i = current + dir
            if !passable.call(nxt):
                continue
            if !came_from.has(nxt):
                frontier.append(nxt)
                came_from[nxt] = current
    if !came_from.has(goal):
        return []
    var path: Array[Vector2i] = [goal]
    var node: Vector2i = goal
    while node != start:
        node = came_from[node]
        path.append(node)
    path.reverse()
    return path

func test_bfs_performance(res) -> void:
    var start := Vector2i(0, 0)
    var goal := Vector2i(40, 0)
    var passable := func(cell: Vector2i) -> bool:
        return true
    var queue_time: int = 0
    var array_time: int = 0
    var iterations := 3
    for i in range(iterations):
        var t0: int = Time.get_ticks_usec()
        Pathing.bfs_path(start, goal, passable)
        queue_time += Time.get_ticks_usec() - t0
    for i in range(iterations):
        var t1: int = Time.get_ticks_usec()
        _naive_bfs(start, goal, passable)
        array_time += Time.get_ticks_usec() - t1
    if queue_time * 5 >= array_time * 6:
        res.fail("Queue BFS %dus vs array BFS %dus" % [queue_time, array_time])
