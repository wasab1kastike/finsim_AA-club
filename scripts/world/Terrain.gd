class_name Terrain
extends RefCounted

const WATER := "water"
const MOUNTAIN := "mountain"
const GRASS := "grass"
const TAIGA := "taiga"
const TOWN := "town"
const RUINS := "ruins"
const PLAIN := "plain"

const _TEXTURES := {
    WATER: preload("res://assets/tiles/lake.svg"),
    MOUNTAIN: preload("res://assets/tiles/hill.svg"),
    GRASS: preload("res://assets/tiles/forest.svg"),
    TAIGA: preload("res://assets/tiles/taiga.svg"),
    TOWN: preload("res://assets/tiles/town.svg"),
    RUINS: preload("res://assets/tiles/ruins.svg"),
    PLAIN: preload("res://assets/tiles/forest.svg"),
}

static func get_texture(t: String) -> Texture2D:
    return _TEXTURES.get(t, _TEXTURES[GRASS])

