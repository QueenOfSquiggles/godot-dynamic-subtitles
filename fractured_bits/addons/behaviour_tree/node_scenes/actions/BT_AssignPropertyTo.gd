extends BTLeaf

export (String) var blackboard_key := ""
export (NodePath) var to_node : NodePath
export (String) var to_property := ""

onready var node := get_node(to_node) as Node

func tick(actor : Node, blackboard : Dictionary) -> int:
	var property = blackboard[blackboard_key]
	# would an assert be useful here? It'll break either way and I can debug from there
	node.set_indexed(to_property, property)
	return STATE_SUCCESS
