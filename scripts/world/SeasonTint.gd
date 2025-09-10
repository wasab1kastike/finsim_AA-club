extends CanvasModulate

func set_season(season: String) -> void:
    match season:
        "winter":
            color = Color(0.8, 0.9, 1.0, 1.0)  # slight blue tint
        "summer":
            color = Color(1.0, 0.95, 0.9, 1.0)  # slight warm tint
        _:
            color = Color.WHITE

