extends Node2D

@onready var hud: CanvasLayer = $Hud
@onready var game_clock: Node = $GameClock

var money: int = 0
var ammo: int = 0

func _ready() -> void:
    hud.start_pressed.connect(game_clock.start)
    hud.pause_pressed.connect(game_clock.stop)
    game_clock.tick.connect(hud.update_clock)
    hud.update_resources(money, ammo)
