extends BTLeaf

export (NodePath) var from_node : NodePath
export (String) var node_property := ""
export (String) var blackboard_key := ""

func tick(actor : Node, blackboard : Dictionary) -> int:
	var node := get_node(from_node) as Node
	var property = node.get_indexed(node_property)
	blackboard[blackboard_key] = property
	return STATE_SUCCESS
