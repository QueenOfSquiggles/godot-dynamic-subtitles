tool
extends EditorPlugin

const SINGLETON := "Subtitles"
const GEN_SUBS_NAME := "Generate SubtitleData in Scene"

onready var subtitle_data_script := preload("res://addons/subtitles/scenes/SubtitleData.gd")

func _enter_tree() -> void:
	add_custom_type("SubtitleData", "Node", subtitle_data_script, null)
	add_autoload_singleton(SINGLETON, "res://addons/subtitles/scenes/Subtitles.gd")
	add_tool_menu_item(GEN_SUBS_NAME, self, "_tool_gen_subdata_in_scene")


func _exit_tree() -> void:
	remove_custom_type("SubtitleData")
	remove_autoload_singleton(SINGLETON)
	remove_tool_menu_item(GEN_SUBS_NAME)


func _tool_gen_subdata_in_scene(args) -> void:
	var scene := get_tree().edited_scene_root
	var audio_nodes := _recurse_get_audio_nodes(scene)
	print("Found %s audio nodes in current scene" % str(audio_nodes.size()))
	for a in audio_nodes:
		var audio := a as Node
		print("Processing node [%s]" % str(scene.get_path_to(audio)))
		var add_data :bool = true
		for c in audio.get_children():
			if c is SubtitleData:
				add_data = false
		if add_data:
			print(">\tAdding sub data")
			var sub_data := SubtitleData.new()
			sub_data.name = "SubtitleData"
			audio.add_child(sub_data)
			sub_data.subtitle_key = audio.name
			sub_data.set_owner(scene)
		else:
			print(">\tSubtitle data detected on scene node : %s" %  str(scene.get_path_to(audio)))
		print(">\t", audio.get_children())
	#print("reloading")
	# TODO Do we need to add anything here? Like some kind of "mark_changed" kind of thing?

func _recurse_get_audio_nodes(root : Node, existing_array : Array = []) -> Array:
	for c in root.get_children():
		# technically this will skip the root node if it is an audio node, however, that is so incredibly unlikely for a scene.
		if _is_audio_node(c):
			existing_array.append(c)
		_recurse_get_audio_nodes(c, existing_array)
	return existing_array

func _is_audio_node(node : Node) -> bool:
	if node is AudioStreamPlayer:
		return true
	if node is AudioStreamPlayer2D:
		return true
	if node is AudioStreamPlayer3D:
		return true
	return false
