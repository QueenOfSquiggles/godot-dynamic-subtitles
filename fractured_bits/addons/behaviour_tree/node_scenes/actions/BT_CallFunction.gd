extends BTLeaf

export (NodePath) var target_node : NodePath
export (String) var func_name := ""
export (bool) var deferred := false

onready var node := get_node(target_node) as Node

func tick(actor : Node, blackboard : Dictionary) -> int:
	if node.has_method(func_name):
		if deferred:
			node.call_deferred(func_name)
		else:
			node.call(func_name)
		return STATE_SUCCESS
	# fail if the method doesn't exist.
	# not sure if that's really useful
	return STATE_FAILURE
