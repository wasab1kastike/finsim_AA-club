extends Node

const Building = preload("res://scripts/core/Building.gd")
const TutorialOverlay = preload("res://scenes/ui/TutorialOverlay.tscn")

@onready var world: Node = $World
@onready var hud: CanvasLayer = $Hud
@onready var reveal_btn: Button = $DebugUI/RevealAllButton
@onready var spawn_btn: Button = $DebugUI/SpawnButton

var _selected_building: Building = null
var _last_clicked: Vector2i = Vector2i.ZERO
var _buildings: Dictionary = {}
var _tutorial_overlay: Node = null

func _ready() -> void:
    for file in DirAccess.get_files_at("res://resources/buildings"):
        if file.get_extension() == "tres":
            var b: Building = load("res://resources/buildings/%s" % file)
            _buildings[b.name] = b
    if world.has_signal("tile_clicked"):
        world.tile_clicked.connect(_on_tile_clicked)
    hud.start_pressed.connect(GameClock.start)
    hud.pause_pressed.connect(GameClock.stop)
    hud.build_pressed.connect(_on_build_pressed)
    hud.building_selected.connect(_on_building_selected)
    GameClock.tick.connect(_on_game_tick)
    reveal_btn.pressed.connect(_on_reveal_all)
    spawn_btn.pressed.connect(_on_spawn)
    hud.update_resources(GameState.res)
    if not GameState.tutorial_done:
        start_tutorial()

func _on_game_tick() -> void:
    hud.update_resources(GameState.res)

func _on_building_selected(name: String) -> void:
    _selected_building = _buildings.get(name, null)

func _on_build_pressed() -> void:
    if _selected_building == null:
        return
    if not GameState.tiles.has(_last_clicked):
        return
    var tile: Dictionary = GameState.tiles[_last_clicked]
    if tile.get("building") != null:
        return
    var cost: Dictionary = _selected_building.get_construction_cost()
    for res in cost.keys():
        if GameState.res.get(res, 0.0) < cost[res]:
            return
    for res in cost.keys():
        GameState.res[res] = GameState.res.get(res, 0.0) - cost[res]
    tile["building"] = _selected_building.resource_path.get_file().get_basename()
    GameState.tiles[_last_clicked] = tile
    hud.update_tile(_last_clicked, _selected_building)
    hud.update_resources(GameState.res)

func _on_tile_clicked(qr: Vector2i) -> void:
    _last_clicked = qr
    var data: Dictionary = GameState.tiles.get(qr, {})
    var bname = data.get("building", "")
    var building = _buildings.get(bname, null)
    hud.update_tile(qr, building)
    hud.show_building_info(building)
    print("Main: clicked %s terrain %s" % [qr, data.get("terrain", "")])

func _on_reveal_all() -> void:
    world.reveal_all()

func _on_spawn() -> void:
    world.spawn_unit_at_center()

func start_tutorial() -> void:
    if _tutorial_overlay:
        _tutorial_overlay.queue_free()
    _tutorial_overlay = TutorialOverlay.instantiate()
    add_child(_tutorial_overlay)
    _tutorial_overlay.tutorial_completed.connect(_on_tutorial_completed)

func _on_tutorial_completed() -> void:
    GameState.tutorial_done = true
    GameState.save()
    _tutorial_overlay = null
