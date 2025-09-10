extends Node

@onready var world: Node = $World
@onready var reveal_btn: Button = $DebugUI/RevealAllButton
@onready var spawn_btn: Button = $DebugUI/SpawnButton

func _ready() -> void:
    if world.has_signal("tile_clicked"):
        world.tile_clicked.connect(_on_tile_clicked)
    reveal_btn.pressed.connect(_on_reveal_all)
    spawn_btn.pressed.connect(_on_spawn)

func _on_tile_clicked(qr: Vector2i) -> void:
    var data: Dictionary = GameState.tiles.get(qr, {})
    print("Main: clicked %s terrain %s" % [qr, data.get("terrain", "")])

func _on_reveal_all() -> void:
    world.reveal_all()

func _on_spawn() -> void:
    world.spawn_unit_at_center()
