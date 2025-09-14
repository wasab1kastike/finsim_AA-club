extends Theme

func _init():
    var fg := StyleBoxFlat.new()
    fg.bg_color = Palette.HP_GREEN
    fg.corner_radius_top_left = 3
    fg.corner_radius_top_right = 3
    fg.corner_radius_bottom_left = 3
    fg.corner_radius_bottom_right = 3

    var bg := StyleBoxFlat.new()
    bg.bg_color = Color(0,0,0,0.55)
    bg.corner_radius_top_left = 3
    bg.corner_radius_top_right = 3
    bg.corner_radius_bottom_left = 3
    bg.corner_radius_bottom_right = 3

    set_stylebox("fill", "ProgressBar", fg)
    set_stylebox("background", "ProgressBar", bg)
    set_constant("outline_size", "ProgressBar", 0)
    set_color("font_color", "ProgressBar", Palette.TEXT)
    set_font_size("font_size", "ProgressBar", 10)
