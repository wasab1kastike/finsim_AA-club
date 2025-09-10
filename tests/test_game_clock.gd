extends Node
var GameClock = preload("res://autoload/GameClock.gd")

func test_process_increments_time_when_running(res):
    var clock = GameClock.new()
    clock.start()
    clock._process(0.5)
    if clock.time != 0.5:
        res.fail("Time after first process")
    clock._process(0.25)
    if clock.time != 0.75:
        res.fail("Time after second process")

func test_process_no_increment_when_stopped(res):
    var clock = GameClock.new()
    clock.stop()
    clock._process(1.0)
    if clock.time != 0.0:
        res.fail("Time should not advance when stopped")
