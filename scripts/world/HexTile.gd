extends Node2D

const Terrain = preload("res://scripts/world/Terrain.gd")

@export var q: int = 0
@export var r: int = 0
@export var terrain: String = Terrain.PLAIN
@export var resource: String = ""

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
    update_sprite()

func update_sprite() -> void:
    sprite.texture = Terrain.get_texture(terrain)
