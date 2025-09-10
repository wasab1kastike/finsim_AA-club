extends CanvasLayer
class_name TutorialOverlay

signal tutorial_completed

@onready var text_label: RichTextLabel = $Panel/Text
@onready var next_button: Button = $Panel/NextButton

var _steps: Array[String] = [
    "Press the Start button to begin the clock.",
    "Click a tile to select it.",
    "Use the Build button to construct a structure."
]
var _index: int = 0

func _ready() -> void:
    next_button.pressed.connect(_on_next_pressed)
    _show_step()

func _show_step() -> void:
    if _index < _steps.size():
        text_label.text = _steps[_index]
    else:
        tutorial_completed.emit()
        queue_free()

func _on_next_pressed() -> void:
    _index += 1
    _show_step()
