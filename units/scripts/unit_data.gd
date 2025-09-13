class_name UnitData
enum Faction { PLAYER, RAIDER, NEUTRAL }

var name: String
var max_hp: int = 10
var hp: int = 10
var move: int = 3
var icon_path: String = "res://units/art/unit_soldier.svg"
var faction: Faction = Faction.PLAYER

func faction_color() -> Color:
    match faction:
        Faction.PLAYER: return Palette.PLAYER
        Faction.RAIDER: return Palette.RAIDER
        _: return Palette.NEUTRAL
