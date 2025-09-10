extends CanvasLayer
class_name EventOverlay

signal choice_selected(choice: Dictionary)

const GameEvent = preload("res://scripts/events/Event.gd")

@onready var title_label: Label = $Panel/Title
@onready var description_label: Label = $Panel/Description
@onready var choices_container: VBoxContainer = $Panel/Choices

func show_event(ev: GameEvent) -> void:
    title_label.text = ev.name
    description_label.text = ev.description
    for c in ev.choices:
        var btn := Button.new()
        btn.text = c.get("text", "Choice")
        btn.pressed.connect(func(): choice_selected.emit(c); queue_free())
        choices_container.add_child(btn)
