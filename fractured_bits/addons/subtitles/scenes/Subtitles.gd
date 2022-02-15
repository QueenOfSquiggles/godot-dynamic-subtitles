extends Node
"""
Subtitles (SubtitlesLayer.gd)

see 'create_subtitle' for core functionality

This node is a canvas layer autoload so the layer this renders on can be customized. I.e. if you want the subtitles to be behind some kind of detail layer, that's possible. IN general it is recommended to put subtitles as top-layer as possible.
"""


onready var layer_3D := SubtitlesLayer3D.new()

func _ready() -> void:
	add_child(layer_3D)
	

func add_subtitle(sub_data : Node, audio_stream : Node, theme_override : Theme = null) -> void:
	# we have to type `sub_data` as Node instead of SubtitlesData because it introduces a cyclic dependency. This class actually doesn't care what node that is because we just pass it along to the proper layer
	if audio_stream is AudioStreamPlayer3D:
		layer_3D.add_subtitle(audio_stream, sub_data, theme_override)
