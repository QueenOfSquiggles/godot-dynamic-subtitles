extends Node
"""
Autoload for handling subtitles. The logic for positioning and holding the subtitles is handled by seperate layers
"""


onready var layer_3D := SubtitlesLayer3D.new()

func _ready() -> void:
	add_child(layer_3D)
	

func add_subtitle(sub_data : Node, audio_stream : Node, theme_override : Theme = null) -> void:
	# we have to type `sub_data` as Node instead of SubtitlesData because it introduces a cyclic dependency. This class actually doesn't care what node that is because we just pass it along to the proper layer
	if audio_stream is AudioStreamPlayer3D:
		layer_3D.add_subtitle(audio_stream, sub_data, theme_override)
