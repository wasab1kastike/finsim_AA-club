extends Node
class_name AutoResolve

static func resolve(friendly: Array, enemies: Array, terrain: String) -> Dictionary:
    var rounds: int = 5 + int(RNG.randf() * 16.0)
    var atk_mod := 1.0
    var def_mod := 1.0
    if terrain == "hill":
        atk_mod += 0.1
    elif terrain == "forest":
        def_mod += 0.2
    for _i in range(rounds):
        if friendly.is_empty() or enemies.is_empty():
            break
        # attackers strike defenders
        for j in range(friendly.size()):
            if enemies.is_empty():
                break
            var idx := int(RNG.randf() * enemies.size())
            var a: Dictionary = friendly[j]
            var d: Dictionary = enemies[idx]
            var dmg := max(1, int(round(a.get("atk", 0) * atk_mod - d.get("def", 0) * def_mod)))
            d["hp"] = d.get("hp", 0) - dmg
            if d["hp"] <= 0:
                enemies.remove_at(idx)
            else:
                enemies[idx] = d
        # defenders strike back
        for j in range(enemies.size()):
            if friendly.is_empty():
                break
            var idx := int(RNG.randf() * friendly.size())
            var a2: Dictionary = enemies[j]
            var d2: Dictionary = friendly[idx]
            var dmg2 := max(1, int(round(a2.get("atk", 0) * atk_mod - d2.get("def", 0) * def_mod)))
            d2["hp"] = d2.get("hp", 0) - dmg2
            if d2["hp"] <= 0:
                friendly.remove_at(idx)
            else:
                friendly[idx] = d2
    var winner := "draw"
    if enemies.is_empty() and not friendly.is_empty():
        winner = "friendly"
    elif friendly.is_empty() and not enemies.is_empty():
        winner = "enemy"
    elif not friendly.is_empty() and not enemies.is_empty():
        var fhp := 0
        for f in friendly:
            fhp += f.get("hp", 0)
        var ehp := 0
        for e in enemies:
            ehp += e.get("hp", 0)
        winner = "friendly" if fhp >= ehp else "enemy"
    return {
        "friendly": friendly,
        "enemies": enemies,
        "winner": winner,
    }
