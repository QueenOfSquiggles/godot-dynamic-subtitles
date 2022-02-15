tool
extends Label

export (int, 1, 512) var font_size := 16 setget set_font_size


func set_font_size(value : int) -> void:
	font_size = value
