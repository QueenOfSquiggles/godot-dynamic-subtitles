extends Node
"""
Autoload for handling subtitles. The logic for positioning and holding the subtitles is handled by seperate layers
"""

# Since these are variables on a singleton, the CanvasLayer settings could easily be modified by the user at any point during initialization
onready var layer_3D := SubtitlesLayer3D.new()
onready var layer_2D := SubtitlesLayer2D.new()
onready var layer_dialogue := SubtitlesLayerDialogue.new()

var default_subtitle_theme := preload("res://addons/subtitles/default_theming/base_theme.tres")

func _ready() -> void:
	add_child(layer_3D)
	add_child(layer_2D)
	add_child(layer_dialogue)
	
func add_subtitle(sub_data : Node, audio_stream : Node) -> void:
	# we have to type `sub_data` as Node instead of SubtitlesData because it introduces a cyclic dependency. This class actually doesn't care what node that is because we just pass it along to the proper layer
	var theme_override = null
	if sub_data.subtitle_theme_override == null:
		# use default theme for any that don't have a theme specified
		theme_override = default_subtitle_theme

	if sub_data.is_character_dialogue:
		# if identified as a dialogue, push to the dialogue layer
		layer_dialogue.add_subtitle(audio_stream, sub_data, theme_override)
	elif audio_stream is AudioStreamPlayer3D:
		# not character dialogue, handle 3D subtitles
		layer_3D.add_subtitle(audio_stream, sub_data, theme_override)
	elif audio_stream is AudioStreamPlayer2D:
		# not character dialogue, handle 2D subtitle
		layer_2D.add_subtitle(audio_stream, sub_data, theme_override)
	else:
		push_warning("Subtitle [%s] should be either assigned as a character dialogue, or be under a 3D or 2D AudioStreamPlayer. Pushing this to the character dialogue layer. Delete this warning if this functionality is desired")
		# fallback case, generally undersireable? Hence the warning
		layer_dialogue.add_subtitle(audio_stream, sub_data, theme_override)
