extends BTCompositor

export (NodePath) var from_node : NodePath setget set_from_node
export (String) var node_property := "" setget set_node_prop
export (String) var blackboard_key := "" setget set_blackboard_key

onready var has_prop := $BT_Decorator/BTQ_HasProperty
onready var load_prop := $BTA_LoadPropertyFrom

func set_from_node(path : NodePath) -> void:
	from_node = path
	load_prop.from_node = path
	
func set_node_prop(prop : String) -> void:
	node_property = prop
	load_prop.node_property = prop

func set_blackboard_key(key : String) -> void:
	blackboard_key = key
	has_prop.blackboard_key = key
	load_prop.blackboard_key = key
