extends Node2D

@export var q: int = 0
@export var r: int = 0
@export var terrain: String = "plain"
@export var resource: String = ""

@onready var sprite: Sprite2D = $Sprite

const TERRAIN_TEXTURES := {
    "water": preload("res://assets/tiles/lake.svg"),
    "mountain": preload("res://assets/tiles/hill.svg"),
    "grass": preload("res://assets/tiles/forest.svg"),
}

func _ready() -> void:
    update_sprite()

func update_sprite() -> void:
    var tex: Texture2D = TERRAIN_TEXTURES.get(terrain, TERRAIN_TEXTURES["grass"])
    sprite.texture = tex
