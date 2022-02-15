extends Node

export (String) var save_id := "generic_save"
export (NodePath) var source_node_path : NodePath
export (Array, String) var properties := []

var source_node : Node

func _ready() -> void:
	source_node = get_node(source_node_path)
	if not source_node:
		source_node = get_parent()
	SaveData.connect("on_loading", self, "load_data")
	SaveData.connect("on_saving", self, "save_data")

func load_data() -> void:
	var data := SaveData.load_custom_data(save_id) as Dictionary
	if data.empty():
		return
	for key in properties:
		if data.has(key):
			source_node.set_indexed(key, data[key])
	if source_node.has_method("load_data"):
		source_node.load_data(data)

func save_data() -> void:
	var data := {}
	for key in properties:
		data[key] = source_node.get_indexed(key)
	if source_node.has_method("save_data"):
		data = source_node.save_data(data)
	if not data.empty():
		SaveData.save_custom_data(save_id, data)
