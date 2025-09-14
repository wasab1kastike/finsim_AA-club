extends Node

const PolicyBase := preload("res://scripts/policies/Policy.gd")

func test_at_least_one_policy(res) -> void:
    var dir := "res://resources/policies"
    var count := 0
    for file in DirAccess.get_files_at(dir):
        if file.get_extension() == "tres":
            var path := "%s/%s" % [dir, file]
            var pol := load(path)
            if pol != null and pol is PolicyBase and pol.name != "":
                count += 1
    if count == 0:
        res.fail("no valid policies found in %s" % dir)
