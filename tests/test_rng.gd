extends Node
var RNGClass = preload("res://autoload/RNG.gd")

func test_seed_generates_same_sequence(res):
    var rng1 = RNGClass.new()
    var rng2 = RNGClass.new()
    rng1.seed_from_string("seed")
    rng2.seed_from_string("seed")
    if rng1.randi() != rng2.randi():
        res.fail("First randi should match for same seed")
    if rng1.randf() != rng2.randf():
        res.fail("First randf should match for same seed")

func test_randf_between_0_and_1(res):
    var rng = RNGClass.new()
    rng.seed_from_string("demo")
    var value = rng.randf()
    if value < 0.0 or value >= 1.0:
        res.fail("randf should be in [0,1)")
