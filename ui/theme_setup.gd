extends Node


func _ready() -> void:
    var theme := Theme.new()
    var font: FontFile = load("res://fonts/Inter-Regular.ttf")
    theme.default_font = font
    theme.default_font_size = 18

    theme.set_color("font_color", "Label", Palette.FG)
    theme.set_color("font_color", "Button", Palette.FG)
    theme.set_color("font_hover_color", "Button", Palette.ACCENT)
    theme.set_color("font_pressed_color", "Button", Palette.ACCENT)

    theme.set_constant("separation", "HBoxContainer", 8)
    theme.set_constant("separation", "VBoxContainer", 8)

    var panel := StyleBoxFlat.new()
    panel.bg_color = Palette.BG
    panel.corner_radius_top_left = 12
    panel.corner_radius_top_right = 12
    panel.corner_radius_bottom_left = 12
    panel.corner_radius_bottom_right = 12
    theme.set_stylebox("panel", "Panel", panel)
    theme.set_stylebox("panel", "PanelContainer", panel)

    get_tree().root.theme = theme
