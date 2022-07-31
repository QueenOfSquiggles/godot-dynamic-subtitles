extends CanvasLayer
class_name SubtitlesLayer2D

func add_subtitle(_stream_node : AudioStreamPlayer2D, _sub_data : SubtitleData, _theme_override : Theme = null) -> void:
	pass

func clear() -> void:
	# not currently implemented
	pass

func set_visible(is_visible : bool) -> void:
	for c in get_children():
		if c is Control:
			(c as Control).visible = is_visible
