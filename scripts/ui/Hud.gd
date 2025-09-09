extends CanvasLayer

signal start_pressed
signal pause_pressed

@onready var resources_label: Label = $ResourcesLabel
@onready var start_button: Button = $StartButton
@onready var pause_button: Button = $PauseButton
@onready var clock_label: Label = $ClockLabel

func _ready() -> void:
    start_button.pressed.connect(func(): start_pressed.emit())
    pause_button.pressed.connect(func(): pause_pressed.emit())

func update_resources(resources: Dictionary) -> void:
    var parts: PackedStringArray = []
    for key in resources.keys().sorted():
        parts.append("%s: %d" % [key.capitalize(), int(resources[key])])
    resources_label.text = " ".join(parts)

func update_clock(time: float) -> void:
    clock_label.text = "Time: %.2f" % time
