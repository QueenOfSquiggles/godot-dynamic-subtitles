extends Node
"""
Autoload for handling subtitles. The logic for positioning and holding the subtitles is handled by seperate layers
"""

# Since these are variables on a singleton, the CanvasLayer settings could easily be modified by the user at any point during initialization
var layer_3D : SubtitlesLayer3D
var layer_2D : SubtitlesLayer2D
var layer_dialogue : SubtitlesLayerDialogue

var default_subtitle_theme := preload("res://addons/subtitles/default_theming/base_theme.tres")

"""
Editable Subtitles Settings

These should be available in Project Settings, which may be easier to use than through code

"""
var subtitles_enabled := true
var use_auto_dialogue_line_splitter := true
var custom_viewport_scale := 1.0

signal on_viewport_changed(viewport)

func _ready() -> void:
	layer_3D = SubtitlesLayer3D.new()
	layer_2D = SubtitlesLayer2D.new()
	layer_dialogue = SubtitlesLayerDialogue.new()

	add_child(layer_3D)
	add_child(layer_2D)
	add_child(layer_dialogue)
	layer_3D.set_process_input(false)
	layer_2D.set_process_input(false)
	layer_dialogue.set_process_input(false)
	

func add_subtitle(sub_data : Node, audio_stream : Node) -> void:
	# we have to type `sub_data` as Node instead of SubtitlesData because it introduces a cyclic dependency. This class actually doesn't care what node that is because we just pass it along to the proper layer
	if subtitles_enabled == false:
		return
	
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

func clear_subtitles() -> void:
	layer_3D.clear()
	layer_2D.clear()
	layer_dialogue.clear()

func hide() -> void:
	layer_3D.set_visible(false)
	layer_2D.set_visible(false)
	layer_dialogue.set_visible(false)
	
func show() -> void:
	layer_3D.set_visible(true)
	layer_2D.set_visible(true)
	layer_dialogue.set_visible(true)

func set_viewport(viewport : Viewport) -> void:
	if not is_instance_valid(get_tree()):
		# for some reason this always produces an error. But it's fine because that only happens when the game is closing anyway
		return
	emit_signal("on_viewport_changed", viewport)
	if not viewport.is_connected("tree_exiting", self, "set_viewport"):
		viewport.connect("tree_exiting", self, "set_viewport", [get_tree().root.get_viewport()])
