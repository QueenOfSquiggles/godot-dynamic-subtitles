extends Node

export (float) var custom_viewport_scale := 1.0

func _ready() -> void:
	yield(get_parent(), "ready")
	assert(get_parent() is Viewport, "This node must be a child of a viewport!")
	Subtitles.custom_viewport_scale = custom_viewport_scale
	Subtitles.set_viewport(get_parent())

func _exit_tree() -> void:
	Subtitles.custom_viewport_scale = 1.0
